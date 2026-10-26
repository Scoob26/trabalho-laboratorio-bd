package db;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Gerencia conexões com o banco de dados MySQL.
 *
 * ARQUITETURA DE CONEXÕES (B5 — controle de acesso real):
 *
 * Após o login, ConexaoDB mantém duas conexões:
 *   1. instanciaPerfil — conexão com o usuário MySQL do perfil autenticado
 *      (cinema_atendente / cinema_gerente / cinema_auditor), com os GRANTs
 *      corretos. É a conexão principal retornada por getConexao().
 *   2. instanciaAdmin — conexão root, usada APENAS para a autenticação do
 *      login (verificar Usuario_App) e operações que o perfil não tem acesso
 *      mas são necessárias internamente (ex: registrar último_acesso).
 *
 * Todos os DAOs chamam getConexao(), que retorna a conexão de perfil quando
 * disponível. Isso garante que o banco aplica os GRANTs corretos em tempo
 * de execução — um auditor não consegue fazer INSERT nem via DAO, pois
 * o MySQL recusa na conexão do perfil.
 */
public class ConexaoDB {

    /** Conexão administrativa (root) — apenas para autenticação e bootstrap. */
    private static Connection instanciaAdmin = null;

    /** Conexão do perfil MySQL autenticado — usada por todos os DAOs. */
    private static Connection instanciaPerfil = null;
    private static String     perfilAtual     = null;

    private ConexaoDB() {}

    // =========================================================================
    // MÉTODO PRINCIPAL — retornado por todos os DAOs
    // =========================================================================

    /**
     * Retorna a conexão ativa para uso pelos DAOs.
     *
     * PRIORIDADE: conexão de perfil (se disponível) > conexão admin.
     *
     * Isso garante que após o login, todas as operações dos DAOs usam
     * o usuário MySQL do perfil autenticado, com seus GRANTs específicos (B5).
     * Se o perfil não tiver permissão para a operação, o MySQL rejeita.
     */
    public static Connection getConexao() throws SQLException {
        // Após login: usa a conexão de perfil (tem GRANTs corretos)
        if (instanciaPerfil != null) {
            if (!instanciaPerfil.isClosed()) return instanciaPerfil;
            // Conexão fechou inesperadamente — tenta reabrir com o mesmo perfil
            if (perfilAtual != null) {
                instanciaPerfil = abrirConexao("db.usuario." + perfilAtual,
                                               "db.senha."   + perfilAtual);
                return instanciaPerfil;
            }
        }
        // Sem perfil ativo (antes do login): usa conexão admin
        return getConexaoAdmin();
    }

    // =========================================================================
    // CONEXÃO ADMINISTRATIVA — apenas para login e operações internas
    // =========================================================================

    /**
     * Retorna a conexão administrativa (root).
     * Usar APENAS para autenticar o login e operações de bootstrap.
     * Os DAOs devem chamar getConexao(), não este método.
     */
    public static Connection getConexaoAdmin() throws SQLException {
        if (instanciaAdmin == null || instanciaAdmin.isClosed()) {
            instanciaAdmin = abrirConexao("db.usuario", "db.senha");
        }
        return instanciaAdmin;
    }

    // =========================================================================
    // ABERTURA DE CONEXÃO DE PERFIL (chamado pelo login)
    // =========================================================================

    /**
     * Abre uma conexão com o usuário MySQL do perfil autenticado.
     * Chamado por TelaLogin após autenticação bem-sucedida.
     *
     * @param perfil "atendente" | "gerente" | "auditor"
     */
    public static Connection abrirConexaoPerfil(String perfil) throws SQLException {
        fecharPerfil();
        instanciaPerfil = abrirConexao("db.usuario." + perfil, "db.senha." + perfil);
        perfilAtual     = perfil;
        return instanciaPerfil;
    }

    // =========================================================================
    // ABERTURA INTERNA
    // =========================================================================

    private static Connection abrirConexao(String chaveUsuario, String chaveSenha)
            throws SQLException {
        Properties props = carregarPropriedades();
        String url     = props.getProperty("db.url");
        String usuario = props.getProperty(chaveUsuario);
        String senha   = props.getProperty(chaveSenha);

        if (url == null) {
            throw new SQLException("db.url não definido em db.properties.");
        }
        // Fallback: se as chaves de perfil não existirem, usa o admin
        if (usuario == null) usuario = props.getProperty("db.usuario");
        if (senha   == null) senha   = props.getProperty("db.senha");

        if (usuario == null || senha == null) {
            throw new SQLException(
                "Credenciais não encontradas para [" + chaveUsuario +
                "]. Verifique src/db/db.properties.");
        }
        return DriverManager.getConnection(url, usuario, senha);
    }

    private static Properties carregarPropriedades() throws SQLException {
        Properties props = new Properties();
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

    // =========================================================================
    // FECHAMENTO
    // =========================================================================

    /** Fecha a conexão de perfil (chamado no logout). */
    public static void fecharPerfil() {
        fecharConexao(instanciaPerfil);
        instanciaPerfil = null;
        perfilAtual     = null;
    }

    /** Fecha todas as conexões (chamado ao encerrar o app). */
    public static void fecharTudo() {
        fecharConexao(instanciaPerfil);
        instanciaPerfil = null;
        perfilAtual     = null;
        fecharConexao(instanciaAdmin);
        instanciaAdmin  = null;
    }

    private static void fecharConexao(Connection con) {
        if (con != null) {
            try { if (!con.isClosed()) con.close(); }
            catch (SQLException e) {
                System.err.println("Erro ao fechar conexão: " + e.getMessage());
            }
        }
    }
}
