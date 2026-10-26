# 🎬 Sistema de Gerenciamento de Cinema

**Universidade Católica de Brasília — Bacharelado em Engenharia de Software**  
**Disciplina:** Laboratório de Banco de Dados — GPE17M40083  
**Professor:** Samuel Novais Moura Júnior  
**Semestre:** 2026/2

---

## 📋 Tema

**Cinema** — Sistema completo de gerenciamento de um complexo cinematográfico, cobrindo o cadastro de filmes, classificação etária, distribuidoras, salas, sessões, ingressos, clientes, funcionários e promoções.

---

## 👥 Integrantes

| Nome | Matrícula | Papel |
|------|-----------|-------|
| Átila | — | — |

---

## 🗂️ Estrutura do Repositório

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

> **Nota:** o arquivo `src/db/db.properties` contém a senha do banco local e está listado no `.gitignore`. Use `db.properties.exemplo` como referência para criar o seu.

---

## 🚀 Como executar o banco do zero

### Pré-requisitos
- MySQL 8.0 ou superior
- Cliente MySQL (CLI, MySQL Workbench ou DBeaver)
- Java 17+ e JavaFX SDK 17+ e driver JDBC `mysql-connector-j` no classpath

### Passos — banco (Etapa 1 + Etapa 2)

```bash
# 1. Etapa 1: DDL + Carga + Consultas
mysql -u root -p < sql/01_ddl.sql
mysql -u root -p cinema_db < sql/02_carga.sql
mysql -u root -p cinema_db < sql/03_consultas.sql

# 2. Etapa 2: Segurança, Auditoria, Otimização, Transações, Projeto Físico
mysql -u root -p cinema_db < sql/04_etapa2_seguranca.sql
mysql -u root -p cinema_db < sql/05_etapa2_auditoria.sql
mysql -u root -p cinema_db < sql/06_etapa2_otimizacao.sql
mysql -u root -p cinema_db < sql/08_etapa2_projeto_fisico.sql

# 3. Usuários de demonstração (login da interface)
mysql -u root -p cinema_db < sql/09_etapa2_usuarios_demo.sql

# OBS: 07_etapa2_transacoes.sql contém cenários de teste manuais — executar
# interativamente para observar o comportamento transacional.
```

### Passos — aplicação JavaFX (Etapa 2)

```bash
# 1. Copie o template de configuração
cp src/db/db.properties.exemplo src/db/db.properties
# Edite db.properties com suas credenciais locais

# 2. Compile com JavaFX no modulepath
javac --module-path /caminho/javafx-sdk/lib \
      --add-modules javafx.controls,javafx.fxml \
      -cp ".;mysql-connector-j.jar" -d out \
      src/ui/*.java src/model/*.java src/dao/*.java src/db/*.java

# 3. Execute
java --module-path /caminho/javafx-sdk/lib \
     --add-modules javafx.controls,javafx.fxml \
     -cp "out;mysql-connector-j.jar" ui.App
```

### Logins de demonstração

| Login | Senha | Perfil |
|---|---|---|
| `atendente01` | `Ate2026` | Bilheteria — vende ingressos, gerencia clientes |
| `gerente01` | `Ger2026` | Gestão completa — sessões, filmes, salas, relatórios |
| `auditor01` | `Aud2026` | Somente leitura — logs de auditoria |

---

## 🗄️ Entidades principais do modelo

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

## 📐 Principais decisões de modelagem

| Decisão | Estratégia |
|---------|-----------|
| Especialização `Funcionario` | Table-per-subclass (3 tabelas) — evita NULLs estruturais |
| Entidade fraca `Ingresso` | PK composta `(id_sessao, numero_assento)` com `ON DELETE CASCADE` |
| Sobreposição de sessões (RN09) | Verificada por transação na aplicação (`SessaoDAO`) |
| Capacidade da sala (RN10) | Enforçada por trigger `trg_verifica_capacidade` (BEFORE INSERT) |
| Histórico de status (RN11) | Tabela `Historico_Status_Sessao` + trigger `trg_registra_historico_sessao` |
| Desnorm. `Sessao.data_hora_fim` | Armazenado para evitar join na verificação de sobreposição |
| Desnorm. `Ingresso.valor_final` | Snapshot no momento da venda para auditoria financeira |

---

## 🔧 Uso de IA

Este projeto utilizou assistente de inteligência artificial (Kiro / Claude — Anthropic) como apoio na estruturação do DDL, geração dos dados de carga, esboço dos DAOs e formatação dos documentos.

Todas as decisões de modelagem, regras de negócio e consultas foram verificadas e validadas pela equipe. Qualquer integrante é capaz de explicar e defender cada parte do trabalho.
