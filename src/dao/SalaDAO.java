package dao;

import db.ConexaoDB;
import model.Sala;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO de Sala — acesso ao banco via prepared statements.
 */
public class SalaDAO {

    public void inserir(Sala s) throws SQLException {
        String sql = """
            INSERT INTO Sala (numero, capacidade, tipo, estado)
            VALUES (?, ?, ?, ?)
            """;
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt   (1, s.getNumero());
            ps.setInt   (2, s.getCapacidade());
            ps.setString(3, s.getTipo());
            ps.setString(4, s.getEstado());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) s.setId(rs.getInt(1));
            }
        }
    }

    public List<Sala> listarTodas() throws SQLException {
        String sql = """
            SELECT id_sala, numero, capacidade, tipo, estado
            FROM Sala
            ORDER BY numero ASC
            """;
        List<Sala> lista = new ArrayList<>();
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public List<Sala> listarAtivas() throws SQLException {
        String sql = """
            SELECT id_sala, numero, capacidade, tipo, estado
            FROM Sala
            WHERE estado = 'Ativa'
            ORDER BY numero ASC
            """;
        List<Sala> lista = new ArrayList<>();
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public Sala buscarPorId(int id) throws SQLException {
        String sql = """
            SELECT id_sala, numero, capacidade, tipo, estado
            FROM Sala WHERE id_sala = ?
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

    public boolean atualizar(Sala s) throws SQLException {
        String sql = """
            UPDATE Sala
            SET numero = ?, capacidade = ?, tipo = ?, estado = ?
            WHERE id_sala = ?
            """;
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt   (1, s.getNumero());
            ps.setInt   (2, s.getCapacidade());
            ps.setString(3, s.getTipo());
            ps.setString(4, s.getEstado());
            ps.setInt   (5, s.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean excluir(int id) throws SQLException {
        // Só permite excluir sala sem sessões associadas (RN07)
        String sql = "DELETE FROM Sala WHERE id_sala = ?";
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private Sala mapear(ResultSet rs) throws SQLException {
        Sala s = new Sala();
        s.setId        (rs.getInt   ("id_sala"));
        s.setNumero    (rs.getInt   ("numero"));
        s.setCapacidade(rs.getInt   ("capacidade"));
        s.setTipo      (rs.getString("tipo"));
        s.setEstado    (rs.getString("estado"));
        return s;
    }
}
