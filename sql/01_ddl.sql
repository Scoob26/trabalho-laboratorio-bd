-- =============================================================================
-- PROJETO FINAL — LABORATÓRIO DE BANCO DE DADOS 2026/2
-- Tema: Sistema de Gerenciamento de Cinema
-- SGBD: MySQL 8.0+
-- Arquivo: 01_ddl.sql
-- Descrição: Script físico DDL — cria o banco e todas as tabelas do zero.
--            Executável em base limpa (DROP + CREATE).
-- =============================================================================

-- Garante execução limpa em base existente
DROP DATABASE IF EXISTS cinema_db;
CREATE DATABASE cinema_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE cinema_db;

-- Desativa verificação de FK durante criação (reativado ao final)
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================================
-- TABELA: Distribuidora
-- Empresa responsável pela distribuição comercial dos filmes.
-- Sem dependências externas — criada primeiro.
-- =============================================================================
CREATE TABLE Distribuidora (
    id_distribuidora  INT            NOT NULL AUTO_INCREMENT,
    nome              VARCHAR(150)   NOT NULL,
    cnpj              CHAR(14)       NOT NULL,
    email             VARCHAR(100)   NULL,
    telefone          VARCHAR(20)    NULL,
    pais_origem       VARCHAR(60)    NOT NULL,

    CONSTRAINT pk_distribuidora     PRIMARY KEY (id_distribuidora),
    CONSTRAINT uq_distribuidora_cnpj UNIQUE (cnpj),
    CONSTRAINT uq_distribuidora_nome UNIQUE (nome),
    -- RN: CNPJ deve ter exatamente 14 dígitos numéricos
    CONSTRAINT ck_distribuidora_cnpj CHECK (cnpj REGEXP '^[0-9]{14}$')
) ENGINE=InnoDB COMMENT='Empresas distribuidoras de filmes. RN01.';


