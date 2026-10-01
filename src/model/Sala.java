package model;

/**
 * Entidade Sala — corresponde à tabela Sala no banco.
 */
public class Sala {

    private int    id;
    private int    numero;
    private int    capacidade;
    private String tipo;    // 2D, 3D, IMAX, 4DX
    private String estado;  // Ativa, Em Manutenção, Inativa

    public Sala() {}

    public Sala(int id, int numero, int capacidade, String tipo, String estado) {
        this.id         = id;
        this.numero     = numero;
        this.capacidade = capacidade;
        this.tipo       = tipo;
        this.estado     = estado;
    }

    public void exibir() {
        System.out.printf(
            "ID: %-4d | Sala %-3d | %-4s | %3d assentos | %s%n",
            id, numero, tipo, capacidade, estado
        );
    }

    // ---- getters e setters -------------------------------------------------
    public int    getId()              { return id; }
    public void   setId(int id)        { this.id = id; }

    public int    getNumero()          { return numero; }
    public void   setNumero(int n)     { this.numero = n; }

    public int    getCapacidade()      { return capacidade; }
    public void   setCapacidade(int c) { this.capacidade = c; }

    public String getTipo()            { return tipo; }
    public void   setTipo(String t)    { this.tipo = t; }

    public String getEstado()          { return estado; }
    public void   setEstado(String e)  { this.estado = e; }
}
