# A5 — Verificação de Normalização (3FN)

## Metodologia

Para cada relação, são listadas as dependências funcionais relevantes identificadas, verificada a 1FN, 2FN e 3FN, e indicado quando a relação atinge a Forma Normal de Boyce-Codd (FNBC).

---

## Distribuidora

**Dependências funcionais:**
- `id_distribuidora → nome, cnpj, email, telefone, pais_origem`
- `cnpj → id_distribuidora, nome, email, telefone, pais_origem` (chave candidata)
- `nome → id_distribuidora, cnpj, email, telefone, pais_origem` (chave candidata)

**1FN:** ✅ Todos os atributos são atômicos e monovalorados. Sem grupos repetidos.  
**2FN:** ✅ PK é simples (`id_distribuidora`); toda dependência parcial é impossível.  
**3FN:** ✅ Não há dependência transitiva: nenhum atributo não-chave determina outro atributo não-chave.  
**FNBC:** ✅ Todo determinante (`id_distribuidora`, `cnpj`, `nome`) é superchave.

---

## Genero

**Dependências funcionais:**
- `id_genero → nome, descricao, id_genero_pai`
- `nome → id_genero, descricao, id_genero_pai` (chave candidata)

**1FN:** ✅ Atributos atômicos. O autorrelacionamento `id_genero_pai` é uma FK simples, não um atributo multivalorado.  
**2FN:** ✅ PK simples.  
**3FN:** ✅ Sem transitivas: `id_genero_pai` é FK (chave estrangeira), não uma dependência transitiva entre atributos não-chave.  
**FNBC:** ✅ Todo determinante é superchave.

---

## Filme

**Dependências funcionais:**
- `id_filme → titulo, titulo_nacional, duracao_min, classificacao_etaria, sinopse, data_lancamento, ativo, id_distribuidora`

**1FN:** ✅ Atributos atômicos. Os gêneros foram removidos para `Filme_Genero`, eliminando grupos repetidos.  
**2FN:** ✅ PK simples.  
**3FN:** ✅ Não há transitivas. `id_distribuidora` é FK — não há dependência `id_distribuidora → classificacao_etaria` ou similar dentro desta tabela.  
**FNBC:** ✅

---

## Filme_Genero

**Dependências funcionais:**
- `(id_filme, id_genero) → genero_principal`

**1FN:** ✅ PK composta; todos os atributos atômicos.  
**2FN:** ✅ O único atributo não-chave (`genero_principal`) depende da chave composta completa — não apenas de `id_filme` ou apenas de `id_genero`.  
**3FN:** ✅ Sem transitivas: nenhum atributo não-chave determina outro.  
**FNBC:** ✅ O único determinante é a PK composta, que é superchave.

---

## Sala

**Dependências funcionais:**
- `id_sala → numero, capacidade, tipo, estado`
- `numero → id_sala, capacidade, tipo, estado` (chave candidata)

**1FN:** ✅  
**2FN:** ✅ PK simples.  
**3FN:** ✅ Sem transitivas.  
**FNBC:** ✅ Determinantes `id_sala` e `numero` são superchaves.

---

## Sessao

**Dependências funcionais identificadas:**
- `id_sessao → data_hora_inicio, idioma, valor_ingresso_base, status, id_filme, id_sala`
- `(id_sala, data_hora_inicio) → id_sessao` (chave candidata natural)
- `id_sessao → data_hora_fim` — *desnormalização deliberada* (ver abaixo)

**1FN:** ✅ Todos os atributos são atômicos e monovalorados.  
**2FN:** ✅ A PK é simples (`id_sessao`); dependências parciais são impossíveis.  
**3FN:** ✅ Não há dependência transitiva entre atributos não-chave genuínos — `id_filme` e `id_sala` são FKs, não determinantes de outros atributos não-chave dentro desta tabela.

