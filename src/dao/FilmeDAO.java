package dao;

import db.ConexaoDB;
import model.Filme;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO de Filme — acesso ao banco via prepared statements (B2/RN requisito).
 * Nenhuma concatenação de string para montar SQL.
 */
public class FilmeDAO {

    // -------------------------------------------------------------------------
    // CREATE
    // -------------------------------------------------------------------------
    public void inserir(Filme f) throws SQLException {
        String sql = """
            INSERT INTO Filme
                (titulo, titulo_nacional, duracao_min, classificacao_etaria,
                 sinopse, data_lancamento, ativo, id_distribuidora)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, f.getTitulo());
            ps.setString(2, f.getTituloNacional());
            ps.setInt   (3, f.getDuracaoMin());
            ps.setString(4, f.getClassificacaoEtaria());
            ps.setString(5, f.getSinopse());
            ps.setDate  (6, f.getDataLancamento() != null
                    ? Date.valueOf(f.getDataLancamento()) : null);
            ps.setBoolean(7, f.isAtivo());
            ps.setInt   (8, f.getIdDistribuidora());

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) f.setId(rs.getInt(1));
            }
        }
    }

    // -------------------------------------------------------------------------
    // READ — listar todos ativos
    // -------------------------------------------------------------------------
    public List<Filme> listarAtivos() throws SQLException {
        String sql = """
            SELECT f.id_filme, f.titulo, f.titulo_nacional, f.duracao_min,
                   f.classificacao_etaria, f.sinopse, f.data_lancamento,
                   f.ativo, f.id_distribuidora, d.nome AS nome_distribuidora
            FROM Filme f
            JOIN Distribuidora d ON d.id_distribuidora = f.id_distribuidora
            WHERE f.ativo = 1
            ORDER BY f.titulo ASC
            """;
        List<Filme> lista = new ArrayList<>();
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    // -------------------------------------------------------------------------
    // READ — buscar por ID
    // -------------------------------------------------------------------------
    public Filme buscarPorId(int id) throws SQLException {
        String sql = """
            SELECT f.id_filme, f.titulo, f.titulo_nacional, f.duracao_min,
                   f.classificacao_etaria, f.sinopse, f.data_lancamento,
                   f.ativo, f.id_distribuidora, d.nome AS nome_distribuidora
            FROM Filme f
            JOIN Distribuidora d ON d.id_distribuidora = f.id_distribuidora
            WHERE f.id_filme = ?
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
    // READ — buscar por título (LIKE)
    // -------------------------------------------------------------------------
    public List<Filme> buscarPorTitulo(String fragmento) throws SQLException {
        String sql = """
            SELECT f.id_filme, f.titulo, f.titulo_nacional, f.duracao_min,
                   f.classificacao_etaria, f.sinopse, f.data_lancamento,
                   f.ativo, f.id_distribuidora, d.nome AS nome_distribuidora
            FROM Filme f
            JOIN Distribuidora d ON d.id_distribuidora = f.id_distribuidora
            WHERE f.titulo LIKE ? OR f.titulo_nacional LIKE ?
            ORDER BY f.titulo ASC
            """;
        List<Filme> lista = new ArrayList<>();
        String padrao = "%" + fragmento + "%";
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, padrao);
            ps.setString(2, padrao);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    // -------------------------------------------------------------------------
    // UPDATE
    // -------------------------------------------------------------------------
    public boolean atualizar(Filme f) throws SQLException {
        String sql = """
            UPDATE Filme
            SET titulo = ?, titulo_nacional = ?, duracao_min = ?,
                classificacao_etaria = ?, sinopse = ?,
                data_lancamento = ?, ativo = ?, id_distribuidora = ?
            WHERE id_filme = ?
            """;
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString (1, f.getTitulo());
            ps.setString (2, f.getTituloNacional());
            ps.setInt    (3, f.getDuracaoMin());
            ps.setString (4, f.getClassificacaoEtaria());
            ps.setString (5, f.getSinopse());
            ps.setDate   (6, f.getDataLancamento() != null
                    ? Date.valueOf(f.getDataLancamento()) : null);
            ps.setBoolean(7, f.isAtivo());
            ps.setInt    (8, f.getIdDistribuidora());
            ps.setInt    (9, f.getId());
            return ps.executeUpdate() > 0;
        }
    }

    // -------------------------------------------------------------------------
    // DELETE (soft delete — desativa)
    // -------------------------------------------------------------------------
    public boolean desativar(int id) throws SQLException {
        String sql = "UPDATE Filme SET ativo = 0 WHERE id_filme = ?";
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // -------------------------------------------------------------------------
    // Mapeamento ResultSet → Filme
    // -------------------------------------------------------------------------
    private Filme mapear(ResultSet rs) throws SQLException {
        Filme f = new Filme();
        f.setId                 (rs.getInt   ("id_filme"));
        f.setTitulo             (rs.getString ("titulo"));
        f.setTituloNacional     (rs.getString ("titulo_nacional"));
        f.setDuracaoMin         (rs.getInt    ("duracao_min"));
        f.setClassificacaoEtaria(rs.getString ("classificacao_etaria"));
        f.setSinopse            (rs.getString ("sinopse"));
        Date dl = rs.getDate("data_lancamento");
        if (dl != null) f.setDataLancamento(dl.toLocalDate());
        f.setAtivo              (rs.getBoolean("ativo"));
        f.setIdDistribuidora    (rs.getInt    ("id_distribuidora"));
        f.setNomeDistribuidora  (rs.getString ("nome_distribuidora"));
        return f;
    }
}
