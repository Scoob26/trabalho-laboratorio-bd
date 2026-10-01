package dao;

import db.ConexaoDB;
import model.Sessao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO de Sessao — inclui verificação de sobreposição de horário (RN09)
 * e atualização de status com registro no histórico (RN11), tudo em
 * uma única transação explícita.
 */
public class SessaoDAO {

    // -------------------------------------------------------------------------
    // CREATE — com verificação de sobreposição (RN09) via transação
    // -------------------------------------------------------------------------
    public void inserir(Sessao s) throws SQLException {
        Connection con = ConexaoDB.getConexao();
        con.setAutoCommit(false);

        try {
            // 1. Verifica sobreposição de horário na mesma sala (RN09)
            if (existeSobreposicao(con, s)) {
                con.rollback();
                throw new SQLException(
                    "RN09: Conflito de horário — outra sessão ocupa este " +
                    "intervalo na sala " + s.getIdSala() +
                    " (incluindo 20 min de intervalo mínimo).");
            }

            // 2. Verifica que sala está Ativa (RN07)
            if (!salaEstaAtiva(con, s.getIdSala())) {
                con.rollback();
                throw new SQLException(
                    "RN07: Sala " + s.getIdSala() +
                    " não está Ativa. Sessão não pode ser criada.");
            }

            // 3. Insere a sessão
            String sqlInsert = """
                INSERT INTO Sessao
                    (data_hora_inicio, data_hora_fim, idioma,
                     valor_ingresso_base, status, id_filme, id_sala)
                VALUES (?, ?, ?, ?, 'Agendada', ?, ?)
                """;
            try (PreparedStatement ps = con.prepareStatement(
                    sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
                ps.setTimestamp(1, Timestamp.valueOf(s.getDataHoraInicio()));
                ps.setTimestamp(2, Timestamp.valueOf(s.getDataHoraFim()));
                ps.setString   (3, s.getIdioma());
                ps.setDouble   (4, s.getValorIngressoBase());
                ps.setInt      (5, s.getIdFilme());
                ps.setInt      (6, s.getIdSala());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) s.setId(rs.getInt(1));
                }
            }

            // 4. Registra o status inicial no histórico (RN11)
            registrarHistorico(con, s.getId(), null, "Agendada", null);

            con.commit();

        } catch (SQLException e) {
            con.rollback();
            throw e;
        } finally {
            con.setAutoCommit(true);
        }
    }

    // -------------------------------------------------------------------------
    // READ — listar sessões agendadas futuras
    // -------------------------------------------------------------------------
    public List<Sessao> listarAgendadas() throws SQLException {
        String sql = """
            SELECT s.id_sessao, s.data_hora_inicio, s.data_hora_fim,
                   s.idioma, s.valor_ingresso_base, s.status,
                   s.id_filme, f.titulo AS titulo_filme,
                   s.id_sala, sa.numero AS numero_sala, sa.tipo AS tipo_sala,
                   sa.capacidade,
                   (SELECT COUNT(*) FROM Ingresso i
                    WHERE i.id_sessao = s.id_sessao
                      AND i.status <> 'Cancelado') AS ingressos_vendidos
            FROM Sessao s
            JOIN Filme f  ON f.id_filme = s.id_filme
            JOIN Sala  sa ON sa.id_sala = s.id_sala
            WHERE s.status = 'Agendada'
              AND s.data_hora_inicio >= NOW()
            ORDER BY s.data_hora_inicio ASC
            """;
        return executarListagem(sql);
    }

    // -------------------------------------------------------------------------
    // READ — buscar sessões por filme, com filtro opcional de status (B2)
    // -------------------------------------------------------------------------
    public List<Sessao> buscarPorFilme(int idFilme, String status) throws SQLException {
        // status == null → sem filtro; caso contrário filtra pelo valor informado
        String sql = """
            SELECT s.id_sessao, s.data_hora_inicio, s.data_hora_fim,
                   s.idioma, s.valor_ingresso_base, s.status,
                   s.id_filme, f.titulo AS titulo_filme,
                   s.id_sala, sa.numero AS numero_sala, sa.tipo AS tipo_sala,
                   sa.capacidade,
                   (SELECT COUNT(*) FROM Ingresso i
                    WHERE i.id_sessao = s.id_sessao
                      AND i.status <> 'Cancelado') AS ingressos_vendidos
            FROM Sessao s
            JOIN Filme f  ON f.id_filme = s.id_filme
            JOIN Sala  sa ON sa.id_sala = s.id_sala
            WHERE s.id_filme = ?
            """ + (status != null ? "  AND s.status = ?\n" : "") + """
            ORDER BY s.data_hora_inicio ASC
            """;
        List<Sessao> lista = new ArrayList<>();
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idFilme);
            if (status != null) ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    // -------------------------------------------------------------------------
    // READ — buscar por ID
    // -------------------------------------------------------------------------
    public Sessao buscarPorId(int id) throws SQLException {
        String sql = """
            SELECT s.id_sessao, s.data_hora_inicio, s.data_hora_fim,
                   s.idioma, s.valor_ingresso_base, s.status,
                   s.id_filme, f.titulo AS titulo_filme,
                   s.id_sala, sa.numero AS numero_sala, sa.tipo AS tipo_sala,
                   sa.capacidade,
                   (SELECT COUNT(*) FROM Ingresso i
                    WHERE i.id_sessao = s.id_sessao
                      AND i.status <> 'Cancelado') AS ingressos_vendidos
            FROM Sessao s
            JOIN Filme f  ON f.id_filme = s.id_filme
            JOIN Sala  sa ON sa.id_sala = s.id_sala
            WHERE s.id_sessao = ?
            """;
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    // -------------------------------------------------------------------------
    // UPDATE STATUS — transação explícita com registro no histórico (RN11)
    // -------------------------------------------------------------------------
    public void atualizarStatus(int idSessao, String novoStatus,
                                 Integer idFuncionario) throws SQLException {
        Connection con = ConexaoDB.getConexao();
        con.setAutoCommit(false);
        try {
            // 1. Obtém status atual
            String statusAtual = obterStatusAtual(con, idSessao);
            if (statusAtual == null) {
                throw new SQLException("Sessão " + idSessao + " não encontrada.");
            }

            // 2. Atualiza o status
            String sqlUp = "UPDATE Sessao SET status = ? WHERE id_sessao = ?";
            try (PreparedStatement ps = con.prepareStatement(sqlUp)) {
                ps.setString(1, novoStatus);
                ps.setInt   (2, idSessao);
                ps.executeUpdate();
            }

            // 3. Registra no histórico (RN11)
            registrarHistorico(con, idSessao, statusAtual, novoStatus, idFuncionario);

            con.commit();
        } catch (SQLException e) {
            con.rollback();
            throw e;
        } finally {
            con.setAutoCommit(true);
        }
    }

    // -------------------------------------------------------------------------
    // Helpers privados
    // -------------------------------------------------------------------------

    private boolean existeSobreposicao(Connection con, Sessao s)
            throws SQLException {
        // Verifica sobreposição incluindo 20 min de intervalo mínimo (RN09)
        String sql = """
            SELECT COUNT(*) FROM Sessao
            WHERE id_sala = ?
              AND status <> 'Cancelada'
              AND data_hora_inicio < DATE_ADD(?, INTERVAL 20 MINUTE)
              AND data_hora_fim    > DATE_SUB(?, INTERVAL 20 MINUTE)
            """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt      (1, s.getIdSala());
            ps.setTimestamp(2, Timestamp.valueOf(s.getDataHoraFim()));
            ps.setTimestamp(3, Timestamp.valueOf(s.getDataHoraInicio()));
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        }
    }

    private boolean salaEstaAtiva(Connection con, int idSala)
            throws SQLException {
        String sql = "SELECT estado FROM Sala WHERE id_sala = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idSala);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return "Ativa".equals(rs.getString("estado"));
            }
        }
        return false;
    }

    private String obterStatusAtual(Connection con, int idSessao)
            throws SQLException {
        String sql = "SELECT status FROM Sessao WHERE id_sessao = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idSessao);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("status");
            }
        }
        return null;
    }

    private void registrarHistorico(Connection con, int idSessao,
                                     String statusAnt, String statusNovo,
                                     Integer idFuncionario) throws SQLException {
        String sql = """
            INSERT INTO Historico_Status_Sessao
                (id_sessao, status_anterior, status_novo,
                 data_hora_mudanca, id_funcionario)
            VALUES (?, ?, ?, NOW(), ?)
            """;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt   (1, idSessao);
            if (statusAnt != null) ps.setString(2, statusAnt);
            else                   ps.setNull  (2, Types.VARCHAR);
            ps.setString(3, statusNovo);
            if (idFuncionario != null) ps.setInt (4, idFuncionario);
            else                       ps.setNull(4, Types.INTEGER);
            ps.executeUpdate();
        }
    }

    private List<Sessao> executarListagem(String sql) throws SQLException {
        List<Sessao> lista = new ArrayList<>();
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    private Sessao mapear(ResultSet rs) throws SQLException {
        Sessao s = new Sessao();
        s.setId               (rs.getInt      ("id_sessao"));
        Timestamp ini = rs.getTimestamp("data_hora_inicio");
        if (ini != null) s.setDataHoraInicio(ini.toLocalDateTime());
        Timestamp fim = rs.getTimestamp("data_hora_fim");
        if (fim != null) s.setDataHoraFim(fim.toLocalDateTime());
        s.setIdioma           (rs.getString   ("idioma"));
        s.setValorIngressoBase(rs.getDouble   ("valor_ingresso_base"));
        s.setStatus           (rs.getString   ("status"));
        s.setIdFilme          (rs.getInt      ("id_filme"));
        s.setTituloFilme      (rs.getString   ("titulo_filme"));
        s.setIdSala           (rs.getInt      ("id_sala"));
        s.setNumeroSala       (rs.getInt      ("numero_sala"));
        s.setTipoSala         (rs.getString   ("tipo_sala"));
        s.setCapacidadeSala   (rs.getInt      ("capacidade"));
        s.setIngressosVendidos(rs.getInt      ("ingressos_vendidos"));
        return s;
    }
}