> **Desnormalização deliberada — `data_hora_fim`:**  
> `data_hora_fim` pode ser derivado de `data_hora_inicio + Filme.duracao_min`, portanto é tecnicamente uma dependência derivada que "vaza" do escopo da relação `Sessao`. Isso **não é uma violação da 2FN nem da 3FN** dentro desta relação — 2FN e 3FN tratam de dependências *entre atributos não-chave*, e `data_hora_fim` depende da PK `id_sessao` (via `id_filme` e `data_hora_inicio`). A questão é de **desnormalização entre relações**: armazenar o valor calculado em `Sessao` em vez de sempre buscá-lo via JOIN com `Filme`.  
> **Justificativa:** a verificação de sobreposição de horários (RN09) é executada a cada INSERT de sessão, em alta frequência. Armazenar `data_hora_fim` diretamente elimina o join com `Filme` nessa operação crítica. A consistência é garantida pela aplicação no momento da criação da sessão.  
> **Consequência documentada:** se `Filme.duracao_min` for alterado após a criação da sessão, `Sessao.data_hora_fim` **não** é atualizado automaticamente. A equipe aceita essa troca consciente entre consistência e desempenho.

**FNBC:** ✅ Todo determinante dentro da relação é superchave.

---

## Historico_Status_Sessao

**Dependências funcionais:**
- `id_historico → id_sessao, status_anterior, status_novo, data_hora_mudanca, id_funcionario`

**1FN:** ✅  
**2FN:** ✅ PK simples.  
**3FN:** ✅ Sem transitivas.  
**FNBC:** ✅

---

## Cliente

**Dependências funcionais:**
- `id_cliente → nome, cpf, data_nascimento, email, telefone, pontos_fidelidade, data_cadastro`
- `cpf → id_cliente` (chave candidata)
- `email → id_cliente` (chave candidata)

**1FN:** ✅  
**2FN:** ✅ PK simples.  
**3FN:** ✅ Sem transitivas entre atributos não-chave.  
**FNBC:** ✅ Determinantes `id_cliente`, `cpf` e `email` são todos superchaves.

---

## Funcionario

**Dependências funcionais:**
- `id_funcionario → nome, cpf, email, telefone, data_admissao, salario, cargo, ativo, id_supervisor`
- `cpf → id_funcionario` (chave candidata)
- `email → id_funcionario` (chave candidata)

**1FN:** ✅ `cargo` é atômico (ENUM). Atributos de especialização foram removidos para `Atendente`/`Gerente`.  
**2FN:** ✅ PK simples.  
**3FN:** ✅ `id_supervisor` é FK autorreferenciada — não é transitiva pois não determina atributos não-chave de `Funcionario`.  
**FNBC:** ✅

---

## Atendente

**Dependências funcionais:**
- `id_funcionario → turno, bilheteria`

**1FN:** ✅  
**2FN:** ✅ PK simples (id_funcionario, herdado).  
**3FN:** ✅ Nenhum atributo não-chave determina outro.  
**FNBC:** ✅

---

## Gerente

**Dependências funcionais:**
- `id_funcionario → area_responsabilidade, nivel_acesso`

**1FN:** ✅  
**2FN:** ✅  
**3FN:** ✅  
**FNBC:** ✅

---

## Promocao

**Dependências funcionais:**
- `id_promocao → nome, descricao, percentual_desconto, data_inicio, data_fim`
- `nome → id_promocao` (chave candidata, assumindo nomes únicos)

**1FN:** ✅  
**2FN:** ✅ PK simples.  
**3FN:** ✅ Não há dependência `data_fim → percentual_desconto` ou similar.  
**FNBC:** ✅

---

## Ingresso

**Dependências funcionais identificadas:**
- `(id_sessao, numero_assento) → tipo, status, data_venda, id_cliente, id_funcionario, id_promocao`
- `(id_sessao, numero_assento) → valor_base` — *desnormalização deliberada* (ver abaixo)
- `(id_sessao, numero_assento) → valor_final` — *desnormalização deliberada* (ver abaixo)

**1FN:** ✅ PK composta; todos os atributos são atômicos e monovalorados.

