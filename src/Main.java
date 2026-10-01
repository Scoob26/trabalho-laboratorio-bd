import dao.ClienteDAO;
import dao.FilmeDAO;
import dao.SalaDAO;
import dao.SessaoDAO;
import db.ConexaoDB;
import model.Cliente;
import model.Filme;
import model.Sala;
import model.Sessao;

import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.InputMismatchException;
import java.util.List;
import java.util.Scanner;

/**
 * Ponto de entrada do Sistema de Cinema.
 * Menu console com CRUD completo de Filmes, Salas, Sessões e Clientes,
 * consultas parametrizadas e relatório alimentado por VIEW.
 * Todos os acessos ao banco passam por DAOs com PreparedStatement (B2).
 */
public class Main {

    private static final DateTimeFormatter FMT_DATA =
            DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter FMT_DT =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private static final FilmeDAO   filmeDAO   = new FilmeDAO();
    private static final SalaDAO    salaDAO    = new SalaDAO();
    private static final SessaoDAO  sessaoDAO  = new SessaoDAO();
    private static final ClienteDAO clienteDAO = new ClienteDAO();

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        int op = -1;

        System.out.println("╔══════════════════════════════════════╗");
        System.out.println("║   SISTEMA DE GERENCIAMENTO DE CINEMA  ║");
        System.out.println("╚══════════════════════════════════════╝");

        try {
            ConexaoDB.getConexao();
            System.out.println("✔ Conexão com o banco estabelecida.\n");
        } catch (SQLException e) {
            System.err.println("✘ Erro ao conectar ao banco: " + e.getMessage());
            System.err.println("  Verifique src/db/db.properties.");
            return;
        }

        do {
            System.out.println("\n=== MENU PRINCIPAL ===");
            System.out.println("--- Filmes ---");
            System.out.println(" 1 - Cadastrar Filme");
            System.out.println(" 2 - Listar Filmes Ativos");
            System.out.println(" 3 - Buscar Filme por ID");
            System.out.println(" 4 - Buscar Filme por Título");
            System.out.println(" 5 - Atualizar Filme");
            System.out.println(" 6 - Desativar Filme");
            System.out.println("--- Salas ---");
            System.out.println(" 7 - Cadastrar Sala");
            System.out.println(" 8 - Listar Salas");
            System.out.println(" 9 - Buscar Sala por ID");
            System.out.println("10 - Atualizar Sala");
            System.out.println("11 - Excluir Sala");
            System.out.println("--- Sessões ---");
            System.out.println("12 - Criar Sessão");
            System.out.println("13 - Listar Sessões Agendadas");
            System.out.println("14 - Buscar Sessão por ID");
            System.out.println("15 - Atualizar Status da Sessão");
            System.out.println("--- Clientes ---");
            System.out.println("16 - Cadastrar Cliente");
            System.out.println("17 - Listar Clientes");
            System.out.println("18 - Buscar Cliente por ID");
            System.out.println("19 - Buscar Cliente por CPF");
            System.out.println("20 - Buscar Clientes por Nome");
            System.out.println("21 - Atualizar Cliente");
            System.out.println("22 - Excluir Cliente");
            System.out.println("--- Consultas e Relatórios ---");
            System.out.println("23 - Consultar Sessões por Filme (filtro parametrizado)");
            System.out.println("24 - Relatório de Fidelidade de Clientes (VIEW)");
            System.out.println("---");
            System.out.println(" 0 - Sair");
            System.out.print("Opção: ");

            try {
                op = sc.nextInt();
                sc.nextLine();
            } catch (InputMismatchException e) {
                System.out.println("⚠ Entrada inválida. Digite um número.");
                sc.nextLine();
                continue;
            }

            try {
                switch (op) {
                    // ===================== FILMES =====================
                    case 1  -> cadastrarFilme(sc);
                    case 2  -> listarFilmes();
                    case 3  -> buscarFilmePorId(sc);
                    case 4  -> buscarFilmePorTitulo(sc);
                    case 5  -> atualizarFilme(sc);
                    case 6  -> desativarFilme(sc);
                    // ===================== SALAS ======================
                    case 7  -> cadastrarSala(sc);
                    case 8  -> listarSalas();
                    case 9  -> buscarSalaPorId(sc);
                    case 10 -> atualizarSala(sc);
                    case 11 -> excluirSala(sc);
                    // ===================== SESSÕES ====================
                    case 12 -> criarSessao(sc);
                    case 13 -> listarSessoesAgendadas();
                    case 14 -> buscarSessaoPorId(sc);
                    case 15 -> atualizarStatusSessao(sc);
                    // ===================== CLIENTES ===================
                    case 16 -> cadastrarCliente(sc);
                    case 17 -> listarClientes();
                    case 18 -> buscarClientePorId(sc);
                    case 19 -> buscarClientePorCpf(sc);
                    case 20 -> buscarClientesPorNome(sc);
                    case 21 -> atualizarCliente(sc);
                    case 22 -> excluirCliente(sc);
                    // ============ CONSULTAS E RELATÓRIOS ==============
                    case 23 -> consultarSessoesPorFilme(sc);
                    case 24 -> relatorioFidelidadeClientes();
                    case 0  -> System.out.println("Encerrando sistema...");
                    default -> System.out.println("Opção inválida.");
                }
            } catch (SQLException e) {
                System.out.println("\n✘ Erro de banco de dados: " + traduzirErro(e));
            }

        } while (op != 0);

