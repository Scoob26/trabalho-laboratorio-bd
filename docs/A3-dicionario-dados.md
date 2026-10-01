# A3 — Dicionário de Dados Conceitual

> Formato baseado no Anexo A do enunciado. A coluna **Observação** registra a regra de negócio associada ao atributo quando aplicável.

---

## Entidade: Distribuidora

Empresa responsável pela distribuição comercial dos filmes para o cinema.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_distribuidora | Identificador interno da distribuidora | Inteiro sequencial | Sim | Chave primária substituta |
| nome | Nome comercial da distribuidora | Texto até 150 caracteres | Sim | Deve ser único no sistema |
| cnpj | CNPJ da distribuidora | 14 dígitos numéricos | Sim | Único; formato sem pontuação |
| email | E-mail de contato | Texto até 100 caracteres | Não | Aceita ausência de contato |
| telefone | Telefone de contato | Texto até 20 caracteres | Não | Aceita ausência de contato |
| pais_origem | País-sede da distribuidora | Texto até 60 caracteres | Sim | Ex: "Brasil", "EUA" |

---

## Entidade: Genero

Gênero cinematográfico. Possui autorrelacionamento para representar subgêneros.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_genero | Identificador interno do gênero | Inteiro sequencial | Sim | Chave primária substituta |
| nome | Nome do gênero | Texto até 60 caracteres | Sim | Único; ex: "Ação", "Drama" |
| descricao | Descrição textual do gênero | Texto até 300 caracteres | Não | Campo informativo |
| id_genero_pai | Referência ao gênero pai (autorrelacionamento) | Inteiro (FK) | Não | RN04 — NULL indica gênero raiz |

---

## Entidade: Filme

Obra cinematográfica cadastrada no sistema, exibida ou a ser exibida.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_filme | Identificador interno do filme | Inteiro sequencial | Sim | Chave primária substituta |
| titulo | Título original do filme | Texto até 200 caracteres | Sim | |
| titulo_nacional | Título em português | Texto até 200 caracteres | Não | Pode ser igual ao título original |
| duracao_min | Duração em minutos | Inteiro positivo | Sim | RN03 — deve ser > 0 |
| classificacao_etaria | Classificação indicativa | ENUM: Livre, 10, 12, 14, 16, 18 | Sim | RN02 |
| sinopse | Resumo da história do filme | Texto longo | Não | Campo informativo |
| data_lancamento | Data de lançamento original | Data | Sim | RN05 — não pode ser futura em mais de 365 dias |
| ativo | Indica se o filme está disponível para sessões | Booleano | Sim | Default TRUE; RN08 |
| id_distribuidora | Distribuidora responsável pelo filme | Inteiro (FK) | Sim | RN01 — NOT NULL |

---

## Entidade: Filme_Genero (associativa N:N)

Relacionamento entre Filme e Gênero. Um filme pode ter múltiplos gêneros.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_filme | Referência ao filme | Inteiro (FK) | Sim | Parte da chave primária composta |
| id_genero | Referência ao gênero | Inteiro (FK) | Sim | Parte da chave primária composta |
| genero_principal | Indica se é o gênero principal do filme | Booleano | Sim | Atributo próprio da associação; RN04 |

---

## Entidade: Sala

Sala física de exibição do complexo cinematográfico.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_sala | Identificador interno da sala | Inteiro sequencial | Sim | Chave primária substituta |
| numero | Número identificador da sala no complexo | Inteiro positivo | Sim | RN06 — único no sistema |
| capacidade | Número total de assentos | Inteiro positivo | Sim | RN06 — deve ser > 0 |
| tipo | Tipo de tecnologia da sala | ENUM: 2D, 3D, IMAX, 4DX | Sim | |
| estado | Estado operacional atual | ENUM: Ativa, Em Manutenção, Inativa | Sim | RN07 — default "Ativa" |

---

## Entidade: Sessao

