 Sistema de Gerenciamento de Cinema

Universidade Católica de Brasília   
Disciplina: Laboratório de Banco de Dados — GPE17M40083  
Professor: Samuel Novais Moura Júnior  




 Tema

Cinema — Sistema completo de gerenciamento de um complexo cinematográfico, cobrindo o cadastro de filmes, classificação etária, distribuidoras, salas, sessões, ingressos, clientes, funcionários e promoções.



 Integrantes

| Nome | Matrícula | Papel |
|------|-----------|-------|
| Átila | — | — |



 Estrutura do Repositório


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


> Nota: o arquivo `src/db/db.properties` contém a senha do banco local e está listado no `.gitignore`. Use `db.properties.exemplo` como referência para criar o seu.












Este projeto utilizou assistente de inteligência artificial 


