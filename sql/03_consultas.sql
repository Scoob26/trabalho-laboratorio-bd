-- =============================================================================
-- PROJETO FINAL — LABORATÓRIO DE BANCO DE DADOS 2026/2
-- Tema: Sistema de Gerenciamento de Cinema
-- SGBD: MySQL 8.0+
-- Arquivo: 03_consultas.sql
-- Descrição: 15 consultas de verificação comentadas.
--            Deve ser executado APÓS 01_ddl.sql e 02_carga.sql.
--
-- Distribuição:
--   Q01–Q05: Básicas (projeção, WHERE, ORDER BY, LIKE, BETWEEN, IN, NULL)
--   Q06–Q10: Junções e Agregação (3 tabelas, LEFT JOIN, GROUP BY, HAVING)
--   Q11–Q15: Avançadas (subconsulta correlacionada, EXISTS, negócio não trivial)
-- =============================================================================

USE cinema_db;

-- =============================================================================
-- CATEGORIA 1 — BÁSICAS (Q01 a Q05)
-- =============================================================================

-- ----------------------------------------------------------------------------
-- Q01 — Projeção e ordenação
-- Pergunta de negócio: Quais filmes ativos estão cadastrados no sistema,
--                      ordenados por data de lançamento mais recente?
-- Técnicas: projeção de colunas específicas, WHERE, ORDER BY DESC
-- ----------------------------------------------------------------------------
SELECT
    f.id_filme,
    f.titulo,
    f.titulo_nacional,
    f.duracao_min,
    f.classificacao_etaria,
    f.data_lancamento
FROM Filme f
WHERE f.ativo = 1
ORDER BY f.data_lancamento DESC;


-- ----------------------------------------------------------------------------
-- Q02 — Seleção com LIKE e BETWEEN
-- Pergunta de negócio: Quais filmes têm duração entre 90 e 130 minutos
--                      e título que começa com as letras 'G', 'E' ou 'F'?
-- Técnicas: BETWEEN, LIKE com OR, WHERE composto
-- ----------------------------------------------------------------------------
SELECT
    f.titulo,
    f.titulo_nacional,
    f.duracao_min,
    f.classificacao_etaria
FROM Filme f
WHERE f.duracao_min BETWEEN 90 AND 130
  AND (
      f.titulo LIKE 'G%'
   OR f.titulo LIKE 'E%'
   OR f.titulo LIKE 'F%'
  )
ORDER BY f.duracao_min ASC;


-- ----------------------------------------------------------------------------
-- Q03 — Uso de IN e tratamento de NULL
-- Pergunta de negócio: Quais clientes possuem pontos de fidelidade em uma
--                      das faixas de interesse (0, 50, 75, 150, 300), e
--                      têm ou não têm telefone cadastrado?
-- Técnicas: IN, IS NULL / IS NOT NULL, CASE para legibilidade
-- Nota: a tabela Cliente não possui coluna de cidade; o filtro é feito
--       exclusivamente pela faixa de pontos de fidelidade.
-- ----------------------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome,
    c.cpf,
    c.pontos_fidelidade,
    CASE
        WHEN c.telefone IS NULL THEN 'Sem telefone cadastrado'
        ELSE c.telefone
    END AS contato,
    c.data_cadastro
FROM Cliente c
WHERE c.pontos_fidelidade IN (0, 50, 75, 150, 300)
ORDER BY c.pontos_fidelidade DESC, c.nome ASC;


-- ----------------------------------------------------------------------------
-- Q04 — Seleção com LIKE e NULL em tabela de sessões
-- Pergunta de negócio: Quais sessões agendadas estão previstas para outubro
--                      de 2026, exibindo filmes em idioma que contenha 'Inglês'?
-- Técnicas: LIKE, BETWEEN com datas, filtro de status, ORDER BY
-- ----------------------------------------------------------------------------
SELECT
    s.id_sessao,
    f.titulo                              AS filme,
    sa.numero                             AS sala,
    sa.tipo                               AS tecnologia,
    s.idioma,
    s.data_hora_inicio,
    s.valor_ingresso_base
FROM Sessao s
JOIN Filme f  ON f.id_filme = s.id_filme
JOIN Sala  sa ON sa.id_sala = s.id_sala
WHERE s.status = 'Agendada'
  AND s.data_hora_inicio BETWEEN '2026-10-01 00:00:00' AND '2026-10-31 23:59:59'
  AND s.idioma LIKE '%Inglês%'
ORDER BY s.data_hora_inicio ASC;