-- =============================================================================
-- TABELA: Genero
-- Gênero cinematográfico com autorrelacionamento para subgêneros.
-- RN04: id_genero_pai NULL indica gênero raiz.
-- =============================================================================
CREATE TABLE Genero (
    id_genero      INT           NOT NULL AUTO_INCREMENT,
    nome           VARCHAR(60)   NOT NULL,
    descricao      VARCHAR(300)  NULL,
    -- Autorrelacionamento: subgênero aponta para seu gênero pai (RN04)
    id_genero_pai  INT           NULL,

    CONSTRAINT pk_genero          PRIMARY KEY (id_genero),
    CONSTRAINT uq_genero_nome     UNIQUE (nome),
    -- FK autorrelacionada: gênero pai deve existir; NULL permitido para raízes
    CONSTRAINT fk_genero_pai
        FOREIGN KEY (id_genero_pai) REFERENCES Genero(id_genero)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Gêneros cinematográficos com hierarquia de subgêneros. RN04.';


-- =============================================================================
-- TABELA: Filme
-- Obra cinematográfica cadastrada no sistema.
-- Depende de: Distribuidora
-- =============================================================================
CREATE TABLE Filme (
    id_filme            INT            NOT NULL AUTO_INCREMENT,
    titulo              VARCHAR(200)   NOT NULL,
    titulo_nacional     VARCHAR(200)   NULL,
    duracao_min         SMALLINT       NOT NULL,
    classificacao_etaria ENUM('Livre','10','12','14','16','18') NOT NULL,
    sinopse             TEXT           NULL,
    data_lancamento     DATE           NOT NULL,
    ativo               TINYINT(1)     NOT NULL DEFAULT 1,
    id_distribuidora    INT            NOT NULL,

    CONSTRAINT pk_filme             PRIMARY KEY (id_filme),
    -- RN03: duração deve ser positiva
    CONSTRAINT ck_filme_duracao     CHECK (duracao_min > 0),
    -- RN02: classificação etária válida (garantida pelo ENUM)
    -- RN01: distribuidora obrigatória
    CONSTRAINT fk_filme_distribuidora
        FOREIGN KEY (id_distribuidora) REFERENCES Distribuidora(id_distribuidora)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Filmes cadastrados no sistema. RN01, RN02, RN03, RN05, RN08.';

-- Índice para buscas por título (LIKE prefixo) e listagem por lançamento
CREATE INDEX idx_filme_titulo       ON Filme (titulo);
CREATE INDEX idx_filme_lancamento   ON Filme (data_lancamento);
CREATE INDEX idx_filme_distribuidora ON Filme (id_distribuidora);


-- =============================================================================
-- TABELA: Filme_Genero
-- Associativa N:N entre Filme e Genero, com atributo próprio.
-- RN04: um filme pode ter múltiplos gêneros; atributo genero_principal.
-- =============================================================================
CREATE TABLE Filme_Genero (
    id_filme          INT         NOT NULL,
    id_genero         INT         NOT NULL,
    -- Atributo próprio da associação N:N (RN04)
    genero_principal  TINYINT(1)  NOT NULL DEFAULT 0,

    CONSTRAINT pk_filme_genero  PRIMARY KEY (id_filme, id_genero),
    CONSTRAINT fk_fg_filme
        FOREIGN KEY (id_filme)  REFERENCES Filme(id_filme)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_fg_genero
        FOREIGN KEY (id_genero) REFERENCES Genero(id_genero)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Relacionamento N:N Filme-Genero com atributo genero_principal. RN04.';


-- =============================================================================
-- TABELA: Sala
-- Sala física de exibição do complexo cinematográfico.
-- RN06: número único; capacidade > 0.
-- RN07: estado controla disponibilidade para sessões.
-- =============================================================================
CREATE TABLE Sala (
    id_sala     INT         NOT NULL AUTO_INCREMENT,
    numero      SMALLINT    NOT NULL,
    capacidade  SMALLINT    NOT NULL,
    tipo        ENUM('2D','3D','IMAX','4DX') NOT NULL DEFAULT '2D',
    estado      ENUM('Ativa','Em Manutenção','Inativa') NOT NULL DEFAULT 'Ativa',

    CONSTRAINT pk_sala          PRIMARY KEY (id_sala),
    -- RN06: número da sala único no complexo
    CONSTRAINT uq_sala_numero   UNIQUE (numero),
    -- RN06: capacidade positiva
    CONSTRAINT ck_sala_capacidade CHECK (capacidade > 0)
) ENGINE=InnoDB COMMENT='Salas físicas do cinema. RN06, RN07.';


-- =============================================================================
-- TABELA: Funcionario
-- Superentidade da especialização Atendente / Gerente.
-- Autorrelacionamento: id_supervisor (RN20).
-- =============================================================================
CREATE TABLE Funcionario (
    id_funcionario  INT            NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(120)   NOT NULL,
    cpf             CHAR(11)       NOT NULL,
    email           VARCHAR(100)   NOT NULL,
    telefone        VARCHAR(20)    NULL,
    data_admissao   DATE           NOT NULL,
    salario         DECIMAL(10,2)  NOT NULL,
    cargo           ENUM('Atendente','Gerente') NOT NULL,
    ativo           TINYINT(1)     NOT NULL DEFAULT 1,
    -- Autorrelacionamento hierárquico (RN20): supervisor direto, nullable
    id_supervisor   INT            NULL,

    CONSTRAINT pk_funcionario       PRIMARY KEY (id_funcionario),
    CONSTRAINT uq_funcionario_cpf   UNIQUE (cpf),
    CONSTRAINT uq_funcionario_email UNIQUE (email),
    -- RN: CPF com 11 dígitos numéricos
    CONSTRAINT ck_funcionario_cpf   CHECK (cpf REGEXP '^[0-9]{11}$'),
    -- RN: salário positivo
    CONSTRAINT ck_funcionario_salario CHECK (salario > 0),
    -- RN20: autorrelacionamento — supervisor deve ser funcionário existente
    CONSTRAINT fk_funcionario_supervisor
        FOREIGN KEY (id_supervisor) REFERENCES Funcionario(id_funcionario)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Funcionários do cinema. Superentidade de Atendente e Gerente. RN19, RN20.';

CREATE INDEX idx_funcionario_cargo      ON Funcionario (cargo);
CREATE INDEX idx_funcionario_supervisor ON Funcionario (id_supervisor);


-- =============================================================================
-- TABELA: Atendente
-- Especialização de Funcionario — funcionário da bilheteria.
-- RN19: estratégia table-per-subclass.
-- =============================================================================
CREATE TABLE Atendente (
    id_funcionario  INT                           NOT NULL,
    turno           ENUM('Manhã','Tarde','Noite') NOT NULL,
    bilheteria      TINYINT                       NOT NULL,

    CONSTRAINT pk_atendente         PRIMARY KEY (id_funcionario),
    CONSTRAINT ck_atendente_bilheteria CHECK (bilheteria > 0),
    -- Chave compartilhada com superentidade (RN19)
    CONSTRAINT fk_atendente_funcionario
        FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Especialização Atendente de Funcionario. RN19.';


-- =============================================================================
-- TABELA: Gerente
-- Especialização de Funcionario — funcionário com poder de gestão.
-- RN19: estratégia table-per-subclass.
-- =============================================================================
CREATE TABLE Gerente (
    id_funcionario        INT          NOT NULL,
    area_responsabilidade VARCHAR(80)  NOT NULL,
    nivel_acesso          TINYINT      NOT NULL DEFAULT 1,

    CONSTRAINT pk_gerente             PRIMARY KEY (id_funcionario),
    CONSTRAINT ck_gerente_nivel       CHECK (nivel_acesso BETWEEN 1 AND 5),
    -- Chave compartilhada com superentidade (RN19)
    CONSTRAINT fk_gerente_funcionario
        FOREIGN KEY (id_funcionario) REFERENCES Funcionario(id_funcionario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Especialização Gerente de Funcionario. RN19.';


-- =============================================================================
-- TABELA: Cliente
-- Pessoa física cadastrada no programa de fidelidade.
-- RN16: CPF único, 11 dígitos.
-- RN17: pontos_fidelidade acumulados por compras.
-- =============================================================================
CREATE TABLE Cliente (
    id_cliente        INT           NOT NULL AUTO_INCREMENT,
    nome              VARCHAR(120)  NOT NULL,
    cpf               CHAR(11)      NOT NULL,
    data_nascimento   DATE          NOT NULL,
    email             VARCHAR(100)  NOT NULL,
    telefone          VARCHAR(20)   NULL,
    pontos_fidelidade INT           NOT NULL DEFAULT 0,
    data_cadastro     DATE          NOT NULL DEFAULT (CURRENT_DATE),

    CONSTRAINT pk_cliente           PRIMARY KEY (id_cliente),
    -- RN16: CPF único e com 11 dígitos numéricos
    CONSTRAINT uq_cliente_cpf       UNIQUE (cpf),
    CONSTRAINT uq_cliente_email     UNIQUE (email),
    CONSTRAINT ck_cliente_cpf       CHECK (cpf REGEXP '^[0-9]{11}$'),
    -- RN17: pontos não podem ser negativos
    CONSTRAINT ck_cliente_pontos    CHECK (pontos_fidelidade >= 0)
) ENGINE=InnoDB COMMENT='Clientes do programa de fidelidade. RN16, RN17, RN18.';

CREATE INDEX idx_cliente_cpf  ON Cliente (cpf);
CREATE INDEX idx_cliente_nome ON Cliente (nome);


-- =============================================================================
-- TABELA: Promocao
-- Promoção com desconto percentual e período de vigência.
-- RN22: desconto entre 1% e 100%; data_fim >= data_inicio.
-- =============================================================================
CREATE TABLE Promocao (
    id_promocao          INT           NOT NULL AUTO_INCREMENT,
    nome                 VARCHAR(100)  NOT NULL,
    descricao            VARCHAR(300)  NULL,
    percentual_desconto  DECIMAL(5,2)  NOT NULL,
    data_inicio          DATE          NOT NULL,
    data_fim             DATE          NOT NULL,

    CONSTRAINT pk_promocao              PRIMARY KEY (id_promocao),
    -- RN22: desconto válido entre 1% e 100%
    CONSTRAINT ck_promocao_desconto     CHECK (percentual_desconto BETWEEN 1.00 AND 100.00),
    -- RN22: período coerente
    CONSTRAINT ck_promocao_datas        CHECK (data_fim >= data_inicio)
) ENGINE=InnoDB COMMENT='Promoções de desconto aplicáveis a ingressos. RN22, RN23, RN24.';

CREATE INDEX idx_promocao_vigencia ON Promocao (data_inicio, data_fim);


-- =============================================================================
-- TABELA: Sessao
-- Exibição de um filme em uma sala em data e hora específicas.
-- RN07, RN08, RN09, RN10, RN11.
-- =============================================================================
CREATE TABLE Sessao (
    id_sessao            INT           NOT NULL AUTO_INCREMENT,
    data_hora_inicio     DATETIME      NOT NULL,
    -- data_hora_fim: desnormalização deliberada para verificação de sobreposição (RN09)
    data_hora_fim        DATETIME      NOT NULL,
    idioma               VARCHAR(30)   NOT NULL,
    valor_ingresso_base  DECIMAL(8,2)  NOT NULL,
    status               ENUM('Agendada','Em Exibição','Encerrada','Cancelada') NOT NULL DEFAULT 'Agendada',
    id_filme             INT           NOT NULL,
    id_sala              INT           NOT NULL,

    CONSTRAINT pk_sessao                PRIMARY KEY (id_sessao),
    -- Valor base positivo
    CONSTRAINT ck_sessao_valor          CHECK (valor_ingresso_base > 0),
    -- Fim deve ser após início
    CONSTRAINT ck_sessao_horario        CHECK (data_hora_fim > data_hora_inicio),
    -- RN08: filme deve existir
    CONSTRAINT fk_sessao_filme
        FOREIGN KEY (id_filme)  REFERENCES Filme(id_filme)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    -- RN07: sala deve existir
    CONSTRAINT fk_sessao_sala
        FOREIGN KEY (id_sala)   REFERENCES Sala(id_sala)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Sessões de exibição. RN07, RN08, RN09, RN10, RN11.';

-- Índice para verificação de sobreposição de horários (RN09)
CREATE INDEX idx_sessao_sala_horario ON Sessao (id_sala, data_hora_inicio, data_hora_fim);
CREATE INDEX idx_sessao_filme        ON Sessao (id_filme);
CREATE INDEX idx_sessao_status       ON Sessao (status);
CREATE INDEX idx_sessao_data         ON Sessao (data_hora_inicio);


-- =============================================================================
-- TABELA: Historico_Status_Sessao
-- Registra cada mudança de status de uma sessão ao longo do tempo.
-- Atributo temporal exigido pelo projeto (RN11).
-- =============================================================================
CREATE TABLE Historico_Status_Sessao (
    id_historico      INT       NOT NULL AUTO_INCREMENT,
    id_sessao         INT       NOT NULL,
    status_anterior   ENUM('Agendada','Em Exibição','Encerrada','Cancelada') NULL,
    status_novo       ENUM('Agendada','Em Exibição','Encerrada','Cancelada') NOT NULL,
    -- Atributo temporal: data e hora exata da mudança de status (RN11)
    data_hora_mudanca DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_funcionario    INT       NULL,

    CONSTRAINT pk_historico_status       PRIMARY KEY (id_historico),
    CONSTRAINT fk_historico_sessao
        FOREIGN KEY (id_sessao)       REFERENCES Sessao(id_sessao)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_historico_funcionario
        FOREIGN KEY (id_funcionario)  REFERENCES Funcionario(id_funcionario)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Histórico temporal de mudanças de status das sessões. RN11.';

CREATE INDEX idx_historico_sessao ON Historico_Status_Sessao (id_sessao);
CREATE INDEX idx_historico_data   ON Historico_Status_Sessao (data_hora_mudanca);


-- =============================================================================
-- TABELA: Ingresso
-- ENTIDADE FRACA de Sessao — identificada por (id_sessao, numero_assento).
-- RN10, RN12, RN13, RN14, RN15, RN23, RN24.
-- =============================================================================
CREATE TABLE Ingresso (
    -- Identificação parcial da entidade fraca (RN12)
    id_sessao       INT           NOT NULL,
    numero_assento  SMALLINT      NOT NULL,
    tipo            ENUM('Inteira','Meia-entrada','Cortesia') NOT NULL,
    -- valor_base: snapshot do preço no momento da venda (desnorm. deliberada — auditoria RN24)
    valor_base      DECIMAL(8,2)  NOT NULL,
    -- valor_final: calculado pela aplicação com desconto de promoção (RN24)
    valor_final     DECIMAL(8,2)  NOT NULL,
    status          ENUM('Reservado','Pago','Cancelado') NOT NULL DEFAULT 'Reservado',
    data_venda      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente      INT           NULL,
    id_funcionario  INT           NULL,
    -- RN23: no máximo uma promoção por ingresso
    id_promocao     INT           NULL,

    -- PK composta — chave de entidade fraca (RN12, RN13)
    CONSTRAINT pk_ingresso              PRIMARY KEY (id_sessao, numero_assento),
    CONSTRAINT ck_ingresso_assento      CHECK (numero_assento > 0),
    CONSTRAINT ck_ingresso_valor_base   CHECK (valor_base >= 0),
    CONSTRAINT ck_ingresso_valor_final  CHECK (valor_final >= 0),
    -- RN14: tipo válido (garantido pelo ENUM)
    -- FK para entidade proprietária (Sessao) — ON DELETE CASCADE (entidade fraca)
    CONSTRAINT fk_ingresso_sessao
        FOREIGN KEY (id_sessao)       REFERENCES Sessao(id_sessao)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- Cliente opcional (venda avulsa sem cadastro)
    CONSTRAINT fk_ingresso_cliente
        FOREIGN KEY (id_cliente)      REFERENCES Cliente(id_cliente)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    -- Atendente que realizou a venda (opcional: pode ser venda online)
    CONSTRAINT fk_ingresso_funcionario
        FOREIGN KEY (id_funcionario)  REFERENCES Funcionario(id_funcionario)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    -- RN23: promoção opcional; no máximo uma
    CONSTRAINT fk_ingresso_promocao
        FOREIGN KEY (id_promocao)     REFERENCES Promocao(id_promocao)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Ingressos — entidade fraca de Sessao. RN10, RN12, RN13, RN14, RN15, RN23, RN24.';

CREATE INDEX idx_ingresso_cliente    ON Ingresso (id_cliente);
CREATE INDEX idx_ingresso_funcionario ON Ingresso (id_funcionario);
CREATE INDEX idx_ingresso_promocao   ON Ingresso (id_promocao);
CREATE INDEX idx_ingresso_data_venda ON Ingresso (data_venda);
CREATE INDEX idx_ingresso_status     ON Ingresso (status);


-- =============================================================================
-- TABELA: Avaliacao
-- Associativa N:N entre Cliente e Filme, com atributos próprios.
-- RN18: cliente só avalia filme que assistiu; nota 1–5.
-- RN21: relacionamento N:N com atributo próprio.
-- =============================================================================
CREATE TABLE Avaliacao (
    id_cliente      INT       NOT NULL,
    id_filme        INT       NOT NULL,
    -- Atributos próprios da associação N:N (RN21)
    nota            TINYINT   NOT NULL,
    comentario      TEXT      NULL,
    -- Atributo temporal da associação (RN18)
    data_avaliacao  DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_avaliacao         PRIMARY KEY (id_cliente, id_filme),
    -- RN18: nota entre 1 e 5
    CONSTRAINT ck_avaliacao_nota    CHECK (nota BETWEEN 1 AND 5),
    CONSTRAINT fk_avaliacao_cliente
        FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_filme
        FOREIGN KEY (id_filme)   REFERENCES Filme(id_filme)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Avaliações de filmes por clientes. N:N com atributos. RN18, RN21.';

CREATE INDEX idx_avaliacao_filme ON Avaliacao (id_filme);
CREATE INDEX idx_avaliacao_nota  ON Avaliacao (nota);


-- =============================================================================
-- TRIGGER: trg_verifica_capacidade
-- Impede que o número de ingressos vendidos/reservados supere a capacidade da sala.
-- RN10.
-- =============================================================================
CREATE TRIGGER trg_verifica_capacidade
BEFORE INSERT ON Ingresso
FOR EACH ROW
BEGIN
    DECLARE v_capacidade    SMALLINT;
    DECLARE v_vendidos      INT;
    DECLARE v_id_sala       INT;

    -- Obtém a capacidade da sala via sessão
    SELECT s.id_sala, sa.capacidade
    INTO v_id_sala, v_capacidade
    FROM Sessao s
    JOIN Sala sa ON sa.id_sala = s.id_sala
    WHERE s.id_sessao = NEW.id_sessao;

    -- Conta ingressos ativos (não cancelados) para a sessão
    SELECT COUNT(*) INTO v_vendidos
    FROM Ingresso
    WHERE id_sessao = NEW.id_sessao
      AND status <> 'Cancelado';

    -- RN10: bloqueia se já atingiu a capacidade máxima
    IF v_vendidos >= v_capacidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Capacidade da sala esgotada para esta sessão. (RN10)';
    END IF;
END;


-- =============================================================================
-- TRIGGER: trg_registra_historico_sessao
-- Registra automaticamente no histórico cada mudança de status de uma sessão.
-- RN11.
-- =============================================================================
CREATE TRIGGER trg_registra_historico_sessao
AFTER UPDATE ON Sessao
FOR EACH ROW
BEGIN
    -- Só registra se o status realmente mudou
    IF OLD.status <> NEW.status THEN
        INSERT INTO Historico_Status_Sessao
            (id_sessao, status_anterior, status_novo, data_hora_mudanca, id_funcionario)
        VALUES
            (NEW.id_sessao, OLD.status, NEW.status, NOW(), NULL);
    END IF;
END;


-- Reativa verificação de FK
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- VIEW: vw_fidelidade_clientes
-- Consolida dados de fidelidade de cada cliente: pontos acumulados,
-- total de ingressos pagos e valor total gasto.
-- Usada pelo relatório de fidelidade da aplicação Java (ClienteDAO).
-- =============================================================================
CREATE OR REPLACE VIEW vw_fidelidade_clientes AS
SELECT
    c.id_cliente,
    c.nome,
    c.cpf,
    c.email,
    c.telefone,
    c.pontos_fidelidade,
    c.data_cadastro,
    COUNT(i.numero_assento)          AS total_ingressos_pagos,
    COALESCE(SUM(i.valor_final), 0)  AS total_gasto
FROM Cliente c
LEFT JOIN Ingresso i
       ON i.id_cliente = c.id_cliente
      AND i.status     = 'Pago'
GROUP BY
    c.id_cliente, c.nome, c.cpf, c.email,
    c.telefone, c.pontos_fidelidade, c.data_cadastro;


-- =============================================================================
-- FIM DO SCRIPT DDL
-- Para testar: execute este arquivo em base limpa e verifique com:
--   SHOW TABLES;
--   SHOW VIEWS;
--   SHOW CREATE TABLE Ingresso;
-- =============================================================================
