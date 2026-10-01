package dao;

import db.ConexaoDB;
import model.Cliente;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO de Cliente — acesso ao banco via prepared statements.
 * RN16: CPF único, 11 dígitos (enforçado pelo banco).
 * RN17: pontos de fidelidade gerenciados pela aplicação.
 */
public class ClienteDAO {

    // -------------------------------------------------------------------------
    // CREATE
    // -------------------------------------------------------------------------
    public void inserir(Cliente c) throws SQLException {
        String sql = """
            INSERT INTO Cliente
                (nome, cpf, data_nascimento, email, telefone,
                 pontos_fidelidade, data_cadastro)
            VALUES (?, ?, ?, ?, ?, 0, CURRENT_DATE)
            """;
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(
                     sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, c.getNome());
            ps.setString(2, c.getCpf());
            ps.setDate  (3, c.getDataNascimento() != null
                    ? Date.valueOf(c.getDataNascimento()) : null);
            ps.setString(4, c.getEmail());
            ps.setString(5, c.getTelefone());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) c.setId(rs.getInt(1));
            }
        }
    }

    // -------------------------------------------------------------------------
    // READ — listar todos
    // -------------------------------------------------------------------------
    public List<Cliente> listarTodos() throws SQLException {
        String sql = """
            SELECT id_cliente, nome, cpf, data_nascimento,
                   email, telefone, pontos_fidelidade, data_cadastro
            FROM Cliente
            ORDER BY nome ASC
            """;
        List<Cliente> lista = new ArrayList<>();
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
    public Cliente buscarPorId(int id) throws SQLException {
        String sql = """
            SELECT id_cliente, nome, cpf, data_nascimento,
                   email, telefone, pontos_fidelidade, data_cadastro
            FROM Cliente WHERE id_cliente = ?
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
    // READ — buscar por CPF (consulta parametrizada — B2)
    // -------------------------------------------------------------------------
    public Cliente buscarPorCpf(String cpf) throws SQLException {
        String sql = """
            SELECT id_cliente, nome, cpf, data_nascimento,
                   email, telefone, pontos_fidelidade, data_cadastro
            FROM Cliente WHERE cpf = ?
            """;
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, cpf);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    // -------------------------------------------------------------------------
    // READ — buscar por nome (LIKE — consulta parametrizada)
    // -------------------------------------------------------------------------
    public List<Cliente> buscarPorNome(String fragmento) throws SQLException {
        String sql = """
            SELECT id_cliente, nome, cpf, data_nascimento,
                   email, telefone, pontos_fidelidade, data_cadastro
            FROM Cliente WHERE nome LIKE ?
            ORDER BY nome ASC
            """;
        List<Cliente> lista = new ArrayList<>();
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + fragmento + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    // -------------------------------------------------------------------------
    // READ — relatório alimentado pela view vw_fidelidade_clientes
    // -------------------------------------------------------------------------
    public void exibirRelatorioFidelidade() throws SQLException {
        String sql = """
            SELECT nome, cpf, email, pontos_fidelidade,
                   total_ingressos_pagos, total_gasto,
                   data_cadastro
            FROM vw_fidelidade_clientes
            ORDER BY pontos_fidelidade DESC
            """;
        System.out.println("\n╔══════════════════════════════════════════════════════════╗");
        System.out.println("║         RELATÓRIO DE FIDELIDADE DE CLIENTES              ║");
        System.out.println("╚══════════════════════════════════════════════════════════╝");
        System.out.printf("%-30s %-11s %-5s %-8s %-12s%n",
            "Nome", "CPF", "Pts", "Ingressos", "Gasto Total");
        System.out.println("─".repeat(75));
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int linhas = 0;
            while (rs.next()) {
                System.out.printf("%-30s %-11s %-5d %-9d R$ %,.2f%n",
                    rs.getString("nome"),
                    rs.getString("cpf"),
                    rs.getInt   ("pontos_fidelidade"),
                    rs.getInt   ("total_ingressos_pagos"),
                    rs.getDouble("total_gasto"));
                linhas++;
            }
            if (linhas == 0) System.out.println("Nenhum cliente com compras registradas.");
        }
    }

    // -------------------------------------------------------------------------
    // UPDATE
    // -------------------------------------------------------------------------
    public boolean atualizar(Cliente c) throws SQLException {
        String sql = """
            UPDATE Cliente
            SET nome = ?, email = ?, telefone = ?
            WHERE id_cliente = ?
            """;
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, c.getNome());
            ps.setString(2, c.getEmail());
            ps.setString(3, c.getTelefone());
            ps.setInt   (4, c.getId());
            return ps.executeUpdate() > 0;
        }
    }

    // -------------------------------------------------------------------------
    // DELETE (hard delete — só se não houver ingressos)
    // -------------------------------------------------------------------------
    public boolean excluir(int id) throws SQLException {
        String sql = "DELETE FROM Cliente WHERE id_cliente = ?";
        try (Connection con = ConexaoDB.getConexao();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // -------------------------------------------------------------------------
    // Mapeamento ResultSet → Cliente
    // -------------------------------------------------------------------------
    private Cliente mapear(ResultSet rs) throws SQLException {
        Cliente c = new Cliente();
        c.setId              (rs.getInt   ("id_cliente"));
        c.setNome            (rs.getString("nome"));
        c.setCpf             (rs.getString("cpf"));
        Date dn = rs.getDate("data_nascimento");
        if (dn != null) c.setDataNascimento(dn.toLocalDate());
        c.setEmail           (rs.getString("email"));
        c.setTelefone        (rs.getString("telefone"));
        c.setPontosFidelidade(rs.getInt   ("pontos_fidelidade"));
        Date dc = rs.getDate("data_cadastro");
        if (dc != null) c.setDataCadastro(dc.toLocalDate());
        return c;
    }
}