-- ----------------------------------------------------------------------------
-- Q05 — Projeção com status específicos e NULL
-- Pergunta de negócio: Quais ingressos estão com status Cancelado ou
--                      Reservado, ou foram vendidos sem vínculo a um
--                      cliente cadastrado (venda avulsa)?
-- Técnicas: IN, IS NULL, CASE, ORDER BY múltiplo
-- ----------------------------------------------------------------------------
SELECT
    i.id_sessao,
    i.numero_assento,
    i.tipo,
    i.valor_final,
    i.status,
    i.data_venda,
    CASE
        WHEN i.id_cliente IS NULL THEN 'Venda avulsa'
        ELSE CAST(i.id_cliente AS CHAR)
    END AS cliente,
    CASE
        WHEN i.id_funcionario IS NULL THEN 'Venda online'
        ELSE CAST(i.id_funcionario AS CHAR)
    END AS canal_venda
FROM Ingresso i
WHERE i.status IN ('Cancelado', 'Reservado')
   OR i.id_cliente IS NULL
ORDER BY i.status ASC, i.data_venda DESC;


-- =============================================================================
-- CATEGORIA 2 — JUNÇÕES E AGREGAÇÃO (Q06 a Q10)
-- =============================================================================

-- ----------------------------------------------------------------------------
-- Q06 — Junção de cinco tabelas
-- Pergunta de negócio: Qual é o detalhamento completo de cada ingresso pago,
--                      mostrando o filme exibido, a sala, o nome do cliente
--                      e o atendente responsável pela venda?
-- Técnicas: JOIN de 5 tabelas (Ingresso, Sessao, Filme, Sala, Cliente,
--           Funcionario), LEFT JOIN para cliente e funcionário opcionais,
--           COALESCE para tratar vendas avulsas e online
-- ----------------------------------------------------------------------------
SELECT
    f.titulo                              AS filme,
    sa.numero                             AS sala,
    sa.tipo                               AS tecnologia,
    s.data_hora_inicio                    AS data_sessao,
    i.numero_assento                      AS assento,
    i.tipo                                AS tipo_ingresso,
    i.valor_final,
    COALESCE(c.nome, 'Avulso')            AS cliente,
    COALESCE(func.nome, 'Online')         AS atendente
FROM Ingresso i
JOIN Sessao    s    ON s.id_sessao      = i.id_sessao
JOIN Filme     f    ON f.id_filme       = s.id_filme
JOIN Sala      sa   ON sa.id_sala       = s.id_sala
LEFT JOIN Cliente  c    ON c.id_cliente    = i.id_cliente
LEFT JOIN Funcionario func ON func.id_funcionario = i.id_funcionario
WHERE i.status = 'Pago'
ORDER BY s.data_hora_inicio ASC, i.numero_assento ASC;


-- ----------------------------------------------------------------------------
-- Q07 — LEFT JOIN para identificar entidades sem relacionamento
-- Pergunta de negócio: Quais filmes ativos ainda NÃO receberam nenhuma
--                      avaliação de clientes?
-- Técnicas: LEFT JOIN, IS NULL no lado direito (anti-join pattern)
-- ----------------------------------------------------------------------------
SELECT
    f.id_filme,
    f.titulo,
    f.classificacao_etaria,
    f.data_lancamento,
    d.nome                                AS distribuidora
FROM Filme f
LEFT JOIN Avaliacao a ON a.id_filme = f.id_filme
JOIN Distribuidora  d ON d.id_distribuidora = f.id_distribuidora
WHERE f.ativo = 1
  AND a.id_filme IS NULL
ORDER BY f.data_lancamento DESC;


-- ----------------------------------------------------------------------------
-- Q08 — GROUP BY com contagem e soma
-- Pergunta de negócio: Qual é a receita total e o número de ingressos
--                      vendidos por sessão, ordenados pela maior receita?
-- Técnicas: GROUP BY, SUM, COUNT, JOIN, ORDER BY agregado
-- ----------------------------------------------------------------------------
SELECT
    s.id_sessao,
    f.titulo                              AS filme,
    sa.numero                             AS sala,
    s.data_hora_inicio,
    COUNT(i.numero_assento)               AS total_ingressos_pagos,
    SUM(i.valor_final)                    AS receita_total,
    AVG(i.valor_final)                    AS ticket_medio
FROM Sessao s
JOIN Filme    f  ON f.id_filme  = s.id_filme
JOIN Sala     sa ON sa.id_sala  = s.id_sala
JOIN Ingresso i  ON i.id_sessao = s.id_sessao
WHERE i.status = 'Pago'
GROUP BY s.id_sessao, f.titulo, sa.numero, s.data_hora_inicio
ORDER BY receita_total DESC;