Exibição agendada de um filme em uma sala em data e hora específicas.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_sessao | Identificador interno da sessão | Inteiro sequencial | Sim | Chave primária substituta |
| data_hora_inicio | Data e hora de início da exibição | DateTime | Sim | RN09 |
| data_hora_fim | Data e hora de fim (calculada) | DateTime | Sim | Derivado: inicio + duracao do filme |
| idioma | Idioma de exibição | Texto até 30 caracteres | Sim | Ex: "Português", "Inglês Legendado" |
| valor_ingresso_base | Preço base do ingresso inteiro | Decimal(8,2) | Sim | Valor de referência para cálculo RN24 |
| status | Status atual da sessão | ENUM: Agendada, Em Exibição, Encerrada, Cancelada | Sim | RN11 |
| id_filme | Filme exibido na sessão | Inteiro (FK) | Sim | RN08 |
| id_sala | Sala onde ocorre a sessão | Inteiro (FK) | Sim | RN07, RN09 |

---

## Entidade: Historico_Status_Sessao

Registra cada mudança de status de uma sessão ao longo do tempo. Representa o atributo temporal exigido pelo projeto.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_historico | Identificador do registro histórico | Inteiro sequencial | Sim | Chave primária substituta |
| id_sessao | Sessão a que se refere | Inteiro (FK) | Sim | RN11 |
| status_anterior | Status antes da mudança | ENUM: Agendada, Em Exibição, Encerrada, Cancelada | Não | NULL no primeiro registro |
| status_novo | Status após a mudança | ENUM: Agendada, Em Exibição, Encerrada, Cancelada | Sim | RN11 |
| data_hora_mudanca | Data e hora em que a mudança ocorreu | DateTime | Sim | RN11 — atributo temporal |
| id_funcionario | Funcionário que realizou a mudança | Inteiro (FK) | Não | Pode ser automático (NULL) |

---

## Entidade: Cliente

Pessoa física cadastrada no programa de fidelidade do cinema.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_cliente | Identificador interno do cliente | Inteiro sequencial | Sim | Chave primária substituta |
| nome | Nome completo do cliente | Texto até 120 caracteres | Sim | |
| cpf | CPF do cliente | 11 dígitos numéricos | Sim | RN16 — único; sem formatação |
| data_nascimento | Data de nascimento | Data | Sim | Usada para validação de classificação etária |
| email | E-mail do cliente | Texto até 100 caracteres | Sim | Único no sistema |
| telefone | Telefone de contato | Texto até 20 caracteres | Não | Aceita ausência |
| pontos_fidelidade | Saldo atual de pontos acumulados | Inteiro >= 0 | Sim | RN17 — default 0 |
| data_cadastro | Data de entrada no programa | Date | Sim | Default data atual |

---

## Entidade: Funcionario

Colaborador do cinema. Superentidade da especialização Atendente / Gerente.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_funcionario | Identificador interno do funcionário | Inteiro sequencial | Sim | Chave primária substituta |
| nome | Nome completo | Texto até 120 caracteres | Sim | |
| cpf | CPF do funcionário | 11 dígitos numéricos | Sim | Único no sistema |
| email | E-mail corporativo | Texto até 100 caracteres | Sim | Único |
| telefone | Telefone de contato | Texto até 20 caracteres | Não | |
| data_admissao | Data de admissão na empresa | Date | Sim | |
| salario | Salário bruto mensal | Decimal(10,2) | Sim | Deve ser > 0 |
| cargo | Discriminador da especialização | ENUM: Atendente, Gerente | Sim | RN19 |
| ativo | Indica se o funcionário está em atividade | Booleano | Sim | Default TRUE |
| id_supervisor | Referência ao supervisor direto (autorrelacionamento) | Inteiro (FK) | Não | RN20 — NULL para quem não tem supervisor |

---

## Entidade: Atendente (especialização de Funcionario)

Funcionário que atua na bilheteria e realiza a venda de ingressos.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_funcionario | Identificador (herdado de Funcionario) | Inteiro (FK/PK) | Sim | RN19 — chave compartilhada |
| turno | Turno de trabalho | ENUM: Manhã, Tarde, Noite | Sim | |
| bilheteria | Número da bilheteria de atuação | Inteiro positivo | Sim | |

---

## Entidade: Gerente (especialização de Funcionario)

Funcionário com poderes de gestão sobre salas e programação de sessões.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_funcionario | Identificador (herdado de Funcionario) | Inteiro (FK/PK) | Sim | RN19 — chave compartilhada |
| area_responsabilidade | Área de gestão | Texto até 80 caracteres | Sim | Ex: "Programação", "Operações" |
| nivel_acesso | Nível de permissão no sistema | Inteiro (1–5) | Sim | Quanto maior, mais permissões |

