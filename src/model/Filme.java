package model;

import java.time.LocalDate;

/**
 * Entidade Filme — corresponde à tabela Filme no banco.
 * Estende a classe base Entidade do projeto original.
 */
public class Filme {

    private int       id;
    private String    titulo;
    private String    tituloNacional;
    private int       duracaoMin;
    private String    classificacaoEtaria;  // Livre, 10, 12, 14, 16, 18
    private String    sinopse;
    private LocalDate dataLancamento;
    private boolean   ativo;
    private int       idDistribuidora;
    private String    nomeDistribuidora;    // campo de join, não persistido diretamente

    public Filme() {}

    public Filme(int id, String titulo, String classificacaoEtaria,
                 int duracaoMin, int idDistribuidora) {
        this.id                  = id;
        this.titulo              = titulo;
        this.classificacaoEtaria = classificacaoEtaria;
        this.duracaoMin          = duracaoMin;
        this.idDistribuidora     = idDistribuidora;
        this.ativo               = true;
    }

    /** Exibe o filme de forma resumida no console. */
    public void exibir() {
        System.out.printf(
            "ID: %-4d | %-40s | %s | %3d min | %-10s | %s%n",
            id,
            titulo,
            classificacaoEtaria,
            duracaoMin,
            ativo ? "Ativo" : "Inativo",
            nomeDistribuidora != null ? nomeDistribuidora : ""
        );
    }

    // ---- getters e setters -------------------------------------------------
    public int       getId()                   { return id; }
    public void      setId(int id)             { this.id = id; }

    public String    getTitulo()               { return titulo; }
    public void      setTitulo(String t)       { this.titulo = t; }

    public String    getTituloNacional()       { return tituloNacional; }
    public void      setTituloNacional(String t){ this.tituloNacional = t; }

    public int       getDuracaoMin()           { return duracaoMin; }
    public void      setDuracaoMin(int d)      { this.duracaoMin = d; }

    public String    getClassificacaoEtaria()  { return classificacaoEtaria; }
    public void      setClassificacaoEtaria(String c) { this.classificacaoEtaria = c; }

    public String    getSinopse()              { return sinopse; }
    public void      setSinopse(String s)      { this.sinopse = s; }

    public LocalDate getDataLancamento()       { return dataLancamento; }
    public void      setDataLancamento(LocalDate d) { this.dataLancamento = d; }

    public boolean   isAtivo()                 { return ativo; }
    public void      setAtivo(boolean a)       { this.ativo = a; }

    public int       getIdDistribuidora()      { return idDistribuidora; }
    public void      setIdDistribuidora(int i) { this.idDistribuidora = i; }

    public String    getNomeDistribuidora()    { return nomeDistribuidora; }
    public void      setNomeDistribuidora(String n) { this.nomeDistribuidora = n; }
}