-- ----------------------------------------------------------------------------
-- Q09 — GROUP BY com HAVING (filtro pós-agregação)
-- Pergunta de negócio: Quais clientes compraram mais de 3 ingressos pagos
--                      no total, e qual é o valor total gasto por cada um?
-- Técnicas: GROUP BY, COUNT, SUM, HAVING, JOIN
-- ----------------------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome,
    c.email,
    c.pontos_fidelidade,
    COUNT(i.numero_assento)               AS total_ingressos,
    SUM(i.valor_final)                    AS total_gasto
FROM Cliente c
JOIN Ingresso i ON i.id_cliente = c.id_cliente
WHERE i.status = 'Pago'
GROUP BY c.id_cliente, c.nome, c.email, c.pontos_fidelidade
HAVING COUNT(i.numero_assento) > 3
ORDER BY total_gasto DESC;


-- ----------------------------------------------------------------------------
-- Q10 — Agregação com múltiplos grupos e JOIN
-- Pergunta de negócio: Qual é a nota média, maior nota e menor nota de cada
--                      filme que recebeu avaliações, incluindo quantas
--                      avaliações têm comentário e quantas não têm?
-- Técnicas: GROUP BY, AVG, MAX, MIN, COUNT, SUM com CASE, JOIN, HAVING
-- Nota: usa JOIN simples (não LEFT JOIN) — só retorna filmes com ao menos
--       uma avaliação; o HAVING COUNT >= 1 é redundante mas explícito.
-- ----------------------------------------------------------------------------
SELECT
    f.titulo,
    f.classificacao_etaria,
    COUNT(a.id_cliente)                              AS total_avaliacoes,
    ROUND(AVG(a.nota), 2)                            AS nota_media,
    MAX(a.nota)                                      AS nota_maxima,
    MIN(a.nota)                                      AS nota_minima,
    SUM(CASE WHEN a.comentario IS NOT NULL THEN 1 ELSE 0 END) AS com_comentario,
    SUM(CASE WHEN a.comentario IS NULL     THEN 1 ELSE 0 END) AS sem_comentario
FROM Filme f
JOIN Avaliacao a ON a.id_filme = f.id_filme
GROUP BY f.id_filme, f.titulo, f.classificacao_etaria
HAVING COUNT(a.id_cliente) >= 1
ORDER BY nota_media DESC, total_avaliacoes DESC;


-- =============================================================================
-- CATEGORIA 3 — AVANÇADAS (Q11 a Q15)
-- =============================================================================

-- ----------------------------------------------------------------------------
-- Q11 — Subconsulta correlacionada
-- Pergunta de negócio: Quais clientes gastaram acima da média geral de
--                      gasto por cliente no cinema?
-- Técnicas: subconsulta correlacionada no WHERE, GROUP BY interno,
--           comparação com subquery escalar
-- ----------------------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome,
    c.email,
    c.pontos_fidelidade,
    (
        SELECT COALESCE(SUM(i2.valor_final), 0)
        FROM Ingresso i2
        WHERE i2.id_cliente = c.id_cliente
          AND i2.status = 'Pago'
    ) AS total_gasto_cliente
FROM Cliente c
WHERE (
    SELECT COALESCE(SUM(i2.valor_final), 0)
    FROM Ingresso i2
    WHERE i2.id_cliente = c.id_cliente
      AND i2.status = 'Pago'
) > (
    -- Subquery escalar: média de gasto entre todos os clientes com compra
    SELECT AVG(gasto_por_cliente)
    FROM (
        SELECT SUM(i3.valor_final) AS gasto_por_cliente
        FROM Ingresso i3
        WHERE i3.status = 'Pago'
          AND i3.id_cliente IS NOT NULL
        GROUP BY i3.id_cliente
    ) AS sub_gastos
)
ORDER BY total_gasto_cliente DESC;


-- ----------------------------------------------------------------------------
-- Q12 — EXISTS
-- Pergunta de negócio: Quais salas têm pelo menos uma sessão agendada para
--                      os próximos 7 dias a partir de 01/10/2026?
-- Técnicas: EXISTS com subconsulta correlacionada, filtro de data fixo
-- Nota: usa datas fixas (dentro do intervalo da carga) em vez de NOW()
--       para garantir resultado determinístico na execução do script.
-- ----------------------------------------------------------------------------
SELECT
    sa.id_sala,
    sa.numero,
    sa.tipo,
    sa.capacidade,
    sa.estado