        ConexaoDB.fechar();
        sc.close();
    }

    // =========================================================================
    // FILMES
    // =========================================================================

    private static void cadastrarFilme(Scanner sc) throws SQLException {
        System.out.println("\n--- Cadastrar Filme ---");
        System.out.print("Título original: ");
        String titulo = sc.nextLine().trim();

        System.out.print("Título nacional (Enter para igual): ");
        String tituloNac = sc.nextLine().trim();
        if (tituloNac.isEmpty()) tituloNac = null;

        int duracao = lerInteiro(sc, "Duração (minutos): ");
        System.out.print("Classificação etária (Livre/10/12/14/16/18): ");
        String classif = sc.nextLine().trim();

        System.out.print("Sinopse (Enter para omitir): ");
        String sinopse = sc.nextLine().trim();
        if (sinopse.isEmpty()) sinopse = null;

        LocalDate lancamento = lerData(sc, "Data de lançamento (dd/MM/yyyy): ");
        int idDist = lerInteiro(sc, "ID da Distribuidora: ");

        Filme f = new Filme();
        f.setTitulo(titulo);
        f.setTituloNacional(tituloNac);
        f.setDuracaoMin(duracao);
        f.setClassificacaoEtaria(classif);
        f.setSinopse(sinopse);
        f.setDataLancamento(lancamento);
        f.setAtivo(true);
        f.setIdDistribuidora(idDist);

        filmeDAO.inserir(f);
        System.out.println("✔ Filme cadastrado com ID " + f.getId());
    }

    private static void listarFilmes() throws SQLException {
        System.out.println("\n--- Filmes Ativos ---");
        List<Filme> lista = filmeDAO.listarAtivos();
        if (lista.isEmpty()) {
            System.out.println("Nenhum filme ativo cadastrado.");
            return;
        }
        lista.forEach(Filme::exibir);
        System.out.println("Total: " + lista.size() + " filme(s).");
    }

    private static void buscarFilmePorId(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID do Filme: ");
        Filme f = filmeDAO.buscarPorId(id);
        if (f != null) f.exibir();
        else System.out.println("Filme não encontrado.");
    }

    private static void buscarFilmePorTitulo(Scanner sc) throws SQLException {
        System.out.print("Fragmento do título: ");
        String frag = sc.nextLine().trim();
        List<Filme> lista = filmeDAO.buscarPorTitulo(frag);
        if (lista.isEmpty()) System.out.println("Nenhum filme encontrado.");
        else lista.forEach(Filme::exibir);
    }

    private static void atualizarFilme(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID do Filme a atualizar: ");
        Filme f = filmeDAO.buscarPorId(id);
        if (f == null) { System.out.println("Filme não encontrado."); return; }

        f.exibir();
        System.out.print("Novo título (Enter para manter): ");
        String t = sc.nextLine().trim();
        if (!t.isEmpty()) f.setTitulo(t);

        System.out.print("Nova classificação etária (Enter para manter): ");
        String c = sc.nextLine().trim();
        if (!c.isEmpty()) f.setClassificacaoEtaria(c);

        boolean ok = filmeDAO.atualizar(f);
        System.out.println(ok ? "✔ Filme atualizado." : "✘ Nenhum registro alterado.");
    }

    private static void desativarFilme(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID do Filme a desativar: ");
        boolean ok = filmeDAO.desativar(id);
        System.out.println(ok ? "✔ Filme desativado." : "✘ Filme não encontrado.");
    }

    // =========================================================================
    // SALAS
    // =========================================================================

    private static void cadastrarSala(Scanner sc) throws SQLException {
        System.out.println("\n--- Cadastrar Sala ---");
        int numero     = lerInteiro(sc, "Número da sala: ");
        int capacidade = lerInteiro(sc, "Capacidade de assentos: ");
        System.out.print("Tipo (2D/3D/IMAX/4DX): ");
        String tipo   = sc.nextLine().trim();
        System.out.print("Estado (Ativa/Em Manutenção/Inativa): ");
        String estado = sc.nextLine().trim();

        Sala s = new Sala(0, numero, capacidade, tipo, estado);
        salaDAO.inserir(s);
        System.out.println("✔ Sala cadastrada com ID " + s.getId());
    }

    private static void listarSalas() throws SQLException {
        System.out.println("\n--- Salas ---");
        List<Sala> lista = salaDAO.listarTodas();
        if (lista.isEmpty()) System.out.println("Nenhuma sala cadastrada.");
        else lista.forEach(Sala::exibir);
    }

    private static void buscarSalaPorId(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID da Sala: ");
        Sala s = salaDAO.buscarPorId(id);
        if (s != null) s.exibir();
        else System.out.println("Sala não encontrada.");
    }

    private static void atualizarSala(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID da Sala a atualizar: ");
        Sala s = salaDAO.buscarPorId(id);
        if (s == null) { System.out.println("Sala não encontrada."); return; }

        s.exibir();
        System.out.print("Novo estado (Ativa/Em Manutenção/Inativa) [Enter para manter]: ");
        String estado = sc.nextLine().trim();
        if (!estado.isEmpty()) s.setEstado(estado);

        System.out.print("Nova capacidade (0 para manter): ");
        int cap = lerInteiro(sc, "");
        if (cap > 0) s.setCapacidade(cap);

        boolean ok = salaDAO.atualizar(s);
        System.out.println(ok ? "✔ Sala atualizada." : "✘ Nenhum registro alterado.");
    }

    private static void excluirSala(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID da Sala a excluir: ");
        boolean ok = salaDAO.excluir(id);
        System.out.println(ok ? "✔ Sala excluída." : "✘ Sala não encontrada ou possui sessões.");
    }

    // =========================================================================
    // SESSÕES
    // =========================================================================

    private static void criarSessao(Scanner sc) throws SQLException {
        System.out.println("\n--- Criar Sessão ---");
        listarFilmes();
        int idFilme = lerInteiro(sc, "ID do Filme: ");

        listarSalas();
        int idSala = lerInteiro(sc, "ID da Sala: ");

        LocalDateTime inicio = lerDataHora(sc, "Data/hora de início (dd/MM/yyyy HH:mm): ");
        LocalDateTime fim    = lerDataHora(sc, "Data/hora de fim    (dd/MM/yyyy HH:mm): ");

        System.out.print("Idioma (ex: Português / Inglês Legendado): ");
        String idioma = sc.nextLine().trim();

        double valor = lerDouble(sc, "Valor do ingresso base (R$): ");

        Sessao s = new Sessao();
        s.setIdFilme(idFilme);
        s.setIdSala(idSala);
        s.setDataHoraInicio(inicio);
        s.setDataHoraFim(fim);
        s.setIdioma(idioma);
        s.setValorIngressoBase(valor);

        sessaoDAO.inserir(s);
        System.out.println("✔ Sessão criada com ID " + s.getId());
    }

    private static void listarSessoesAgendadas() throws SQLException {
        System.out.println("\n--- Sessões Agendadas ---");
        List<Sessao> lista = sessaoDAO.listarAgendadas();
        if (lista.isEmpty()) System.out.println("Nenhuma sessão agendada.");
        else lista.forEach(Sessao::exibir);
    }

    private static void buscarSessaoPorId(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID da Sessão: ");
        Sessao s = sessaoDAO.buscarPorId(id);
        if (s != null) s.exibir();
        else System.out.println("Sessão não encontrada.");
    }

    private static void atualizarStatusSessao(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID da Sessão: ");
        System.out.print("Novo status (Agendada/Em Exibição/Encerrada/Cancelada): ");
        String novoStatus = sc.nextLine().trim();
        int idFunc = lerInteiro(sc, "ID do Funcionário responsável (0 para automático): ");
        sessaoDAO.atualizarStatus(id, novoStatus, idFunc == 0 ? null : idFunc);
        System.out.println("✔ Status atualizado e histórico registrado.");
    }

    // =========================================================================
    // CLIENTES
    // =========================================================================

    private static void cadastrarCliente(Scanner sc) throws SQLException {
        System.out.println("\n--- Cadastrar Cliente ---");
        System.out.print("Nome completo: ");
        String nome = sc.nextLine().trim();

        System.out.print("CPF (11 dígitos, só números): ");
        String cpf = sc.nextLine().trim();

        LocalDate nascimento = lerData(sc, "Data de nascimento (dd/MM/yyyy): ");

        System.out.print("E-mail: ");
        String email = sc.nextLine().trim();

        System.out.print("Telefone (Enter para omitir): ");
        String tel = sc.nextLine().trim();
        if (tel.isEmpty()) tel = null;

        Cliente c = new Cliente(nome, cpf, nascimento, email, tel);
        clienteDAO.inserir(c);
        System.out.println("✔ Cliente cadastrado com ID " + c.getId());
    }

    private static void listarClientes() throws SQLException {
        System.out.println("\n--- Clientes ---");
        List<Cliente> lista = clienteDAO.listarTodos();
        if (lista.isEmpty()) System.out.println("Nenhum cliente cadastrado.");
        else {
            lista.forEach(Cliente::exibir);
            System.out.println("Total: " + lista.size() + " cliente(s).");
        }
    }

    private static void buscarClientePorId(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID do Cliente: ");
        Cliente c = clienteDAO.buscarPorId(id);
        if (c != null) c.exibir();
        else System.out.println("Cliente não encontrado.");
    }

    private static void buscarClientePorCpf(Scanner sc) throws SQLException {
        System.out.print("CPF (11 dígitos): ");
        String cpf = sc.nextLine().trim();
        Cliente c = clienteDAO.buscarPorCpf(cpf);
        if (c != null) c.exibir();
        else System.out.println("Cliente não encontrado.");
    }

    private static void buscarClientesPorNome(Scanner sc) throws SQLException {
        System.out.print("Fragmento do nome: ");
        String frag = sc.nextLine().trim();
        List<Cliente> lista = clienteDAO.buscarPorNome(frag);
        if (lista.isEmpty()) System.out.println("Nenhum cliente encontrado.");
        else lista.forEach(Cliente::exibir);
    }

    private static void atualizarCliente(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID do Cliente a atualizar: ");
        Cliente c = clienteDAO.buscarPorId(id);
        if (c == null) { System.out.println("Cliente não encontrado."); return; }

        c.exibir();
        System.out.print("Novo nome (Enter para manter): ");
        String nome = sc.nextLine().trim();
        if (!nome.isEmpty()) c.setNome(nome);

        System.out.print("Novo e-mail (Enter para manter): ");
        String email = sc.nextLine().trim();
        if (!email.isEmpty()) c.setEmail(email);

        System.out.print("Novo telefone (Enter para manter): ");
        String tel = sc.nextLine().trim();
        if (!tel.isEmpty()) c.setTelefone(tel);

        boolean ok = clienteDAO.atualizar(c);
        System.out.println(ok ? "✔ Cliente atualizado." : "✘ Nenhum registro alterado.");
    }

    private static void excluirCliente(Scanner sc) throws SQLException {
        int id = lerInteiro(sc, "ID do Cliente a excluir: ");
        System.out.print("Confirma exclusão? (s/N): ");
        String conf = sc.nextLine().trim();
        if (!conf.equalsIgnoreCase("s")) {
            System.out.println("Operação cancelada.");
            return;
        }
        boolean ok = clienteDAO.excluir(id);
        System.out.println(ok ? "✔ Cliente excluído." : "✘ Cliente não encontrado ou possui ingressos.");
    }

    // =========================================================================
    // CONSULTAS PARAMETRIZADAS E RELATÓRIOS
    // =========================================================================

    /**
     * Consulta parametrizada: sessões de um filme específico, com filtro
     * opcional de status. Demonstra PreparedStatement com parâmetro de busca (B2).
     */
    private static void consultarSessoesPorFilme(Scanner sc) throws SQLException {
        System.out.println("\n--- Consultar Sessões por Filme ---");
        listarFilmes();
        int idFilme = lerInteiro(sc, "ID do Filme: ");

        System.out.print("Filtrar por status (Agendada/Em Exibição/Encerrada/Cancelada — Enter para todos): ");
        String status = sc.nextLine().trim();

        List<Sessao> lista = sessaoDAO.buscarPorFilme(idFilme,
                status.isEmpty() ? null : status);

        if (lista.isEmpty()) {
            System.out.println("Nenhuma sessão encontrada com esses critérios.");
        } else {
            System.out.println("\nSessões encontradas: " + lista.size());
            lista.forEach(Sessao::exibir);
        }
    }

    /**
     * Relatório alimentado pela view vw_fidelidade_clientes.
     * Demonstra o uso de VIEW como fonte de dados para a aplicação.
     */
    private static void relatorioFidelidadeClientes() throws SQLException {
        clienteDAO.exibirRelatorioFidelidade();
    }

    // =========================================================================
    // Utilitários de leitura
    // =========================================================================

    private static int lerInteiro(Scanner sc, String prompt) {
        while (true) {
            if (!prompt.isEmpty()) System.out.print(prompt);
            try {
                int v = sc.nextInt();
                sc.nextLine();
                return v;
            } catch (InputMismatchException e) {
                sc.nextLine();
                System.out.print("⚠ Valor inválido. " + prompt);
            }
        }
    }

    private static double lerDouble(Scanner sc, String prompt) {
        while (true) {
            System.out.print(prompt);
            try {
                double v = sc.nextDouble();
                sc.nextLine();
                return v;
            } catch (InputMismatchException e) {
                sc.nextLine();
                System.out.print("⚠ Valor inválido. ");
            }
        }
    }

    private static LocalDate lerData(Scanner sc, String prompt) {
        while (true) {
            System.out.print(prompt);
            try {
                return LocalDate.parse(sc.nextLine().trim(), FMT_DATA);
            } catch (DateTimeParseException e) {
                System.out.println("⚠ Formato inválido. Use dd/MM/yyyy.");
            }
        }
    }

    private static LocalDateTime lerDataHora(Scanner sc, String prompt) {
        while (true) {
            System.out.print(prompt);
            try {
                return LocalDateTime.parse(sc.nextLine().trim(), FMT_DT);
            } catch (DateTimeParseException e) {
                System.out.println("⚠ Formato inválido. Use dd/MM/yyyy HH:mm.");
            }
        }
    }

    // =========================================================================
    // Tradução de erros de restrição do banco para mensagens amigáveis (B1)
    // =========================================================================

    private static String traduzirErro(SQLException e) {
        String msg = e.getMessage();
        if (msg == null) return "Erro desconhecido.";

        // Unicidade
        if (msg.contains("uq_sala_numero"))
            return "Já existe uma sala com este número.";
        if (msg.contains("uq_cliente_cpf") || msg.contains("uq_funcionario_cpf"))
            return "CPF já cadastrado no sistema.";
        if (msg.contains("uq_cliente_email") || msg.contains("uq_funcionario_email"))
            return "E-mail já cadastrado no sistema.";
        if (msg.contains("uq_distribuidora_cnpj"))
            return "CNPJ já cadastrado no sistema.";

        // CHECK constraints
        if (msg.contains("ck_filme_duracao"))
            return "A duração do filme deve ser maior que zero.";
        if (msg.contains("ck_sala_capacidade"))
            return "A capacidade da sala deve ser maior que zero.";
        if (msg.contains("ck_promocao_desconto"))
            return "O percentual de desconto deve estar entre 1% e 100%.";
        if (msg.contains("ck_cliente_pontos"))
            return "Os pontos de fidelidade não podem ser negativos.";
        if (msg.contains("ck_cliente_cpf") || msg.contains("ck_funcionario_cpf"))
            return "CPF inválido: informe exatamente 11 dígitos numéricos.";
        if (msg.contains("ck_sessao_valor"))
            return "O valor do ingresso base deve ser maior que zero.";
        if (msg.contains("ck_sessao_horario"))
            return "O horário de fim da sessão deve ser posterior ao de início.";
        if (msg.contains("ck_avaliacao_nota"))
            return "A nota da avaliação deve ser entre 1 e 5.";

        // Triggers
        if (msg.contains("Capacidade da sala esgotada"))
            return msg; // já é mensagem amigável (trigger RN10)

        // Mensagens já traduzidas nos DAOs
        if (msg.contains("RN09") || msg.contains("RN07"))
            return msg;

        // Chaves estrangeiras
        if (msg.contains("a foreign key constraint") || msg.contains("foreign key"))
            return "Operação bloqueada: este registro está referenciado por outro dado. " +
                   "Remova as dependências antes de excluir.";

        // Valor de ENUM inválido
        if (msg.contains("ENUM") || msg.contains("Data truncated"))
            return "Valor inválido para o campo. Verifique as opções permitidas.";

        // Fallback: devolve a mensagem original do driver
        return msg;
    }
}