**Nota sobre 2FN e 3FN para os atributos derivados:**  
`valor_base` poderia ser obtido via join com `Sessao.valor_ingresso_base` — portanto há uma dependência `id_sessao → valor_base` (parcial em relação à PK composta). Da mesma forma, `valor_final` é calculado a partir de `valor_base`, `tipo` e `id_promocao`.  
Formalmente, **`valor_base` viola a 2FN** e **`valor_final` viola a 3FN** se tratados como atributos normais. A equipe optou conscientemente por não normalizar esses dois atributos. Essa é uma **desnormalização deliberada**, aceita por razão técnica clara:

> **Desnormalização deliberada — `valor_base` e `valor_final`:**  
> Ambas as colunas armazenam um *snapshot* dos valores no momento exato da venda. Se `Sessao.valor_ingresso_base` for alterado após a venda, os relatórios históricos de receita continuarão corretos — não distorcidos pelo novo preço. Isso é prática padrão em sistemas de bilheteria e e-commerce (imutabilidade do registro de venda).  
> A presença intencional dessas colunas foi avaliada e documentada como escolha de projeto físico. A relação **não está em 2FN nem em 3FN** para esses dois atributos, e isso é **aceito e justificado**.

**FNBC:** não se aplica para `valor_base` e `valor_final` pelos mesmos motivos acima. Os demais atributos (`tipo`, `status`, `data_venda`, `id_cliente`, `id_funcionario`, `id_promocao`) dependem da PK composta completa e não apresentam violações.

---

## Avaliacao

**Dependências funcionais:**
- `(id_cliente, id_filme) → nota, comentario, data_avaliacao`

**1FN:** ✅  
**2FN:** ✅ `nota`, `comentario` e `data_avaliacao` dependem da chave composta completa — não há atributo que dependa apenas de `id_cliente` ou apenas de `id_filme`.  
**3FN:** ✅ Sem transitivas.  
**FNBC:** ✅ O único determinante é a PK composta.

---

## Resumo Geral

| Relação | 1FN | 2FN | 3FN | FNBC | Desnormalização |
|---------|:---:|:---:|:---:|:----:|-----------------|
| Distribuidora | ✅ | ✅ | ✅ | ✅ | — |
| Genero | ✅ | ✅ | ✅ | ✅ | — |
| Filme | ✅ | ✅ | ✅ | ✅ | — |
| Filme_Genero | ✅ | ✅ | ✅ | ✅ | — |
| Sala | ✅ | ✅ | ✅ | ✅ | — |
| Sessao | ✅ | ✅ | ✅ | ✅ | `data_hora_fim`: derivado de `Filme.duracao_min` + `data_hora_inicio`; armazenado por desempenho (RN09) |
| Historico_Status_Sessao | ✅ | ✅ | ✅ | ✅ | — |
| Cliente | ✅ | ✅ | ✅ | ✅ | — |
| Funcionario | ✅ | ✅ | ✅ | ✅ | — |
| Atendente | ✅ | ✅ | ✅ | ✅ | — |
| Gerente | ✅ | ✅ | ✅ | ✅ | — |
| Promocao | ✅ | ✅ | ✅ | ✅ | — |
| Ingresso | ✅ | ⚠️ | ⚠️ | ⚠️ | `valor_base` viola 2FN; `valor_final` viola 3FN — ambos desnormalizados deliberadamente (auditoria financeira) |
| Avaliacao | ✅ | ✅ | ✅ | ✅ | — |

> ⚠️ = violação formal identificada, aceita e justificada como desnormalização deliberada de projeto físico.

**Conclusão:** 13 das 14 relações estão na **Terceira Forma Normal (3FN)** e atingem a **Forma Normal de Boyce-Codd (FNBC)**. A relação `Ingresso` está em **1FN**, mas apresenta desnormalizações documentadas nos atributos `valor_base` (viola 2FN: dependência parcial de `id_sessao`) e `valor_final` (viola 3FN: dependência transitiva via `valor_base` e `id_promocao`). Essas escolhas são intencionais, com justificativa técnica clara — imutabilidade do registro de venda para auditoria financeira — e são práticas padrão em sistemas de bilheteria e e-commerce.

A relação `Sessao` está em 3FN/FNBC dentro de seus próprios limites; o atributo `data_hora_fim` representa uma **desnormalização entre relações** (valor derivável via join com `Filme`), aceita por razão de desempenho em operação crítica.
