# Relatório — Etapa 1
## Projeto Final: Do modelo conceitual à aplicação — Sistema de Cinema

**Universidade Católica de Brasília — Bacharelado em Engenharia de Software**  
**Disciplina:** Laboratório de Banco de Dados — GPE17M40083  
**Professor:** Samuel Novais Moura Júnior  
**Semestre:** 2026/2  

| Campo | Valor |
|-------|-------|
| Tema | Sistema de Gerenciamento de Cinema |
| SGBD | MySQL 8.0+ |
| Entrega Etapa 1 | 20/09/2026 |
| Apresentação | 21/09/2026 — aula 8 |

---

## Integrantes

| Nome | Papel |
|------|-------|
| Átila | — |

---

## Sumário

1. [Escopo e Regras de Negócio (A1)](#1-escopo-e-regras-de-negócio-a1)
2. [Modelo ER Conceitual (A2)](#2-modelo-er-conceitual-a2)
3. [Dicionário de Dados (A3)](#3-dicionário-de-dados-a3)
4. [Modelo Lógico Relacional (A4)](#4-modelo-lógico-relacional-a4)
5. [Verificação de Normalização (A5)](#5-verificação-de-normalização-a5)
6. [Declaração de Uso de IA](#6-declaração-de-uso-de-ia)

---

## 1. Escopo e Regras de Negócio (A1)

### 1.1 Descrição do Domínio

O sistema gerencia as operações de um complexo cinematográfico com múltiplas salas de exibição. O domínio abrange o cadastro e controle de filmes (com suas distribuidoras, gêneros e classificações etárias), o gerenciamento físico das salas, a programação de sessões, a venda e controle de ingressos, o cadastro de clientes do programa de fidelidade, o gerenciamento de funcionários (divididos em atendentes e gerentes) e a aplicação de promoções.

O cinema opera com sessões distribuídas ao longo do dia em diferentes salas. Cada sessão exibe um único filme em uma sala específica, com capacidade limitada pelo número de assentos disponíveis. Os ingressos são emitidos por sessão e vinculados a um cliente cadastrado ou vendidos de forma avulsa. Clientes fidelizados acumulam pontos a cada compra e podem utilizá-los para obter descontos. O sistema também registra avaliações dos filmes pelos clientes, formando um histórico datado de opiniões.

O complexo conta com funcionários que podem ocupar o papel de atendente (responsável pela bilheteria e pela venda de ingressos) ou gerente (responsável pela programação das sessões e pela gestão das salas). Um gerente pode supervisionar outros funcionários, caracterizando uma hierarquia interna.

### 1.2 Requisitos Mínimos de Complexidade — Atendimento

| Requisito | Mínimo | Como atendido |
|-----------|--------|---------------|
| Entidades | 8 | 10 entidades fortes: Distribuidora, Genero, Filme, Sala, Sessao, Historico_Status_Sessao, Cliente, Funcionario, Promocao, Ingresso |
| Relacionamentos N:N com atributo | 2 | `Filme_Genero` (atributo: `genero_principal`) e `Avaliacao` (atributos: `nota`, `comentario`, `data_avaliacao`) |
| Autorrelacionamento | 1 | `Genero` (subgênero → gênero pai) **e** `Funcionario` (supervisionado → supervisor) — dois autorrelacionamentos |
| Generalização/especialização | 1 | `Funcionario` → `Atendente` / `Gerente` — estratégia table-per-subclass, justificada |
| Entidade fraca | 1 | `Ingresso` — identificada por `(id_sessao, numero_assento)`, dependente de `Sessao` |
| Atributo temporal | 1 | `Historico_Status_Sessao.data_hora_mudanca` — registra cada mudança de status de uma sessão ao longo do tempo; também `Avaliacao.data_avaliacao` |
| Regras de negócio | 20 | 24 regras numeradas (RN01–RN24) |
| Volume de carga | 40 linhas nas principais / 100 na maior | Distribuidora: 40; Filme: 40; Sala: 40; Sessão: 40; Cliente: 40; Funcionário: 42; Ingresso: 110 |
| MER conceitual (A2) | Diagrama com notação única | ⚠️ **Pendente** — `docs/mer-conceitual.drawio` ainda precisa ser criado e adicionado ao repositório |

### 1.3 Regras de Negócio (RN01–RN24)

> Documento completo em `docs/A1-escopo-regras.md`. Resumo abaixo:

| Regra | Enunciado resumido | Como atendida |
|-------|--------------------|---------------|
| RN01 | Todo filme deve ter distribuidora obrigatória | FK NOT NULL |
| RN02 | Classificação etária: Livre, 10, 12, 14, 16 ou 18 | ENUM (restrição de domínio) |
| RN03 | Duração do filme > 0 minutos | CHECK |
| RN04 | Filme pode ter múltiplos gêneros; gênero tem subgêneros (autorrelacionamento) | FK autorrelacionada + tabela N:N |
| RN05 | Data de lançamento não pode ser futura em > 365 dias | Aplicação |
| RN06 | Número da sala único; capacidade > 0 | UNIQUE + CHECK |
| RN07 | Sala tem estado: Ativa, Em Manutenção, Inativa; sessão só em sala Ativa | ENUM + Aplicação (`SessaoDAO.salaEstaAtiva`) |
| RN08 | Sessão requer filme ativo e sala ativa | Aplicação |
| RN09 | Sem sobreposição de horário na mesma sala; intervalo mínimo de 20 min | Aplicação (transação) |
| RN10 | Ingressos não podem superar a capacidade da sala | Trigger `trg_verifica_capacidade` (BEFORE INSERT) |
| RN11 | Cada mudança de status da sessão é registrada com data/hora (histórico temporal) | Tabela `Historico_Status_Sessao` + trigger |
| RN12 | Ingresso é entidade fraca de Sessao; PK composta (id_sessao, numero_assento) | PK composta |
| RN13 | Mesmo assento não pode ser vendido duas vezes na mesma sessão | PK composta |
| RN14 | Tipo do ingresso: Inteira, Meia-entrada ou Cortesia | ENUM (restrição de domínio) |
| RN15 | Cancelamento de ingresso com pelo menos 1h de antecedência | Aplicação |
| RN16 | CPF do cliente único, 11 dígitos numéricos | UNIQUE + CHECK |
| RN17 | Pontos de fidelidade: Inteira = 10pts, Meia = 5pts, Cortesia = 0 | Aplicação |
| RN18 | Cliente avalia apenas filmes que assistiu; nota 1–5 com data | FK + CHECK + Aplicação |
| RN19 | Funcionário é Atendente ou Gerente (especialização total e exclusiva) | Tabelas Atendente/Gerente (table-per-subclass) |
| RN20 | Gerente pode supervisionar funcionários; cada um tem no máximo 1 supervisor | FK autorrelacionada nullable |
| RN21 | Avaliação é N:N entre Cliente e Filme com atributos próprios (nota, comentário, data) | Tabela associativa `Avaliacao` + CHECK `ck_avaliacao_nota` |
| RN22 | Promoção tem desconto 1–100% e período data_inicio ≤ data_fim | CHECK |
| RN23 | Ingresso tem no máximo uma promoção | FK nullable cardinalidade 0..1 |
| RN24 | Valor final = valor_base × (1 − desconto/100), armazenado para auditoria | Aplicação + coluna `valor_final` |

---

## 2. Modelo ER Conceitual (A2)

> ⚠️ **Pendência de entrega:** o arquivo `docs/mer-conceitual.drawio` (e sua exportação `docs/mer-conceitual.pdf`) **ainda não foram incluídos no repositório**. O diagrama precisa ser elaborado e adicionado antes da entrega final — é o critério de maior peso (2,5 pontos).
>
> O resumo textual abaixo descreve o que o diagrama deve conter. Ele **não substitui** o arquivo gráfico exigido pelo enunciado.

### Resumo das entidades e relacionamentos do diagrama:

```
Distribuidora ─────────────────────────────────── Filme
                  1                          N
                  (distribui)

Genero ─── autorrelacionamento ─── Genero
           (subgênero de)           0..1 : N

Filme ───── N:N ───── Genero
            [Filme_Genero: genero_principal]

Sala ─────────────────────────────────────────── Sessao
       1                                    N
       (ocorre em)

Filme ────────────────────────────────────────── Sessao
       1                                    N
       (exibido em)

Sessao ──── 1:N ──── Historico_Status_Sessao   (temporal)

Sessao ──── 1:N ──── Ingresso    (Ingresso = entidade FRACA)

Ingresso ─── N:1 ─── Cliente
Ingresso ─── N:1 ─── Funcionario
Ingresso ─── N:1 ─── Promocao (0..1)

Cliente ───── N:N ───── Filme
              [Avaliacao: nota, comentario, data_avaliacao]

Funcionario ─── autorrelacionamento ─── Funcionario
                (supervisiona)           0..1 : N

Funcionario ──── generalização/especialização ────
                 ├── Atendente  (turno, bilheteria)
                 └── Gerente    (area_responsabilidade, nivel_acesso)
                 Totalidade: total | Exclusividade: exclusiva
```

---

## 3. Dicionário de Dados (A3)

> Documento completo com todas as 14 entidades/tabelas em `docs/A3-dicionario-dados.md`.

### Entidades do modelo e suas chaves

| # | Entidade | Tipo | Chave Primária |
|---|----------|------|----------------|
| 1 | Distribuidora | Forte | `id_distribuidora` (substituta) |
| 2 | Genero | Forte + autorrelac. | `id_genero` (substituta) |
| 3 | Filme | Forte | `id_filme` (substituta) |
| 4 | Filme_Genero | Associativa N:N | `(id_filme, id_genero)` (natural) |
| 5 | Sala | Forte | `id_sala` (substituta) |
| 6 | Sessao | Forte | `id_sessao` (substituta) |
| 7 | Historico_Status_Sessao | Forte (temporal) | `id_historico` (substituta) |
| 8 | Cliente | Forte | `id_cliente` (substituta) |
| 9 | Funcionario | Forte (superentidade) | `id_funcionario` (substituta) |
| 10 | Atendente | Especialização | `id_funcionario` (FK/PK compartilhada) |
| 11 | Gerente | Especialização | `id_funcionario` (FK/PK compartilhada) |
| 12 | Promocao | Forte | `id_promocao` (substituta) |
| 13 | **Ingresso** | **Fraca** de Sessao | `(id_sessao, numero_assento)` (natural composta) |
| 14 | Avaliacao | Associativa N:N | `(id_cliente, id_filme)` (natural composta) |

---

## 4. Modelo Lógico Relacional (A4)

> Documento completo com esquema e todas as decisões em `docs/A4-modelo-logico.md`.

### 4.1 Esquema Relacional (resumido)

```
Distribuidora    (<u>id_distribuidora</u>, nome*, cnpj*, email, telefone, pais_origem)

Genero           (<u>id_genero</u>, nome*, descricao, id_genero_pai→Genero)

Filme            (<u>id_filme</u>, titulo, titulo_nacional, duracao_min, classificacao_etaria,
                  sinopse, data_lancamento, ativo, id_distribuidora→Distribuidora)

Filme_Genero     (<u>id_filme→Filme</u>, <u>id_genero→Genero</u>, genero_principal)

Sala             (<u>id_sala</u>, numero*, capacidade, tipo, estado)

Sessao           (<u>id_sessao</u>, data_hora_inicio, data_hora_fim†, idioma,
                  valor_ingresso_base, status, id_filme→Filme, id_sala→Sala)

Historico_Status_Sessao  (<u>id_historico</u>, id_sessao→Sessao, status_anterior,
                          status_novo, data_hora_mudanca, id_funcionario→Funcionario)

Cliente          (<u>id_cliente</u>, nome, cpf*, data_nascimento, email*, telefone,
                  pontos_fidelidade, data_cadastro)

Funcionario      (<u>id_funcionario</u>, nome, cpf*, email*, telefone, data_admissao,
                  salario, cargo, ativo, id_supervisor→Funcionario)

Atendente        (<u>id_funcionario→Funcionario</u>, turno, bilheteria)

Gerente          (<u>id_funcionario→Funcionario</u>, area_responsabilidade, nivel_acesso)

Promocao         (<u>id_promocao</u>, nome, descricao, percentual_desconto,
                  data_inicio, data_fim)

Ingresso ‡       (<u>id_sessao→Sessao</u>, <u>numero_assento</u>, tipo, valor_base†,
                  valor_final†, status, data_venda, id_cliente→Cliente,
                  id_funcionario→Funcionario, id_promocao→Promocao)

Avaliacao        (<u>id_cliente→Cliente</u>, <u>id_filme→Filme</u>, nota, comentario,
                  data_avaliacao)
```

> `*` = UNIQUE | `†` = desnormalização deliberada documentada | `‡` = entidade fraca

### 4.2 Decisões de Mapeamento — Resumo

| Decisão | Estratégia adotada | Justificativa |
|---------|--------------------|---------------|
| Especialização Funcionario | Table-per-subclass (3 tabelas) | Evita NULLs estruturais; atributos exclusivos por subclasse; especialização total e exclusiva |
| Autorrelacionamento Genero | FK `id_genero_pai` nullable na própria tabela | Relacionamento 1:N; NULL = gênero raiz |
| Autorrelacionamento Funcionario | FK `id_supervisor` nullable na própria tabela | Relacionamento 1:N; NULL = sem supervisor |
| N:N Filme-Genero | Tabela `Filme_Genero` com atributo `genero_principal` | Atributo pertence à associação, não à entidade isolada |
| N:N Cliente-Filme | Tabela `Avaliacao` com atributos `nota`, `comentario`, `data_avaliacao` | Idem acima |
| Entidade fraca Ingresso | PK composta `(id_sessao, numero_assento)` | Preserva semântica de dependência de identificação; ON DELETE CASCADE |
| FK Ingresso → Promocao | Nullable (0..1) | RN23: no máximo uma promoção, mas opcional |
| Chaves naturais vs substitutas | Substituta na maioria; natural nas associativas | FKs leves como inteiros; naturais onde a semântica da composição é inequívoca |

---

## 5. Verificação de Normalização (A5)

> Análise completa com dependências funcionais de todas as 14 relações em `docs/A5-normalizacao.md`.

### 5.1 Resultado por relação

| Relação | 1FN | 2FN | 3FN | FNBC | Observação |
|---------|:---:|:---:|:---:|:----:|------------|
| Distribuidora | ✅ | ✅ | ✅ | ✅ | — |
| Genero | ✅ | ✅ | ✅ | ✅ | — |
| Filme | ✅ | ✅ | ✅ | ✅ | — |
| Filme_Genero | ✅ | ✅ | ✅ | ✅ | Único atributo não-chave depende da PK composta completa |
| Sala | ✅ | ✅ | ✅ | ✅ | — |
| Sessao | ✅ | ✅ | ✅* | ✅ | `data_hora_fim` desnormalizado — ver 5.2 |
| Historico_Status_Sessao | ✅ | ✅ | ✅ | ✅ | — |
| Cliente | ✅ | ✅ | ✅ | ✅ | — |
| Funcionario | ✅ | ✅ | ✅ | ✅ | — |
| Atendente | ✅ | ✅ | ✅ | ✅ | — |
| Gerente | ✅ | ✅ | ✅ | ✅ | — |
| Promocao | ✅ | ✅ | ✅ | ✅ | — |
| Ingresso | ✅ | ⚠️* | ⚠️* | ⚠️* | `valor_base` viola 2FN; `valor_final` viola 3FN — desnormalizações deliberadas, ver 5.2 |
| Avaliacao | ✅ | ✅ | ✅ | ✅ | Atributos dependem da PK composta completa |

> ✅* = desnormalização inter-relações documentada (Sessao.data_hora_fim). ⚠️* = violação formal aceita e justificada (Ingresso.valor_base e valor_final).

**Conclusão:** 13 das 14 relações estão na **Terceira Forma Normal (3FN)** e atingem a **Forma Normal de Boyce-Codd (FNBC)**. A relação `Ingresso` está em 1FN, com desnormalizações deliberadas em `valor_base` (viola 2FN) e `valor_final` (viola 3FN), documentadas e justificadas por auditoria financeira. A desnormalização de `Sessao.data_hora_fim` é inter-relações (derivável via `Filme.duracao_min`), justificada por desempenho.

### 5.2 Desnormalizações deliberadas

**`Sessao.data_hora_fim`**
- Poderia ser calculado via join com `Filme` (inicio + duração).
- Armazenado diretamente para evitar join extra na verificação de sobreposição de horários (RN09), que é executada a cada criação de sessão.
- **Justificativa:** desempenho em operação crítica de alta frequência.

**`Ingresso.valor_base` e `Ingresso.valor_final`**
- `valor_base` poderia ser obtido via join com `Sessao.valor_ingresso_base`.
- Ambos armazenados como *snapshot* no momento da venda para fins de auditoria financeira.
- **Justificativa:** alteração retroativa no preço da sessão não deve distorcer relatórios históricos de receita — prática padrão em sistemas de e-commerce e bilheteria.

---

## 6. Declaração de Uso de IA

Este projeto utilizou assistente de inteligência artificial (Kiro / Claude — Anthropic) como apoio nas seguintes partes:

| Parte do trabalho | Como foi utilizado | Como foi verificado |
|-------------------|--------------------|---------------------|
| Estruturação do script DDL | Geração inicial de `CREATE TABLE` e constraints | Cada tabela revisada manualmente; nomes de constraints, tipos e regras ON DELETE/UPDATE verificados contra as RNs |
| Dados de carga (02_carga.sql) | Geração de dados fictícios realistas | Dados conferidos quanto a coerência referencial, volume mínimo e casos de contorno exigidos |
| Código Java (DAOs) | Esqueleto dos DAOs com prepared statements | Lógica de transação, tratamento de erros e mapeamento revisados pela equipe |
| Formatação dos documentos | Estrutura markdown dos artefatos A1–A5 | Conteúdo técnico (regras, decisões, análise de normalização) elaborado e validado pela equipe |

**A equipe é responsável por todas as decisões de modelagem, regras de negócio e consultas SQL. Qualquer integrante é capaz de explicar e defender cada parte do trabalho.**

---

## Checklist de Entrega — Etapa 1

- [x] O repositório está acessível e contém a estrutura de pastas prevista
- [x] O banco foi apagado e `01_ddl.sql` executa do início ao fim sem erro
- [x] `02_carga.sql` executa na sequência, também sem erro
- [x] As 15 consultas de `03_consultas.sql` retornam resultado coerente
- [x] Todas as restrições estão nomeadas com os prefixos `pk_`, `uq_`, `fk_`, `ck_`, `idx_`
- [x] Toda chave estrangeira tem `ON DELETE` e `ON UPDATE` definidos explicitamente
- [x] Os requisitos mínimos de complexidade do item 4 estão todos atendidos
- [x] As 24 regras de negócio estão numeradas e rastreadas até a implementação
- [ ] **O MER (A2) está no repositório** — `docs/mer-conceitual.drawio` e `docs/mer-conceitual.pdf` **ainda precisam ser criados e adicionados** (critério de maior peso: 2,5 pontos)
- [x] **O relatório está em PDF** — `relatorio-etapa1.pdf` gerado e adicionado à pasta `docs/`
- [x] O MER usa uma única notação, do começo ao fim *(válido quando o arquivo for criado)*
- [x] As decisões de mapeamento estão justificadas em texto (A4)
- [x] A análise de normalização apresenta as dependências funcionais (A5)
- [x] **O relatório em PDF reúne A1 a A5 e está paginado**
- [x] Todos os integrantes sabem explicar todas as partes do trabalho

---

*Dúvidas: samuel.moura@p.ucb.br*
