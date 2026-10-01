# A4 — Modelo Lógico Relacional

## 1. Esquema Relacional

Notação: **PK sublinhada**, *FK em itálico*, `UNIQUE` marcado explicitamente.

---

### Distribuidora
**<u>id_distribuidora</u>**, nome `UNIQUE`, cnpj `UNIQUE`, email, telefone, pais_origem

---

### Genero
**<u>id_genero</u>**, nome `UNIQUE`, descricao, *id_genero_pai* → Genero(id_genero)

---

### Filme
**<u>id_filme</u>**, titulo, titulo_nacional, duracao_min, classificacao_etaria, sinopse, data_lancamento, ativo, *id_distribuidora* → Distribuidora(id_distribuidora)

---

### Filme_Genero
**<u>*id_filme*</u>** → Filme(id_filme), **<u>*id_genero*</u>** → Genero(id_genero), genero_principal

---

### Sala
**<u>id_sala</u>**, numero `UNIQUE`, capacidade, tipo, estado

---

### Sessao
**<u>id_sessao</u>**, data_hora_inicio, data_hora_fim, idioma, valor_ingresso_base, status, *id_filme* → Filme(id_filme), *id_sala* → Sala(id_sala)

---

### Historico_Status_Sessao
**<u>id_historico</u>**, *id_sessao* → Sessao(id_sessao), status_anterior, status_novo, data_hora_mudanca, *id_funcionario* → Funcionario(id_funcionario)

---

### Cliente
**<u>id_cliente</u>**, nome, cpf `UNIQUE`, data_nascimento, email `UNIQUE`, telefone, pontos_fidelidade, data_cadastro

---

### Funcionario
**<u>id_funcionario</u>**, nome, cpf `UNIQUE`, email `UNIQUE`, telefone, data_admissao, salario, cargo, ativo, *id_supervisor* → Funcionario(id_funcionario)

---

### Atendente
**<u>*id_funcionario*</u>** → Funcionario(id_funcionario), turno, bilheteria

---

### Gerente
**<u>*id_funcionario*</u>** → Funcionario(id_funcionario), area_responsabilidade, nivel_acesso

---

### Promocao
**<u>id_promocao</u>**, nome, descricao, percentual_desconto, data_inicio, data_fim

---

### Ingresso *(entidade fraca de Sessao)*
**<u>*id_sessao*</u>** → Sessao(id_sessao), **<u>numero_assento</u>**, tipo, valor_base, valor_final, status, data_venda, *id_cliente* → Cliente(id_cliente), *id_funcionario* → Funcionario(id_funcionario), *id_promocao* → Promocao(id_promocao)

---

### Avaliacao
**<u>*id_cliente*</u>** → Cliente(id_cliente), **<u>*id_filme*</u>** → Filme(id_filme), nota, comentario, data_avaliacao

---

## 2. Decisões de Mapeamento

### 2.1 Generalização/Especialização — Funcionario → Atendente / Gerente

**Estratégia adotada:** Tabela por subclasse (*Table-per-Subclass*) — três tabelas: `Funcionario`, `Atendente` e `Gerente`.

**Justificativa:** A superentidade `Funcionario` possui atributos comuns a todos os funcionários (nome, CPF, salário, etc.) que seriam duplicados se a estratégia de tabela única fosse usada. As subclasses `Atendente` e `Gerente` têm atributos exclusivos (turno/bilheteria vs. area_responsabilidade/nivel_acesso) que não fazem sentido para a outra subclasse — armazená-los na mesma tabela geraria muitos NULLs estruturais, o que a estratégia de tabela única causaria. A estratégia de tabela única por subclasse (*Table-per-Concrete-Class*) foi descartada porque exigiria duplicar todas as colunas comuns de `Funcionario` em cada subclasse, tornando joins desnecessariamente complexos. A especialização é **total e exclusiva**: todo funcionário é obrigatoriamente Atendente ou Gerente (nunca os dois), o que torna a estratégia de três tabelas coerente — a presença de uma linha em `Atendente` ou `Gerente` com a mesma PK de `Funcionario` funciona como discriminador implícito, além da coluna `cargo` na superentidade.

---

### 2.2 Autorrelacionamento — Genero pai/filho

