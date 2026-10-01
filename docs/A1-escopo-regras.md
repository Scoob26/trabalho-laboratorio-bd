# A1 — Documento de Escopo e Regras de Negócio

## 1. Descrição do Domínio

O sistema gerencia as operações de um complexo cinematográfico com múltiplas salas de exibição. O domínio abrange o cadastro e controle de filmes (com suas distribuidoras, gêneros e classificações etárias), o gerenciamento físico das salas, a programação de sessões, a venda e controle de ingressos, o cadastro de clientes do programa de fidelidade, o gerenciamento de funcionários (divididos em atendentes e gerentes) e a aplicação de promoções.

O cinema opera com sessões distribuídas ao longo do dia em diferentes salas. Cada sessão exibe um único filme em uma sala específica, com capacidade limitada pelo número de assentos disponíveis. Os ingressos são emitidos por sessão e vinculados a um cliente cadastrado ou vendidos de forma avulsa. Clientes fidelizados acumulam pontos a cada compra e podem utilizá-los para obter descontos. O sistema também registra avaliações dos filmes pelos clientes, formando um histórico datado de opiniões.

O complexo conta com funcionários que podem ocupar o papel de atendente (responsável pela bilheteria e pela venda de ingressos) ou gerente (responsável pela programação das sessões e pela gestão das salas). Um gerente pode supervisionar outros funcionários, caracterizando uma hierarquia interna.

---

## 2. Regras de Negócio

### Filmes e Distribuidoras

**RN01** — Todo filme deve estar associado a exatamente uma distribuidora no momento do cadastro.  
*Atendida por:* restrição do banco (FK `fk_filme_distribuidora` NOT NULL).

**RN02** — Todo filme deve possuir uma classificação etária obrigatória, cujos valores permitidos são: Livre, 10, 12, 14, 16 e 18.  
*Atendida por:* restrição do banco (coluna `classificacao_etaria ENUM('Livre','10','12','14','16','18') NOT NULL` — o tipo ENUM do MySQL rejeita qualquer valor fora do conjunto declarado, cumprindo o papel de constraint de domínio).

**RN03** — A duração de um filme deve ser maior que zero minutos.  
*Atendida por:* restrição do banco (CHECK `ck_filme_duracao`).

**RN04** — Um filme pode pertencer a um ou mais gêneros; cada gênero pode ter um gênero-pai (autorrelacionamento), permitindo subgêneros (ex: "Ficção Científica" é subgênero de "Aventura").  
*Atendida por:* restrição do banco (FK `fk_genero_pai` na tabela `Genero`; tabela associativa `Filme_Genero`).

**RN05** — A data de lançamento de um filme não pode ser futura em mais de 365 dias a partir da data de cadastro no sistema.  
*Atendida por:* aplicação (validação na camada de negócio antes do INSERT).

---

### Salas

**RN06** — Cada sala deve ter um número único dentro do complexo e uma capacidade de assentos maior que zero.  
*Atendida por:* restrição do banco (UNIQUE `uq_sala_numero`; CHECK `ck_sala_capacidade`).

**RN07** — Uma sala pode estar em um de três estados: Ativa, Em Manutenção ou Inativa. Sessões só podem ser criadas em salas com estado "Ativa".  
*Atendida por:* restrição do banco (coluna `estado ENUM('Ativa','Em Manutenção','Inativa') NOT NULL` — o ENUM restringe os valores aceitos); aplicação (`SessaoDAO.inserir` verifica `salaEstaAtiva()` antes do INSERT e realiza rollback caso a sala não esteja Ativa).

---

### Sessões

**RN08** — Uma sessão deve referenciar um filme ativo (não cancelado) e uma sala ativa.  
*Atendida por:* aplicação (verificação de status antes do INSERT).

**RN09** — Não podem existir duas sessões na mesma sala com sobreposição de horário. O intervalo entre o fim de uma sessão e o início da próxima na mesma sala deve ser de no mínimo 20 minutos (para limpeza).  
*Atendida por:* aplicação (consulta de verificação de sobreposição antes do INSERT).

**RN10** — O número de ingressos vendidos para uma sessão não pode ultrapassar a capacidade da sala associada.  
*Atendida por:* restrição do banco (trigger `trg_verifica_capacidade` — BEFORE INSERT em `Ingresso`, conta os ingressos ativos da sessão e emite SIGNAL se a capacidade da sala foi atingida); aplicação (verificação adicional antes da venda).

**RN11** — Uma sessão possui um histórico de status ao longo do tempo: Agendada, Em Exibição, Encerrada ou Cancelada. Cada mudança de status é registrada com data e hora.  
*Atendida por:* banco (tabela `Historico_Status_Sessao` com atributo temporal `data_hora_mudanca`).

---

### Ingressos

**RN12** — O ingresso é uma entidade fraca de Sessao: sua identificação parcial é o número do assento; a chave completa é (id_sessao, numero_assento).  
*Atendida por:* restrição do banco (PK composta `pk_ingresso`).

**RN13** — O mesmo assento não pode ser vendido duas vezes para a mesma sessão.  
*Atendida por:* restrição do banco (UNIQUE `uq_ingresso_sessao_assento` / PK composta).

**RN14** — O tipo de ingresso pode ser: Inteira, Meia-entrada ou Cortesia. O valor cobrado depende do tipo e da promoção aplicada.  
*Atendida por:* restrição do banco (coluna `tipo ENUM('Inteira','Meia-entrada','Cortesia') NOT NULL` — o ENUM garante que apenas valores do conjunto sejam persistidos).

**RN15** — Um ingresso pode ser cancelado, desde que o cancelamento ocorra com pelo menos 1 hora de antecedência em relação ao início da sessão.  
*Atendida por:* aplicação (validação de tempo antes do UPDATE de status).

