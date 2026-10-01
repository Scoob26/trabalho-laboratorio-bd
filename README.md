 Sistema de Gerenciamento de Cinema

Universidade Católica de Brasília 
Disciplina: Laboratório de Banco de Dados  
Professor: Samuel Novais Moura Júnior  


---

 Tema

Cinema — Sistema completo de gerenciamento de um complexo cinematográfico, cobrindo o cadastro de filmes, classificação etária, distribuidoras, salas, sessões, ingressos, clientes, funcionários e promoções.

---

 Integrantes

| Nome | Matrícula
|------|-----------
| Átila | UC25200771

---

 Estrutura do Repositório

```
.
├── README.md                       ← visão geral, tema e integrantes
├── docs/
│   ├── A1-escopo-regras.md         ← escopo do domínio e 24 regras de negócio
│   ├── A3-dicionario-dados.md      ← dicionário de dados conceitual (14 entidades)
│   ├── A4-modelo-logico.md         ← modelo lógico relacional + decisões de mapeamento
│   ├── A5-normalizacao.md          ← verificação de normalização (3FN / FNBC)
│   └── relatorio-etapa1.md         ← relatório consolidado (A1–A5)
├── sql/
│   ├── 01_ddl.sql                  ← script físico DDL (CREATE TABLE, constraints, triggers, índices)
│   ├── 02_carga.sql                ← script de carga DML (≥ 40 registros nas tabelas principais)
│   └── 03_consultas.sql            ← 15 consultas comentadas (básicas, junções, avançadas)
└── src/
    ├── Main.java                   ← ponto de entrada — menu console com CRUD completo
    ├── model/
    │   ├── Filme.java
    │   ├── Sala.java
    │   └── Sessao.java
    ├── dao/
    │   ├── FilmeDAO.java
    │   ├── SalaDAO.java
    │   └── SessaoDAO.java          ← transação explícita (RN09 + RN11)
    └── db/
        ├── ConexaoDB.java          ← singleton de conexão MySQL
        ├── db.properties           ← credenciais locais (não versionado — ver .gitignore)
        └── db.properties.exemplo   ← template com as chaves necessárias
```

> Nota: o arquivo `src/db/db.properties` contém a senha do banco local e está listado no `.gitignore`. Use `db.properties.exemplo` como referência para criar o seu.

---


 Entidades principais do modelo

| Entidade | Tipo | Descrição |
|----------|------|-----------|
| `Distribuidora` | Forte | Empresa distribuidora dos filmes |
| `Genero` | Forte + autorrelac. | Gênero cinematográfico com hierarquia de subgêneros |
| `Filme` | Forte | Obra cadastrada no sistema |
| `Filme_Genero` | Associativa N:N | Relação filme–gênero com atributo `genero_principal` |
| `Sala` | Forte | Sala física do complexo |
| `Sessao` | Forte | Exibição de um filme em uma sala em data/hora específica |
| `Historico_Status_Sessao` | Forte (temporal) | Registro datado de cada mudança de status de sessão |
| `Ingresso` | **Fraca** de Sessao | Ingresso emitido; PK composta `(id_sessao, numero_assento)` |
| `Cliente` | Forte | Pessoa cadastrada no programa de fidelidade |
| `Funcionario` | Forte (superentidade) | Funcionário do cinema (autorrelacionamento hierárquico) |
| `Atendente` | Especialização | Funcionário da bilheteria (table-per-subclass) |
| `Gerente` | Especialização | Funcionário com poder de gestão (table-per-subclass) |
| `Promocao` | Forte | Desconto percentual com período de vigência |
| `Avaliacao` | Associativa N:N | Avaliação de filme por cliente com nota, comentário e data |

---

 Principais decisões de modelagem

| Decisão | Estratégia |
|---------|-----------|
| Especialização `Funcionario` | Table-per-subclass (3 tabelas) — evita NULLs estruturais |
| Entidade fraca `Ingresso` | PK composta `(id_sessao, numero_assento)` com `ON DELETE CASCADE` |
| Sobreposição de sessões (RN09) | Verificada por transação na aplicação (`SessaoDAO`) |
| Capacidade da sala (RN10) | Enforçada por trigger `trg_verifica_capacidade` (BEFORE INSERT) |
| Histórico de status (RN11) | Tabela `Historico_Status_Sessao` + trigger `trg_registra_historico_sessao` |
| Desnorm. `Sessao.data_hora_fim` | Armazenado para evitar join na verificação de sobreposição |
| Desnorm. `Ingresso.valor_final` | Snapshot no momento da venda para auditoria financeira |



