package model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Entidade Sessao — corresponde à tabela Sessao no banco.
 * Inclui campos de join (titulo_filme, numero_sala, etc.) para exibição.
 */
public class Sessao {

    private static final DateTimeFormatter FMT =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private int           id;
    private LocalDateTime dataHoraInicio;
    private LocalDateTime dataHoraFim;
    private String        idioma;
    private double        valorIngressoBase;
    private String        status;

    // FKs
    private int    idFilme;
    private int    idSala;

    // Campos de join (lidos do banco, não persistidos diretamente)
    private String tituloFilme;
    private int    numeroSala;
    private String tipoSala;
    private int    capacidadeSala;
    private int    ingressosVendidos;

    public Sessao() {}

    public void exibir() {
        System.out.printf(
            "ID: %-4d | %-35s | Sala %-3d (%s) | %s → %s | %s | R$ %,.2f | %d/%d ingressos%n",
            id,
            tituloFilme != null ? tituloFilme : "ID " + idFilme,
            numeroSala,
            tipoSala != null ? tipoSala : "",
            dataHoraInicio != null ? dataHoraInicio.format(FMT) : "?",
            dataHoraFim    != null ? dataHoraFim.format(FMT)    : "?",
            idioma,
            valorIngressoBase,
            ingressosVendidos,
            capacidadeSala
        );
    }

    // ---- getters e setters -------------------------------------------------
    public int           getId()                    { return id; }
    public void          setId(int id)              { this.id = id; }

    public LocalDateTime getDataHoraInicio()        { return dataHoraInicio; }
    public void          setDataHoraInicio(LocalDateTime d) { this.dataHoraInicio = d; }

    public LocalDateTime getDataHoraFim()           { return dataHoraFim; }
    public void          setDataHoraFim(LocalDateTime d)    { this.dataHoraFim = d; }

    public String        getIdioma()                { return idioma; }
    public void          setIdioma(String i)        { this.idioma = i; }

    public double        getValorIngressoBase()     { return valorIngressoBase; }
    public void          setValorIngressoBase(double v) { this.valorIngressoBase = v; }

    public String        getStatus()                { return status; }
    public void          setStatus(String s)        { this.status = s; }

    public int           getIdFilme()               { return idFilme; }
    public void          setIdFilme(int i)          { this.idFilme = i; }

    public int           getIdSala()                { return idSala; }
    public void          setIdSala(int i)           { this.idSala = i; }

    public String        getTituloFilme()           { return tituloFilme; }
    public void          setTituloFilme(String t)   { this.tituloFilme = t; }

    public int           getNumeroSala()            { return numeroSala; }
    public void          setNumeroSala(int n)       { this.numeroSala = n; }

    public String        getTipoSala()              { return tipoSala; }
    public void          setTipoSala(String t)      { this.tipoSala = t; }

    public int           getCapacidadeSala()        { return capacidadeSala; }
    public void          setCapacidadeSala(int c)   { this.capacidadeSala = c; }

    public int           getIngressosVendidos()     { return ingressosVendidos; }
    public void          setIngressosVendidos(int i){ this.ingressosVendidos = i; }
}