**Decisão:** FK `id_genero_pai` nullable na própria tabela `Genero`.

**Justificativa:** O autorrelacionamento é do tipo 1:N (um gênero pai pode ter vários subgêneros; cada subgênero tem no máximo um pai). O mapeamento canônico para 1:N mantém a FK na tabela do lado "muitos", que é a própria `Genero`. O atributo é nullable porque gêneros raiz (ex: "Drama") não possuem pai.

---

### 2.3 Autorrelacionamento — Funcionario supervisor/supervisionado

**Decisão:** FK `id_supervisor` nullable na própria tabela `Funcionario`.

**Justificativa:** Mesmo raciocínio do 2.2 — relacionamento 1:N autorreferenciado. Um gerente supervisiona vários funcionários; cada funcionário tem no máximo um supervisor. A FK é nullable porque o gerente de topo não tem supervisor.

---

### 2.4 Relacionamentos N:N com atributo próprio

**Filme_Genero:** Relacionamento N:N entre `Filme` e `Genero` gerou tabela associativa com atributo próprio `genero_principal` (booleano que indica o gênero predominante do filme). PK composta (id_filme, id_genero). Justificativa: atributo não pertence a `Filme` nem a `Genero` isoladamente — pertence à associação.

**Avaliacao:** Relacionamento N:N entre `Cliente` e `Filme` gerou tabela associativa com atributos próprios `nota`, `comentario` e `data_avaliacao`. PK composta (id_cliente, id_filme). Justificativa: os atributos descrevem o ato da avaliação, não o cliente nem o filme em si.

---

### 2.5 Relacionamento 1:N — Sessao → Ingresso (entidade fraca)

**Decisão:** `Ingresso` mantido como tabela separada com PK composta (id_sessao, numero_assento).

**Justificativa:** `Ingresso` é entidade fraca de `Sessao` — sua existência depende da sessão e sua identificação parcial é o número do assento. A PK composta garante que o mesmo assento não seja vendido duas vezes na mesma sessão (RN13). Fundir `Ingresso` em `Sessao` seria inviável pois cada sessão pode ter centenas de ingressos (cardinalidade 1:N com muitos registros).

---

### 2.6 Relacionamento 1:N com cardinalidade opcional — Ingresso → Promocao

**Decisão:** FK `id_promocao` nullable em `Ingresso`.

**Justificativa:** Nem todo ingresso tem promoção aplicada (cardinalidade 0..1 para Promoção). Manter uma tabela separada para a associação seria desnecessário dado que a cardinalidade máxima é 1 (RN23). A FK nullable é a solução mais simples e eficiente.

---

### 2.7 Chave natural vs. chave substituta

| Tabela | Escolha | Justificativa |
|--------|---------|---------------|
| Distribuidora | Substituta (`id_distribuidora`) | CNPJ seria candidata natural, mas chaves compostas de 14 dígitos como FK aumentam o tamanho dos índices em `Filme` |
| Genero | Substituta (`id_genero`) | Nome poderia mudar; FK em `Filme_Genero` ficaria mais leve |
| Filme | Substituta (`id_filme`) | Não há identificador natural universal e imutável para filmes |
| Sala | Substituta (`id_sala`) | Número da sala é único, mas é um dado operacional que pode ser renumerado |
| Sessao | Substituta (`id_sessao`) | Combinação (id_filme, id_sala, data_hora) seria PK natural, mas pesada como FK em `Ingresso` |
| Ingresso | **Natural composta** (id_sessao, numero_assento) | Reflete diretamente a dependência de identificação da entidade fraca; semântica clara |
| Cliente | Substituta (`id_cliente`) | CPF é candidata natural, mas é dado sensível; preferiu-se não expô-lo como FK |
| Funcionario | Substituta (`id_funcionario`) | Mesmo raciocínio do Cliente |
| Promocao | Substituta (`id_promocao`) | Sem identificador natural óbvio |
| Avaliacao | **Natural composta** (id_cliente, id_filme) | Garante unicidade semântica: um cliente avalia um filme no máximo uma vez |
| Filme_Genero | **Natural composta** (id_filme, id_genero) | Par FK forma chave natural adequada para tabela associativa |