FROM Sala sa
WHERE sa.estado = 'Ativa'
  AND EXISTS (
      SELECT 1
      FROM Sessao s
      WHERE s.id_sala = sa.id_sala
        AND s.status  = 'Agendada'
        AND s.data_hora_inicio BETWEEN '2026-10-01 00:00:00'
                                   AND '2026-10-08 23:59:59'
  )
ORDER BY sa.numero ASC;


-- ----------------------------------------------------------------------------
-- Q13 — Pergunta de negócio não trivial: ocupação das sessões
-- Pergunta de negócio: Qual é a taxa de ocupação (%) de cada sessão já
--                      encerrada, considerando apenas ingressos pagos em
--                      relação à capacidade total da sala?
-- Técnicas: JOIN de 4 tabelas, subquery agregada, cálculo de percentual,
--           FORMAT, ORDER BY por taxa decrescente
-- ----------------------------------------------------------------------------
SELECT
    s.id_sessao,
    f.titulo                                         AS filme,
    sa.numero                                        AS sala,
    sa.capacidade,
    s.data_hora_inicio,
    COALESCE(vendas.qtd_pagos, 0)                    AS ingressos_pagos,
    ROUND(
        (COALESCE(vendas.qtd_pagos, 0) / sa.capacidade) * 100
    , 1)                                             AS taxa_ocupacao_pct
FROM Sessao s
JOIN Filme f  ON f.id_filme  = s.id_filme
JOIN Sala  sa ON sa.id_sala  = s.id_sala
LEFT JOIN (
    SELECT id_sessao, COUNT(*) AS qtd_pagos
    FROM Ingresso
    WHERE status = 'Pago'
    GROUP BY id_sessao
) AS vendas ON vendas.id_sessao = s.id_sessao
WHERE s.status = 'Encerrada'
ORDER BY taxa_ocupacao_pct DESC;


-- ----------------------------------------------------------------------------
-- Q14 — Subconsulta correlacionada + negócio: hierarquia de funcionários
-- Pergunta de negócio: Quais funcionários ativos supervisionam outros
--                      funcionários, e quantos supervisionados cada um tem?
-- Técnicas: subconsulta correlacionada no SELECT, JOIN com autojoins,
--           filtragem de supervisores com subordinados
-- ----------------------------------------------------------------------------
SELECT
    sup.id_funcionario                               AS id_supervisor,
    sup.nome                                         AS nome_supervisor,
    sup.cargo,
    (
        SELECT COUNT(*)
        FROM Funcionario sub
        WHERE sub.id_supervisor = sup.id_funcionario
          AND sub.ativo = 1
    )                                                AS qtd_supervisionados,
    GROUP_CONCAT(sub.nome ORDER BY sub.nome SEPARATOR ', ')
                                                     AS nomes_supervisionados
FROM Funcionario sup
JOIN Funcionario sub ON sub.id_supervisor = sup.id_funcionario
WHERE sup.ativo = 1
  AND sub.ativo = 1
GROUP BY sup.id_funcionario, sup.nome, sup.cargo
ORDER BY qtd_supervisionados DESC;


-- ----------------------------------------------------------------------------
-- Q15 — Pergunta de negócio não trivial: clientes elegíveis para avaliação
-- Pergunta de negócio: Quais clientes assistiram a um filme (têm ingresso
--                      pago em sessão desse filme) mas ainda NÃO avaliaram
--                      esse filme — i.e., têm o direito de avaliar pendente?
-- Técnicas: NOT EXISTS com subconsulta correlacionada dupla, JOIN de
--           múltiplas tabelas, DISTINCT
-- RN18: cliente só pode avaliar se tiver assistido; aqui identificamos
--       quem pode mas ainda não avaliou.
-- ----------------------------------------------------------------------------
SELECT DISTINCT
    c.id_cliente,
    c.nome                                           AS cliente,
    f.id_filme,
    f.titulo                                         AS filme_assistido,
    MIN(s.data_hora_inicio)                          AS primeira_sessao_assistida
FROM Cliente  c
JOIN Ingresso i  ON i.id_cliente = c.id_cliente
JOIN Sessao   s  ON s.id_sessao  = i.id_sessao
JOIN Filme    f  ON f.id_filme   = s.id_filme
WHERE i.status = 'Pago'
  -- NOT EXISTS: ainda não avaliou este filme específico (RN18)
  AND NOT EXISTS (
      SELECT 1
      FROM Avaliacao a
      WHERE a.id_cliente = c.id_cliente
        AND a.id_filme   = f.id_filme
  )
GROUP BY c.id_cliente, c.nome, f.id_filme, f.titulo
ORDER BY c.nome ASC, f.titulo ASC;


-- =============================================================================
-- FIM DAS CONSULTAS
-- =============================================================================