---

### Clientes e Fidelidade

**RN16** — O CPF do cliente deve ser único no sistema e ter exatamente 11 dígitos numéricos.  
*Atendida por:* restrição do banco (UNIQUE `uq_cliente_cpf`; CHECK `ck_cliente_cpf`).

**RN17** — A cada ingresso do tipo Inteira comprado, o cliente acumula 10 pontos de fidelidade; Meia-entrada acumula 5 pontos. Cortesia não acumula pontos.  
*Atendida por:* aplicação (lógica de acúmulo na camada de negócio após confirmação da venda).  
*Nota sobre a carga:* os valores de `pontos_fidelidade` na tabela `Cliente` representam o saldo acumulado ao longo do tempo, incluindo compras anteriores ao período coberto pelo script `02_carga.sql`. Os ingressos inseridos na carga são uma amostra recente das transações — o saldo total é coerente com um histórico mais longo de uso do sistema.

**RN18** — Um cliente só pode avaliar um filme se tiver comprado ingresso para ao menos uma sessão desse filme. A avaliação possui nota (1 a 5) e comentário opcional, e é registrada com data.  
*Atendida por:* restrição do banco (FK em `Avaliacao`); aplicação (verificação de histórico de compra antes de permitir avaliação); CHECK `ck_avaliacao_nota`.

---

### Funcionários

**RN19** — Todo funcionário deve ter um cargo, que pode ser "Atendente" ou "Gerente". A especialização é mapeada em tabelas separadas (`Atendente` e `Gerente`), cada uma com atributos próprios.  
*Atendida por:* restrição do banco (estrutura de generalização/especialização com tabelas `Atendente` e `Gerente`).

**RN20** — Um gerente pode supervisionar zero ou vários funcionários, mas um funcionário tem no máximo um supervisor direto (autorrelacionamento em `Funcionario`).  
*Atendida por:* restrição do banco (FK `fk_funcionario_supervisor` em `Funcionario`, autorreferenciada, nullable).

**RN21** — Um cliente pode avaliar vários filmes e um filme pode receber avaliações de vários clientes, formando um relacionamento N:N. Cada avaliação é uma entidade associativa com atributos próprios: nota (obrigatória) e comentário (opcional), além de data de registro.  
*Atendida por:* restrição do banco (tabela `Avaliacao` com chave composta `pk_avaliacao (id_cliente, id_filme)`; constraint `ck_avaliacao_nota CHECK (nota BETWEEN 1 AND 5)`).

**RN22** — Uma promoção tem validade definida por data de início e data de fim, e aplica um percentual de desconto entre 1% e 100%. Promoções com data de fim anterior à data atual não podem ser aplicadas a novos ingressos.  
*Atendida por:* restrição do banco (CHECK `ck_promocao_desconto`); aplicação (validação de vigência antes de aplicar).

**RN23** — Um ingresso pode ter no máximo uma promoção aplicada simultaneamente.  
*Atendida por:* restrição do banco (FK `fk_ingresso_promocao` nullable, cardinalidade 0..1).

**RN24** — O valor final do ingresso é calculado segundo as seguintes regras, aplicadas em ordem:

1. **Cortesia:** `valor_final = 0,00`, independentemente do valor base e de qualquer promoção.
2. **Meia-entrada sem promoção:** `valor_final = valor_base × 0,50` (desconto fixo de 50% por lei).
3. **Meia-entrada com promoção:** `valor_final = (valor_base × 0,50) × (1 − percentual_desconto / 100)`.
4. **Inteira sem promoção:** `valor_final = valor_base`.
5. **Inteira com promoção:** `valor_final = valor_base × (1 − percentual_desconto / 100)`.

Todos os valores são arredondados para 2 casas decimais e armazenados na coluna `valor_final` no momento da venda, formando um snapshot auditável (RN24 complementa RN23).  
*Atendida por:* aplicação (cálculo na camada de negócio); banco (coluna `valor_final` armazenada para auditoria).

---

## 3. Rastreabilidade Resumida

| Regra | Entidade(s) envolvida(s) | Como atendida |
|-------|--------------------------|---------------|
| RN01 | Filme, Distribuidora | FK NOT NULL |
| RN02 | Filme | ENUM (restrição de domínio) |
| RN03 | Filme | CHECK |
| RN04 | Genero, Filme_Genero | FK autorrelacionada + tabela N:N |
| RN05 | Filme | Aplicação |
| RN06 | Sala | UNIQUE + CHECK |
| RN07 | Sala, Sessao | ENUM + Aplicação |
| RN08 | Sessao | Aplicação |
| RN09 | Sessao | Aplicação |
| RN10 | Ingresso, Sessao, Sala | Trigger BEFORE INSERT |
| RN11 | Historico_Status_Sessao | Tabela temporal + trigger AFTER UPDATE |
| RN12 | Ingresso | PK composta (entidade fraca) |
| RN13 | Ingresso | PK composta / UNIQUE |
| RN14 | Ingresso | ENUM (restrição de domínio) |
| RN15 | Ingresso | Aplicação |
| RN16 | Cliente | UNIQUE + CHECK |
| RN17 | Cliente, Ingresso | Aplicação |
| RN18 | Avaliacao, Ingresso | FK + CHECK + Aplicação |
| RN19 | Funcionario, Atendente, Gerente | Especialização (tabelas separadas) |
| RN20 | Funcionario | FK autorrelacionada nullable |
| RN21 | Avaliacao | Tabela associativa N:N com atributos + CHECK nota |
| RN22 | Promocao, Ingresso | CHECK + Aplicação |
| RN23 | Ingresso, Promocao | FK nullable |
| RN24 | Ingresso | Aplicação + coluna derivada |