---

## Entidade: Promocao

Promoção com desconto percentual aplicável a ingressos dentro de um período.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_promocao | Identificador interno | Inteiro sequencial | Sim | Chave primária substituta |
| nome | Nome da promoção | Texto até 100 caracteres | Sim | Ex: "Terça do Cinema" |
| descricao | Descrição textual | Texto até 300 caracteres | Não | |
| percentual_desconto | Percentual de desconto aplicado | Decimal(5,2) entre 1 e 100 | Sim | RN22 |
| data_inicio | Data de início da validade | Date | Sim | RN22 |
| data_fim | Data de fim da validade | Date | Sim | RN22 — deve ser >= data_inicio |

---

## Entidade: Ingresso (entidade fraca de Sessao)

Ingresso emitido para um assento específico em uma sessão. Identificado parcialmente pelo número do assento.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_sessao | Sessão à qual o ingresso pertence | Inteiro (FK) | Sim | RN12 — parte da chave primária |
| numero_assento | Número do assento na sala | Inteiro positivo | Sim | RN12 — identificação parcial; RN13 |
| tipo | Tipo do ingresso | ENUM: Inteira, Meia-entrada, Cortesia | Sim | RN14 |
| valor_base | Valor base do ingresso (copiado da sessão) | Decimal(8,2) | Sim | RN24 |
| valor_final | Valor efetivamente cobrado após desconto | Decimal(8,2) | Sim | RN24 — calculado pela aplicação |
| status | Status do ingresso | ENUM: Reservado, Pago, Cancelado | Sim | RN15 |
| data_venda | Data e hora da emissão | DateTime | Sim | Default NOW() |
| id_cliente | Cliente que comprou o ingresso | Inteiro (FK) | Não | NULL para venda avulsa |
| id_funcionario | Atendente que realizou a venda | Inteiro (FK) | Não | NULL para venda online |
| id_promocao | Promoção aplicada ao ingresso | Inteiro (FK) | Não | RN23 — NULL se sem promoção |

---

## Entidade: Avaliacao (associativa N:N entre Cliente e Filme)

Avaliação feita por um cliente sobre um filme que assistiu. Relacionamento N:N com atributos próprios.

| Atributo | Descrição | Domínio | Obrig. | Observação |
|----------|-----------|---------|--------|------------|
| id_cliente | Cliente que avaliou | Inteiro (FK) | Sim | RN18 — parte da chave primária |
| id_filme | Filme avaliado | Inteiro (FK) | Sim | RN18 — parte da chave primária |
| nota | Nota atribuída ao filme | Inteiro entre 1 e 5 | Sim | RN18 — CHECK ck_avaliacao_nota |
| comentario | Comentário textual opcional | Texto longo | Não | Aceita ausência |
| data_avaliacao | Data e hora da avaliação | DateTime | Sim | RN18 — atributo temporal da associação |

---

## Resumo das Entidades

| # | Entidade | Tipo | Chave Primária |
|---|----------|------|----------------|
| 1 | Distribuidora | Forte | id_distribuidora (substituta) |
| 2 | Genero | Forte (autorrelacionamento) | id_genero (substituta) |
| 3 | Filme | Forte | id_filme (substituta) |
| 4 | Filme_Genero | Associativa N:N | (id_filme, id_genero) |
| 5 | Sala | Forte | id_sala (substituta) |
| 6 | Sessao | Forte | id_sessao (substituta) |
| 7 | Historico_Status_Sessao | Forte (temporal) | id_historico (substituta) |
| 8 | Cliente | Forte | id_cliente (substituta) |
| 9 | Funcionario | Forte (superentidade) | id_funcionario (substituta) |
| 10 | Atendente | Especialização | id_funcionario (FK/PK) |
| 11 | Gerente | Especialização | id_funcionario (FK/PK) |
| 12 | Promocao | Forte | id_promocao (substituta) |
| 13 | Ingresso | **Fraca** de Sessao | (id_sessao, numero_assento) |
| 14 | Avaliacao | Associativa N:N | (id_cliente, id_filme) |

> **Contagem de entidades fortes (sem associativas puras):** Distribuidora, Genero, Filme, Sala, Sessao, Historico_Status_Sessao, Cliente, Funcionario, Promocao, Ingresso = **10 entidades** (acima do mínimo de 8).
