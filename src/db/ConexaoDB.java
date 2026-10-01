package db;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Gerencia a conexão singleton com o banco de dados MySQL.
 * Credenciais carregadas de db.properties (fora do versionamento).
 */
public class ConexaoDB {

    private static Connection instancia = null;

    private ConexaoDB() {}

    /**
     * Retorna a conexão ativa, abrindo uma nova se necessário.
     */
    public static Connection getConexao() throws SQLException {
        if (instancia == null || instancia.isClosed()) {
            instancia = abrirConexao();
        }
        return instancia;
    }

    private static Connection abrirConexao() throws SQLException {
        Properties props = carregarPropriedades();
        String url      = props.getProperty("db.url");
        String usuario  = props.getProperty("db.usuario");
        String senha    = props.getProperty("db.senha");

        if (url == null || usuario == null || senha == null) {
            throw new SQLException(
                "Configuração incompleta. Verifique src/db/db.properties.");
        }

        return DriverManager.getConnection(url, usuario, senha);
    }

    private static Properties carregarPropriedades() throws SQLException {
        Properties props = new Properties();
        // Carrega do classpath (src/db/db.properties)
        try (InputStream is = ConexaoDB.class
                .getResourceAsStream("/db/db.properties")) {
            if (is == null) {
                throw new SQLException(
                    "Arquivo db.properties não encontrado no classpath.");
            }
            props.load(is);
        } catch (IOException e) {
            throw new SQLException("Erro ao carregar db.properties: "
                + e.getMessage());
        }
        return props;
    }

    /** Fecha a conexão aberta, se houver. */
    public static void fechar() {
        if (instancia != null) {
            try {
                if (!instancia.isClosed()) {
                    instancia.close();
                }
            } catch (SQLException e) {
                System.err.println("Erro ao fechar conexão: " + e.getMessage());
            } finally {
                instancia = null;
            }
        }
    }
}
