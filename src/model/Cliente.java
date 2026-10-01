package model;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Entidade Cliente — corresponde à tabela Cliente no banco.
 * RN16: CPF único, 11 dígitos. RN17: pontos de fidelidade acumulados.
 */
public class Cliente {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private int       id;
    private String    nome;
    private String    cpf;
    private LocalDate dataNascimento;
    private String    email;
    private String    telefone;          // nullable
    private int       pontosFidelidade;
    private LocalDate dataCadastro;

    public Cliente() {}

    public Cliente(String nome, String cpf, LocalDate dataNascimento,
                   String email, String telefone) {
        this.nome            = nome;
        this.cpf             = cpf;
        this.dataNascimento  = dataNascimento;
        this.email           = email;
        this.telefone        = telefone;
        this.pontosFidelidade = 0;
        this.dataCadastro    = LocalDate.now();
    }

    /** Exibe o cliente de forma resumida no console. */
    public void exibir() {
        System.out.printf(
            "ID: %-4d | %-30s | CPF: %s | %-30s | Tel: %-15s | Pontos: %d%n",
            id,
            nome,
            cpf,
            email,
            telefone != null ? telefone : "—",
            pontosFidelidade
        );
    }

    // ---- getters e setters -------------------------------------------------
    public int       getId()                        { return id; }
    public void      setId(int id)                  { this.id = id; }

    public String    getNome()                      { return nome; }
    public void      setNome(String nome)           { this.nome = nome; }

    public String    getCpf()                       { return cpf; }
    public void      setCpf(String cpf)             { this.cpf = cpf; }

    public LocalDate getDataNascimento()            { return dataNascimento; }
    public void      setDataNascimento(LocalDate d) { this.dataNascimento = d; }

    public String    getEmail()                     { return email; }
    public void      setEmail(String email)         { this.email = email; }

    public String    getTelefone()                  { return telefone; }
    public void      setTelefone(String telefone)   { this.telefone = telefone; }

    public int       getPontosFidelidade()          { return pontosFidelidade; }
    public void      setPontosFidelidade(int p)     { this.pontosFidelidade = p; }

    public LocalDate getDataCadastro()              { return dataCadastro; }
    public void      setDataCadastro(LocalDate d)   { this.dataCadastro = d; }
}
