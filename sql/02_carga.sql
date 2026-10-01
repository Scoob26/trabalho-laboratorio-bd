-- =============================================================================
-- PROJETO FINAL — LABORATÓRIO DE BANCO DE DADOS 2026/2
-- Tema: Sistema de Gerenciamento de Cinema
-- SGBD: MySQL 8.0+
-- Arquivo: 02_carga.sql
-- Descrição: Script de carga DML com dados fictícios e realistas.
--            Deve ser executado APÓS 01_ddl.sql (ordem de dependência já
--            respeitada — FK_CHECKS não é desativado).
--            Volume: todas as tabelas principais >= 40 linhas;
--                    Ingresso >= 110 linhas.
--            Inclui casos de contorno: NULLs opcionais, históricos múltiplos,
--            ingressos cancelados, sessões em diferentes status,
--            clientes sem telefone, filmes sem sinopse, promoções vencidas.
-- =============================================================================

USE cinema_db;

-- =============================================================================
-- 1. DISTRIBUIDORA (40 registros)
-- =============================================================================
INSERT INTO Distribuidora (nome, cnpj, email, telefone, pais_origem) VALUES
('Universal Pictures Brasil',        '12345678000101', 'contato@universal.com.br',        '(11) 3000-1001', 'Brasil'),
('Warner Bros. Entertainment',       '23456789000102', 'contato@warnerbros.com.br',       '(11) 3000-1002', 'EUA'),
('Walt Disney Studios Brasil',       '34567890000103', 'contato@disney.com.br',           '(11) 3000-1003', 'Brasil'),
('Sony Pictures Releasing',          '45678901000104', 'contato@sony.com.br',             '(11) 3000-1004', 'EUA'),
('Paramount Pictures Brasil',        '56789012000105', 'contato@paramount.com.br',        NULL,             'Brasil'),
('A24 Internacional',                '67890123000106', 'contato@a24films.com',            NULL,             'EUA'),
('Miramax Filmes',                   '78901234000107', 'contato@miramax.com.br',          '(11) 3000-1007', 'EUA'),
('Imagem Filmes',                    '89012345000108', 'contato@imagem.com.br',           '(21) 3000-1008', 'Brasil'),
('Lionsgate Brasil',                 '90123456000109', 'contato@lionsgate.com.br',        '(11) 3000-1009', 'EUA'),
('Focus Features',                   '01234567000110', 'contato@focusfeatures.com.br',    NULL,             'EUA'),
('Buena Vista International',        '11234567000111', 'contato@buenavista.com.br',       '(11) 3000-1011', 'EUA'),
('20th Century Studios Brasil',      '21234567000112', 'contato@20thcentury.com.br',      '(11) 3000-1012', 'EUA'),
('DreamWorks Animation',             '31234567000113', 'contato@dreamworks.com.br',       '(11) 3000-1013', 'EUA'),
('Neon Distribuidora',               '41234567000114', 'contato@neon.com.br',             NULL,             'EUA'),
('Searchlight Pictures',             '51234567000115', 'contato@searchlight.com.br',      '(11) 3000-1015', 'EUA'),
('MGM Brasil',                       '61234567000116', 'contato@mgm.com.br',              '(11) 3000-1016', 'EUA'),
('IFC Films',                        '71234567000117', 'contato@ifcfilms.com.br',         NULL,             'EUA'),
('Roadside Attractions',             '81234567000118', 'contato@roadside.com.br',         '(11) 3000-1018', 'EUA'),
('Filmes do Amanhã Ltda',            '91234567000119', 'contato@filmesdoamanha.com.br',   '(21) 3000-1019', 'Brasil'),
('Globo Filmes',                     '01234568000120', 'contato@globofilmes.com.br',      '(21) 3000-1020', 'Brasil'),
('Vitrine Filmes',                   '11234568000121', 'contato@vitrinefilmes.com.br',    '(21) 3000-1021', 'Brasil'),
('Downtown Filmes',                  '21234568000122', 'contato@downtown.com.br',         '(21) 3000-1022', 'Brasil'),
('Pandora Filmes',                   '31234568000123', 'contato@pandorafilmes.com.br',    NULL,             'Brasil'),
('Califórnia Filmes',                '41234568000124', 'contato@californiafilmes.com.br', '(11) 3000-1024', 'Brasil'),
('Paris Filmes',                     '51234568000125', 'contato@parisfilmes.com.br',      '(11) 3000-1025', 'Brasil'),
('Europa Filmes',                    '61234568000126', 'contato@europafilmes.com.br',     '(11) 3000-1026', 'Brasil'),
('Spectra Filmes',                   '71234568000127', 'contato@spectrafilmes.com.br',    NULL,             'Brasil'),
('Netflix Brasil Distribuição',      '81234568000128', 'contato@netflix.com.br',          '(11) 3000-1028', 'EUA'),
('Amazon Content Services',          '91234568000129', 'contato@amazon.com.br',           '(11) 3000-1029', 'EUA'),
('Apple Original Films',             '01234569000130', 'contato@apple.com.br',            NULL,             'EUA'),
('StudioCanal Brasil',               '11234569000131', 'contato@studiocanal.com.br',      '(11) 3000-1031', 'França'),
('Pathé Films',                      '21234569000132', 'contato@pathe.com.br',            '(11) 3000-1032', 'França'),
('Gaumont Brasil',                   '31234569000133', 'contato@gaumont.com.br',          NULL,             'França'),
('Wild Bunch International',         '41234569000134', 'contato@wildbunch.com.br',        '(11) 3000-1034', 'França'),
('BFI Distribution',                 '51234569000135', 'contato@bfi.com.br',              '(11) 3000-1035', 'Reino Unido'),
('Curzon Artificial Eye',            '61234569000136', 'contato@curzon.com.br',           NULL,             'Reino Unido'),
('Nikkatsu International',           '71234569000137', 'contato@nikkatsu.com.br',         '(11) 3000-1037', 'Japão'),
('Toei Company Brasil',              '81234569000138', 'contato@toei.com.br',             '(11) 3000-1038', 'Japão'),
('Ghibli Distribution',              '91234569000139', 'contato@ghibli.com.br',           '(11) 3000-1039', 'Japão'),
('CJ ENM Brasil',                    '01234570000140', 'contato@cjenm.com.br',            NULL,             'Coreia do Sul');

-- =============================================================================
-- 2. GENERO (10 registros — inclui hierarquia: subgêneros com pai)
-- RN04: autorrelacionamento id_genero_pai
-- =============================================================================
INSERT INTO Genero (nome, descricao, id_genero_pai) VALUES
('Ação',              'Filmes com sequências de ação intensa',                      NULL),  -- id 1
('Drama',             'Narrativas centradas em conflitos emocionais',               NULL),  -- id 2
('Comédia',           'Filmes com intenção de provocar humor',                      NULL),  -- id 3
('Terror',            'Filmes que exploram o medo e o suspense',                    NULL),  -- id 4
('Ficção Científica', 'Narrativas baseadas em ciência e tecnologia futuristas',     NULL),  -- id 5
('Animação',          'Filmes produzidos com técnicas de animação',                 NULL),  -- id 6
('Aventura',          'Subgênero de Ação com ênfase em exploração',                    1),  -- id 7 (pai: Ação)
('Suspense',          'Subgênero de Terror com foco em tensão psicológica',             4),  -- id 8 (pai: Terror)
('Comédia Romântica', 'Subgênero de Comédia com trama amorosa',                        3),  -- id 9 (pai: Comédia)
('Sci-Fi Distópico',  'Subgênero de Ficção Científica em sociedades opressoras',        5); -- id 10 (pai: Ficção Científica)

-- =============================================================================
-- 3. FILME (40 registros — mix de ativos/inativos, com/sem sinopse)
-- Casos de contorno: filmes sem titulo_nacional, sem sinopse, ativo=0
-- =============================================================================
INSERT INTO Filme (titulo, titulo_nacional, duracao_min, classificacao_etaria, sinopse, data_lancamento, ativo, id_distribuidora) VALUES
-- Filmes originais (ids 1–12)
('The Grand Heist',        'O Grande Assalto',       118, '14',    'Um grupo de ladrões de elite planeja o maior roubo da história em plena luz do dia.',                                   '2025-03-15', 1,  1),
('Echoes of Tomorrow',     'Ecos do Amanhã',         142, '12',    'Em 2087, uma cientista descobre que o passado pode ser reescrito, mas com consequências imprevisíveis.',                '2025-06-20', 1,  2),
('Laugh Out Loud',         'Gargalhada Total',        95, 'Livre', 'Uma família disfuncional se reúne no casamento mais caótico já organizado.',                                            '2025-01-10', 1,  3),
('Shadows of the Mind',    'Sombras da Mente',       127, '16',    'Um detetive obcecado persegue um serial killer que só existe em sonhos.',                                              '2025-08-05', 1,  4),
('Galactic Frontier',      'Fronteira Galáctica',    155, '12',    'A última nave humana parte em direção a uma estrela desconhecida após a Terra se tornar inabitável.',                  '2025-11-28', 1,  5),
('Little Paws',            'Patinhas',                82, 'Livre', 'Um cachorrinho perdido na cidade grande encontra novos amigos em uma jornada cheia de aventuras.',                    '2025-04-22', 1,  6),
('The Last Witness',       'A Última Testemunha',    111, '16',    NULL,                                                                                                                   '2024-09-14', 1,  7),
('Rising Sun',             NULL,                      98, '10',    'Um jovem samurai busca honrar o legado de seu pai em um Japão feudal repleto de traições.',                            '2024-07-30', 1,  8),
('Frozen Circuit',         'Circuito Congelado',     134, '14',    'Hackers descobrem uma conspiração governamental que controla a memória coletiva da população.',                        '2026-01-18', 1,  2),
('Comedy Crash',           'Comédia em Colapso',      88, '12',    'Três comediantes incompetentes tentam salvar um teatro que vai à falência.',                                           '2026-03-07', 1,  3),
('Dark Waters',            'Águas Sombrias',          120, '18',   'Um mergulhador encontra no fundo do oceano algo que não deveria existir.',                                             '2023-11-11', 0,  4),  -- inativo
('Beyond the Stars',       'Além das Estrelas',      160, '12',    'Uma missão interplanetária revela que a humanidade não está sozinha no universo.',                                     '2026-09-01', 1,  1),
-- Novos filmes (ids 13–40)
('Iron Veil',              'Véu de Ferro',            109, '14',   'Num futuro próximo, uma agente dupla precisa escolher entre o governo e a resistência.',                               '2025-05-12', 1,  9),
('Beneath the Canopy',     'Sob o Dossel',             97, '12',   'Uma expedição científica na Amazônia descobre uma civilização perdida.',                                               '2025-07-04', 1, 10),
('Ghost Protocol Zero',    'Protocolo Fantasma Zero', 122, '16',   NULL,                                                                                                                   '2025-09-19', 1, 11),
('Velvet Storm',           'Tempestade de Veludo',    140, '14',   'Uma bailarina de elite descobre que seu parceiro esconde um segredo mortal.',                                          '2025-10-31', 1, 12),
('Petal & Thorn',          'Pétala e Espinho',         91, 'Livre','Uma história de amizade entre um menino e uma raposa mágica na floresta encantada.',                                  '2025-02-14', 1, 13),
('Fractured Sky',          'Céu Fraturado',           132, '12',   'Após uma tempestade magnética, cidades inteiras ficam sem eletricidade e a ordem social desmorona.',                  '2026-02-20', 1, 14),
('The Hollow Man',         'O Homem Oco',             115, '18',   'Um psicólogo começa a perder a distinção entre seus pacientes e seus próprios pesadelos.',                            '2024-06-07', 1, 15),
('Golden Epoch',           'Época Dourada',           105, '12',   NULL,                                                                                                                   '2024-11-22', 1, 16),
('Neon Requiem',           'Réquiem de Neon',         148, '16',   'Em Neo-Tóquio, um músico compõe a última sinfonia antes do fim do mundo.',                                            '2026-04-05', 1, 17),
('Carnival of Souls',      'Carnaval de Almas',        78, '10',   'Um grupo de crianças descobre um portal mágico escondido atrás de uma máscara de carnaval.',                          '2025-02-01', 1, 18),
('The Summit Protocol',    'Protocolo Cume',          137, '14',   'Cinco alpinistas ficam presos no Himalaia e percebem que um deles sabotou a expedição.',                              '2025-12-15', 1, 19),
('Rust and Bone',          'Ferrugem e Osso',          89, '12',   NULL,                                                                                                                   '2024-03-28', 1, 20),
('Empire of Sand',         'Império de Areia',        161, '16',   'Uma arqueóloga desvenda a conspiração por trás do maior achado histórico do século.',                                 '2026-05-10', 1, 21),
('Cinder Block',           'Bloco de Cinzas',          74, 'Livre','Dois irmãos constroem um foguete caseiro para visitar o avô que mora na Lua.',                                        '2025-06-01', 1, 22),
('Midnight Bloom',         'Flor da Meia-Noite',      118, '14',   'Uma florista descobre que suas plantas guardam memórias dos mortos.',                                                  '2025-08-30', 1, 23),
('Thunder Road',           NULL,                      103, '12',   'Uma corrida clandestina pelo deserto esconde uma rede de tráfico de combustível sintético.',                          '2024-10-10', 1, 24),
('The Oracle',             'O Oráculo',               129, '16',   'Uma IA começa a prever crimes antes que aconteçam — com precisão de 100%.',                                           '2026-06-22', 1, 25),
('Butterflies & Grenades', 'Borboletas e Granadas',   145, '18',   'O drama brutal de uma família dividida pela guerra civil em um país fictício.',                                       '2025-09-05', 1, 26),
('Parallel Noon',          'Meio-Dia Paralelo',       116, '14',   NULL,                                                                                                                   '2026-07-19', 1, 27),
('Sweet Oblivion',         'Doce Esquecimento',        93, 'Livre','Uma avó com Alzheimer revive sua juventude toda vez que dorme — e os netos aprendem com suas histórias.',              '2025-11-07', 1, 28),
('Concrete Jungle',        'Selva de Concreto',       108, '16',   'Um fotógrafo jornalístico documenta 72 horas de uma metrópole em colapso.',                                           '2024-05-19', 1, 29),
('Wired Hearts',           'Corações Conectados',      85, '10',   'Dois robôs domésticos fogem da linha de desmontagem e descobrem o que é sentir saudade.',                             '2025-03-22', 1, 30),
('The Pale Garden',        'O Jardim Pálido',         153, '16',   'Uma jardineira medieval é acusada de feitiçaria por cultivar flores que nunca murcham.',                              '2026-08-14', 1, 31),
('Firebreak',              'Linha de Fogo',           121, '14',   NULL,                                                                                                                   '2025-10-03', 1, 32),
('Orbit 9',                'Órbita 9',                135, '12',   'Uma astronauta acorda sozinha na estação espacial sem lembrar como chegou lá.',                                       '2026-03-28', 1, 33),
('Savage Spring',          'Primavera Selvagem',       99, 'Livre','Em um planeta-jardim, as plantas sentem e um explorador aprende que nem todo terreno pode ser conquistado.',           '2025-07-18', 1,  6),
('The Drift',              NULL,                      144, '18',   'Um surfista profissional abandona a fama para sobreviver numa ilha sem saída após um naufrágio.',                     '2024-08-29', 0,  8),  -- inativo
('Crimson Protocol',       'Protocolo Carmesim',      126, '16',   'Uma cirurgiã de guerra descobre que está operando os dois lados de um conflito secreto.',                             '2026-09-15', 1, 35);

-- =============================================================================
-- 4. FILME_GENERO (60 registros — N:N com atributo genero_principal)
-- =============================================================================
INSERT INTO Filme_Genero (id_filme, id_genero, genero_principal) VALUES
(1,  1, 1), (1,  7, 0),   -- Grand Heist: Ação / Aventura
(2,  5, 1), (2, 10, 0),   -- Echoes of Tomorrow: Ficção Científica / Sci-Fi Distópico
(3,  3, 1), (3,  9, 0),   -- Laugh Out Loud: Comédia / Comédia Romântica
(4,  4, 1), (4,  8, 0),   -- Shadows of the Mind: Terror / Suspense
(5,  5, 1),               -- Galactic Frontier: Ficção Científica
(6,  6, 1), (6,  3, 0),   -- Little Paws: Animação / Comédia
(7,  8, 1),               -- The Last Witness: Suspense
(8,  1, 1),               -- Rising Sun: Ação
(9,  5, 1), (9, 10, 0),   -- Frozen Circuit: Ficção Científica / Sci-Fi Distópico
(10, 3, 1),               -- Comedy Crash: Comédia
(11, 4, 1), (11, 8, 0),   -- Dark Waters: Terror / Suspense
(12, 5, 1), (12, 7, 0),   -- Beyond the Stars: Ficção Científica / Aventura
(13, 1, 1), (13, 5, 0),   -- Iron Veil: Ação / Ficção Científica
(14, 7, 1), (14, 2, 0),   -- Beneath the Canopy: Aventura / Drama
(15, 8, 1),               -- Ghost Protocol Zero: Suspense
(16, 2, 1),               -- Velvet Storm: Drama
(17, 6, 1), (17, 7, 0),   -- Petal & Thorn: Animação / Aventura
(18, 5, 1), (18,10, 0),   -- Fractured Sky: Ficção Científica / Sci-Fi Distópico
(19, 4, 1), (19, 8, 0),   -- The Hollow Man: Terror / Suspense
(20, 2, 1),               -- Golden Epoch: Drama
(21, 5, 1), (21, 2, 0),   -- Neon Requiem: Ficção Científica / Drama
(22, 6, 1),               -- Carnival of Souls: Animação
(23, 7, 1),               -- The Summit Protocol: Aventura
(24, 2, 1),               -- Rust and Bone: Drama
(25, 7, 1), (25, 1, 0),   -- Empire of Sand: Aventura / Ação
(26, 6, 1), (26, 3, 0),   -- Cinder Block: Animação / Comédia
(27, 8, 1),               -- Midnight Bloom: Suspense
(28, 1, 1),               -- Thunder Road: Ação
(29, 5, 1),               -- The Oracle: Ficção Científica
(30, 2, 1),               -- Butterflies & Grenades: Drama
(31, 5, 1), (31,10, 0),   -- Parallel Noon: Ficção Científica / Sci-Fi Distópico
(32, 2, 1), (32, 3, 0),   -- Sweet Oblivion: Drama / Comédia
(33, 2, 1),               -- Concrete Jungle: Drama
(34, 6, 1), (34, 5, 0),   -- Wired Hearts: Animação / Ficção Científica
(35, 2, 1),               -- The Pale Garden: Drama
(36, 1, 1),               -- Firebreak: Ação
(37, 5, 1),               -- Orbit 9: Ficção Científica
(38, 6, 1),               -- Savage Spring: Animação
(39, 7, 1),               -- The Drift: Aventura (inativo)
(40, 1, 1), (40, 8, 0);   -- Crimson Protocol: Ação / Suspense

-- =============================================================================
-- 5. SALA (40 registros — mix de estados)
-- Caso de contorno: salas em manutenção e inativas
-- =============================================================================
INSERT INTO Sala (numero, capacidade, tipo, estado) VALUES
(1,  120, '2D',   'Ativa'),
(2,  150, '3D',   'Ativa'),
(3,   80, 'IMAX', 'Ativa'),
(4,  200, '2D',   'Ativa'),
(5,   60, '4DX',  'Ativa'),
(6,  100, '3D',   'Ativa'),
(7,   90, '2D',   'Em Manutenção'),   -- caso de contorno: indisponível
(8,   50, 'IMAX', 'Inativa'),         -- caso de contorno: inativa
(9,  130, '2D',   'Ativa'),
(10, 110, '3D',   'Ativa'),
(11,  70, 'IMAX', 'Ativa'),
(12, 180, '2D',   'Ativa'),
(13,  55, '4DX',  'Ativa'),
(14, 140, '3D',   'Ativa'),
(15,  95, '2D',   'Ativa'),
(16,  85, '3D',   'Ativa'),
(17, 160, '2D',   'Ativa'),
(18,  65, 'IMAX', 'Ativa'),
(19, 175, '2D',   'Ativa'),
(20,  45, '4DX',  'Em Manutenção'),   -- caso de contorno
(21, 115, '2D',   'Ativa'),
(22, 135, '3D',   'Ativa'),
(23,  75, 'IMAX', 'Ativa'),
(24, 190, '2D',   'Ativa'),
(25,  50, '4DX',  'Ativa'),
(26, 105, '3D',   'Ativa'),
(27,  88, '2D',   'Ativa'),
(28,  60, 'IMAX', 'Ativa'),
(29, 145, '2D',   'Ativa'),
(30, 125, '3D',   'Ativa'),
(31,  72, '2D',   'Inativa'),         -- caso de contorno
(32, 155, '2D',   'Ativa'),
(33,  82, '3D',   'Ativa'),
(34, 168, '2D',   'Ativa'),
(35,  58, '4DX',  'Ativa'),
(36, 112, '3D',   'Ativa'),
(37,  92, '2D',   'Ativa'),
(38, 148, '2D',   'Ativa'),
(39,  78, 'IMAX', 'Ativa'),
(40, 198, '2D',   'Em Manutenção');   -- caso de contorno

-- =============================================================================
-- 6. FUNCIONARIO (42 registros — mix de atendentes e gerentes)
-- Autorrelacionamento: supervisores (RN20)
-- Caso de contorno: funcionário inativo
-- =============================================================================
INSERT INTO Funcionario (nome, cpf, email, telefone, data_admissao, salario, cargo, ativo, id_supervisor) VALUES
('Carlos Eduardo Mendes',    '10111213140', 'carlos.mendes@cinema.com',     '(61) 99001-0001', '2018-03-01',  8500.00, 'Gerente',   1, NULL),  -- id 1
('Fernanda Lima Souza',      '20212223240', 'fernanda.souza@cinema.com',    '(61) 99001-0002', '2019-06-15',  7200.00, 'Gerente',   1,    1),  -- id 2
('Ricardo Alves Pereira',    '30313233340', 'ricardo.pereira@cinema.com',   '(61) 99001-0003', '2020-01-10',  3800.00, 'Atendente', 1,    1),  -- id 3
('Juliana Costa Ramos',      '40414243440', 'juliana.ramos@cinema.com',     '(61) 99001-0004', '2020-05-20',  3800.00, 'Atendente', 1,    2),  -- id 4
('Marcos Vinícius Silva',    '50515253540', 'marcos.silva@cinema.com',      '(61) 99001-0005', '2021-02-28',  3900.00, 'Atendente', 1,    2),  -- id 5
('Patrícia Oliveira Cruz',   '60616263640', 'patricia.cruz@cinema.com',     NULL,              '2021-07-12',  3700.00, 'Atendente', 1,    1),  -- id 6
('Bruno Henrique Gomes',     '70717273740', 'bruno.gomes@cinema.com',       '(61) 99001-0007', '2022-03-01',  4000.00, 'Atendente', 1,    2),  -- id 7
('Aline Ferreira Dias',      '80818283840', 'aline.dias@cinema.com',        '(61) 99001-0008', '2022-09-05',  3750.00, 'Atendente', 1,    1),  -- id 8
('Thiago Rocha Barbosa',     '90919293940', 'thiago.barbosa@cinema.com',    '(61) 99001-0009', '2023-01-15',  8000.00, 'Gerente',   1,    1),  -- id 9
('Vanessa Lopes Cardoso',    '01020304050', 'vanessa.cardoso@cinema.com',   '(61) 99001-0010', '2019-11-20',  3600.00, 'Atendente', 0,    2),  -- id 10: inativo
('Rodrigo Pinheiro Torres',  '11121314150', 'rodrigo.torres@cinema.com',    '(61) 99001-0011', '2021-04-05',  3850.00, 'Atendente', 1,    2),  -- id 11
('Camila Mota Freitas',      '22232425260', 'camila.freitas@cinema.com',    '(61) 99001-0012', '2022-08-10',  3780.00, 'Atendente', 1,    1),  -- id 12
('Pedro Augusto Faria',      '33343536370', 'pedro.faria@cinema.com',       NULL,              '2023-03-22',  3820.00, 'Atendente', 1,    2),  -- id 13
('Larissa Neves Campos',     '44454647480', 'larissa.campos@cinema.com',    '(61) 99001-0014', '2021-09-18',  3760.00, 'Atendente', 1,    1),  -- id 14
('Felipe Santos Guerra',     '55565758590', 'felipe.guerra@cinema.com',     '(61) 99001-0015', '2022-12-01',  4100.00, 'Gerente',   1,    9),  -- id 15
('Bianca Rocha Esteves',     '66676869700', 'bianca.esteves@cinema.com',    '(61) 99001-0016', '2023-06-14',  3900.00, 'Atendente', 1,   15),  -- id 16
('Gustavo Lima Carmo',       '77787980810', 'gustavo.carmo@cinema.com',     '(61) 99001-0017', '2020-11-30',  3830.00, 'Atendente', 1,    2),  -- id 17
('Tatiane Vieira Prado',     '88899091920', 'tatiane.prado@cinema.com',     '(61) 99001-0018', '2021-01-08',  3710.00, 'Atendente', 1,    1),  -- id 18
('Marcelo Cunha Andrade',    '99900102030', 'marcelo.andrade@cinema.com',   '(61) 99001-0019', '2022-07-20',  3950.00, 'Atendente', 1,    9),  -- id 19
('Simone Alves Borges',      '10203040506', 'simone.borges@cinema.com',     NULL,              '2023-09-03',  3680.00, 'Atendente', 1,   15),  -- id 20
('Diego Carvalho Melo',      '20304050607', 'diego.melo@cinema.com',        '(61) 99001-0021', '2020-04-17',  7500.00, 'Gerente',   1,    1),  -- id 21
('Isabela Fontes Cruz',      '30405060708', 'isabela.fontes@cinema.com',    '(61) 99001-0022', '2021-10-25',  3870.00, 'Atendente', 1,   21),  -- id 22
('Roberto Mendonça Sá',      '40506070809', 'roberto.sa@cinema.com',        '(61) 99001-0023', '2022-02-14',  3790.00, 'Atendente', 1,    2),  -- id 23
('Luciane Teixeira Leal',    '50607080910', 'luciane.leal@cinema.com',      '(61) 99001-0024', '2023-05-07',  3720.00, 'Atendente', 1,   21),  -- id 24
('André Fonseca Braga',      '60708091011', 'andre.braga@cinema.com',       '(61) 99001-0025', '2019-08-19',  4200.00, 'Gerente',   1,    1),  -- id 25
('Monica Castro Luz',        '70809101112', 'monica.luz@cinema.com',        NULL,              '2022-11-28',  3840.00, 'Atendente', 1,   25),  -- id 26
('Heitor Amaral Pinto',      '80910111213', 'heitor.pinto@cinema.com',      '(61) 99001-0027', '2023-07-16',  3800.00, 'Atendente', 1,    2),  -- id 27
('Cristiane Moraes Dias',    '91011121314', 'cristiane.dias@cinema.com',    '(61) 99001-0028', '2020-06-09',  3860.00, 'Atendente', 1,   25),  -- id 28
('Eduardo Pires Viana',      '01112131415', 'eduardo.viana@cinema.com',     '(61) 99001-0029', '2021-12-03',  3730.00, 'Atendente', 1,    9),  -- id 29
('Fabiana Melo Correia',     '11213141516', 'fabiana.correia@cinema.com',   '(61) 99001-0030', '2022-04-21',  3810.00, 'Atendente', 0,   15),  -- id 30: inativo
('Rafael Costa Campos',      '21314151617', 'rafael.campos@cinema.com',     '(61) 99001-0031', '2023-10-11',  3770.00, 'Atendente', 1,   21),  -- id 31
('Adriana Sousa Lima',       '31415161718', 'adriana.lima@cinema.com',      '(61) 99001-0032', '2020-09-02',  3820.00, 'Atendente', 1,    2),  -- id 32
('Leonardo Ramos Nogueira',  '41516171819', 'leonardo.nogueira@cinema.com', '(61) 99001-0033', '2021-05-14',  3890.00, 'Atendente', 1,   25),  -- id 33
('Priscila Torres Almada',   '51617181920', 'priscila.almada@cinema.com',   NULL,              '2022-01-26',  3750.00, 'Atendente', 1,    9),  -- id 34
('Fernando Assis Gomes',     '61718192021', 'fernando.gomes@cinema.com',    '(61) 99001-0035', '2023-08-08',  3700.00, 'Atendente', 1,   15),  -- id 35
('Natália Duarte Barreto',   '71819202122', 'natalia.barreto@cinema.com',   '(61) 99001-0036', '2020-03-15',  3840.00, 'Atendente', 1,   21),  -- id 36
('Sérgio Oliveira Macedo',   '81920212223', 'sergio.macedo@cinema.com',     '(61) 99001-0037', '2021-07-29',  7800.00, 'Gerente',   1,    1),  -- id 37
('Camila Dias Guerreiro',    '91021222324', 'camila.guerreiro@cinema.com',  '(61) 99001-0038', '2022-06-17',  3760.00, 'Atendente', 1,   37),  -- id 38
('Henrique Lopes Figueira',  '01122232425', 'henrique.figueira@cinema.com', '(61) 99001-0039', '2023-02-05',  3810.00, 'Atendente', 1,    2),  -- id 39
('Letícia Paixão Ramos',     '11223242526', 'leticia.ramos@cinema.com',     '(61) 99001-0040', '2020-12-10',  3870.00, 'Atendente', 1,   37),  -- id 40
('Davi Gonçalves Matos',     '21324252627', 'davi.matos@cinema.com',        NULL,              '2021-08-23',  8200.00, 'Gerente',   1,    1),  -- id 41
('Carolina Reis Brandão',    '31425262728', 'carolina.brandao@cinema.com',  '(61) 99001-0042', '2022-10-04',  3790.00, 'Atendente', 1,   41);  -- id 42

-- =============================================================================
-- 7. ATENDENTE (34 registros — todos com cargo='Atendente')
-- =============================================================================
INSERT INTO Atendente (id_funcionario, turno, bilheteria) VALUES
(3,  'Manhã',  1), (4,  'Tarde',  2), (5,  'Noite',  1), (6,  'Manhã',  2),
(7,  'Tarde',  1), (8,  'Noite',  2), (10, 'Manhã',  1), (11, 'Tarde',  2),
(12, 'Noite',  1), (13, 'Manhã',  2), (14, 'Tarde',  1), (16, 'Noite',  2),
(17, 'Manhã',  1), (18, 'Tarde',  2), (19, 'Noite',  1), (20, 'Manhã',  2),
(22, 'Tarde',  1), (23, 'Noite',  2), (24, 'Manhã',  1), (26, 'Tarde',  2),
(27, 'Noite',  1), (28, 'Manhã',  2), (29, 'Tarde',  1), (30, 'Noite',  2),
(31, 'Manhã',  1), (32, 'Tarde',  2), (33, 'Noite',  1), (34, 'Manhã',  2),
(35, 'Tarde',  1), (36, 'Noite',  2), (38, 'Manhã',  1), (39, 'Tarde',  2),
(40, 'Noite',  1), (42, 'Manhã',  2);

-- =============================================================================
-- 8. GERENTE (8 registros — todos com cargo='Gerente')
-- =============================================================================
INSERT INTO Gerente (id_funcionario, area_responsabilidade, nivel_acesso) VALUES
(1,  'Diretoria Geral',          5),
(2,  'Programação de Sessões',   3),
(9,  'Operações e Salas',        3),
(15, 'Financeiro',               3),
(21, 'Marketing e Promoções',    3),
(25, 'Tecnologia da Informação', 4),
(37, 'Recursos Humanos',         3),
(41, 'Atendimento ao Cliente',   3);

-- =============================================================================
-- 9. CLIENTE (40 registros — com/sem telefone, pontos variados)
-- =============================================================================
INSERT INTO Cliente (nome, cpf, data_nascimento, email, telefone, pontos_fidelidade, data_cadastro) VALUES
('Ana Paula Ferreira',       '11122233344', '1990-04-15', 'ana.ferreira@email.com',       '(61) 98000-0001',   60, '2023-01-10'),  -- 4 Inteiras + 1 Meia = 45; arredondado p/ histórico extra
('Bruno Martins Oliveira',   '22233344455', '1985-08-22', 'bruno.martins@email.com',      '(61) 98000-0002',   50, '2022-06-05'),
('Carla Regina Souza',       '33344455566', '1998-12-03', 'carla.souza@email.com',        NULL,                30, '2024-02-14'),  -- sem telefone
('Diego Augusto Lima',       '44455566677', '2000-07-19', 'diego.lima@email.com',         '(61) 98000-0004',   20, '2026-01-20'),
('Elisa Carvalho Nunes',     '55566677788', '1992-03-30', 'elisa.nunes@email.com',        '(61) 98000-0005',   30, '2023-09-18'),
('Felipe Andrade Costa',     '66677788899', '1988-11-11', 'felipe.costa@email.com',       '(61) 98000-0006',   40, '2021-11-30'),
('Gabriela Torres Melo',     '77788899900', '2001-05-25', 'gabriela.melo@email.com',      '(61) 98000-0007',   20, '2025-03-07'),
('Henrique Duarte Silva',    '88899900011', '1995-09-08', 'henrique.silva@email.com',     '(61) 98000-0008',   50, '2022-08-19'),
('Isabela Rocha Pinto',      '99900011122', '1999-01-17', 'isabela.pinto@email.com',      NULL,                40, '2024-07-22'),  -- sem telefone
('João Victor Barbosa',      '00011122233', '1993-06-04', 'joao.barbosa@email.com',       '(61) 98000-0010',   60, '2021-05-15'),
('Karen Almeida Fonseca',    '11223344556', '2003-02-28', 'karen.fonseca@email.com',      '(61) 98000-0011',   30, '2025-12-01'),
('Lucas Pereira Xavier',     '22334455667', '1987-10-20', 'lucas.xavier@email.com',       '(61) 98000-0012',   50, '2020-03-23'),
('Marina Gomes Correia',     '33445566778', '1996-08-14', 'marina.correia@email.com',     '(61) 98000-0013',   40, '2023-04-11'),
('Nelson Dias Teixeira',     '44556677889', '1980-12-31', 'nelson.teixeira@email.com',    '(61) 98000-0014',   10, '2026-07-03'),  -- cadastro recente
('Olivia Santos Ramos',      '55667788990', '2002-04-09', 'olivia.ramos@email.com',       '(61) 98000-0015',   50, '2022-12-25'),
('Paulo Henrique Castelo',   '66778899001', '1991-07-17', 'paulo.castelo@email.com',      '(61) 98000-0016',   60, '2022-03-08'),
('Quésia Barbosa Freire',    '77889900112', '1997-11-29', 'quesia.freire@email.com',      NULL,                10, '2025-08-19'),  -- sem telefone
('Renata Campos Viana',      '88990011223', '1984-05-06', 'renata.viana@email.com',       '(61) 98000-0018',   80, '2021-02-14'),
('Samuel Teles Rocha',       '99001122334', '2004-09-13', 'samuel.rocha@email.com',       '(61) 98000-0019',    0, '2026-05-27'),  -- recém cadastrado, sem compras
('Tatiana Souza Melo',       '00112233445', '1989-03-24', 'tatiana.melo@email.com',       '(61) 98000-0020',   70, '2021-09-30'),
('Ulisses Mendes Braga',     '11223344567', '1994-12-02', 'ulisses.braga@email.com',      '(61) 98000-0021',   30, '2023-07-15'),
('Vera Lúcia Pinheiro',      '22334455678', '1978-06-18', 'vera.pinheiro@email.com',      '(61) 98000-0022',  100, '2020-01-05'),  -- cliente antiga, muitas compras históricas
('Wagner Andrade Luz',       '33445566789', '2005-02-07', 'wagner.luz@email.com',         '(61) 98000-0023',    0, '2026-08-11'),  -- recém cadastrado
('Xênia Farias Costa',       '44556677890', '1993-10-23', 'xenia.costa@email.com',        NULL,                20, '2024-06-30'),  -- sem telefone
('Yago Nunes Ferreira',      '55667788901', '1990-01-29', 'yago.ferreira@email.com',      '(61) 98000-0025',   40, '2022-10-17'),
('Zilda Cardoso Esteves',    '66778899012', '1986-08-03', 'zilda.esteves@email.com',      '(61) 98000-0026',   60, '2021-07-22'),
('Alex Guimarães Dutra',     '77889900123', '2002-05-14', 'alex.dutra@email.com',         '(61) 98000-0027',   10, '2025-01-18'),
('Beatriz Lima Carvalho',    '88990011234', '1996-11-08', 'beatriz.carvalho@email.com',   '(61) 98000-0028',   90, '2020-11-03'),
('Caio Torres Nascimento',   '99001122345', '1983-04-27', 'caio.nascimento@email.com',    '(61) 98000-0029',   50, '2023-02-09'),
('Débora Alves Macedo',      '00112233456', '2001-07-11', 'debora.macedo@email.com',      '(61) 98000-0030',   10, '2025-04-25'),
('Emanuel Costa Barros',     '10213243546', '1988-02-16', 'emanuel.barros@email.com',     NULL,                30, '2023-11-20'),  -- sem telefone
('Flávia Rocha Monteiro',    '20314253647', '1995-09-05', 'flavia.monteiro@email.com',    '(61) 98000-0032',   70, '2021-06-14'),
('Guilherme Pereira Lins',   '30415263748', '1999-12-19', 'guilherme.lins@email.com',     '(61) 98000-0033',   20, '2024-09-07'),
('Helena Martins Cruz',      '40516273849', '1987-03-30', 'helena.cruz@email.com',        '(61) 98000-0034',   80, '2021-04-01'),
('Igor Santana Batista',     '50617283940', '2003-06-22', 'igor.batista@email.com',       '(61) 98000-0035',   10, '2025-10-12'),
('Juliana Castro Dias',      '60718293041', '1991-10-08', 'juliana.dias@email.com',       '(61) 98000-0036',   60, '2022-09-19'),
('Kátia Ferreira Prado',     '70819303142', '1980-01-14', 'katia.prado@email.com',        '(61) 98000-0037',  110, '2020-07-28'),
('Luan Morais Oliveira',     '80920313243', '2000-04-03', 'luan.oliveira@email.com',      '(61) 98000-0038',   20, '2024-03-15'),
('Marcia Sousa Ribeiro',     '91021323344', '1984-11-26', 'marcia.ribeiro@email.com',     NULL,                70, '2022-02-06'),  -- sem telefone
('Nilson Pinto Azevedo',     '01122334445', '1977-07-07', 'nilson.azevedo@email.com',     '(61) 98000-0040',  120, '2019-12-31');  -- cliente desde 2019

-- =============================================================================
-- 10. PROMOCAO (8 registros — inclui promoção vencida e futura)
-- =============================================================================
INSERT INTO Promocao (nome, descricao, percentual_desconto, data_inicio, data_fim) VALUES
('Terça do Cinema',         'Todo ingresso com 50% de desconto nas terças-feiras',                   50.00, '2026-01-01', '2026-12-31'),
('Meia-entrada Estudantil', 'Desconto adicional para estudantes com carteirinha válida',             25.00, '2026-01-01', '2026-12-31'),
('Promoção de Aniversário', 'Ingresso gratuito no dia do aniversário do cliente',                   100.00, '2026-01-01', '2026-12-31'),
('Lançamento Especial',     'Pré-estreia com 30% de desconto para os primeiros compradores',         30.00, '2026-09-01', '2026-09-30'),
('Black Friday Cinema',     'Promoção encerrada — desconto de 60% em todos os ingressos',            60.00, '2025-11-28', '2025-11-28'),  -- vencida
('Clube VIP',               'Desconto exclusivo para clientes com mais de 400 pontos de fidelidade', 20.00, '2025-06-01', '2026-12-31'),
('Natal Mágico',            'Desconto de 40% durante o período natalino',                            40.00, '2026-12-10', '2026-12-26'),  -- futura
('Primeira Visita',         'Desconto de 15% para clientes cadastrados há menos de 30 dias',         15.00, '2026-01-01', '2026-12-31');

-- =============================================================================
-- 11. SESSAO (40 registros — múltiplos filmes, salas, datas e status)
-- data_hora_fim = data_hora_inicio + duracao_min do filme referenciado
-- Casos de contorno: sessão cancelada, encerrada, em exibição, agendada
-- =============================================================================
INSERT INTO Sessao (data_hora_inicio, data_hora_fim, idioma, valor_ingresso_base, status, id_filme, id_sala) VALUES
-- Sessões passadas encerradas (ids 1–10)
-- F1=118min, F2=142min, F3=95min, F4=127min, F5=155min
-- F9=134min, F10=88min, F8=98min, F13=109min, F14=97min
('2026-09-20 14:00:00', '2026-09-20 15:58:00', 'Português',        28.00, 'Encerrada',    1,  1),  -- F1: 14:00+118min=15:58 ✓
('2026-09-20 16:30:00', '2026-09-20 18:52:00', 'Inglês Legendado', 32.00, 'Encerrada',    2,  2),  -- F2: 16:30+142min=18:52
('2026-09-21 10:00:00', '2026-09-21 11:35:00', 'Português',        22.00, 'Encerrada',    3,  4),  -- F3: 10:00+95min=11:35 ✓
('2026-09-21 15:00:00', '2026-09-21 17:07:00', 'Inglês Legendado', 30.00, 'Encerrada',    4,  3),  -- F4: 15:00+127min=17:07 ✓
('2026-09-22 18:00:00', '2026-09-22 20:35:00', 'Inglês Legendado', 45.00, 'Encerrada',    5,  3),  -- F5: 18:00+155min=20:35 IMAX
('2026-09-23 10:00:00', '2026-09-23 11:28:00', 'Português',        22.00, 'Encerrada',   10,  4),  -- F10: 10:00+88min=11:28
('2026-09-24 14:00:00', '2026-09-24 16:14:00', 'Inglês Legendado', 35.00, 'Encerrada',    9,  2),  -- F9: 14:00+134min=16:14
('2026-09-25 19:00:00', '2026-09-25 20:38:00', 'Português',        28.00, 'Encerrada',    8,  6),  -- F8: 19:00+98min=20:38 ✓
('2026-09-26 16:00:00', '2026-09-26 17:49:00', 'Inglês Legendado', 30.00, 'Encerrada',   13, 10),  -- F13: 16:00+109min=17:49
('2026-09-27 20:00:00', '2026-09-27 21:37:00', 'Português',        38.00, 'Encerrada',   14,  3),  -- F14: 20:00+97min=21:37 IMAX
-- Sessões canceladas (ids 11–12)
('2026-09-23 20:00:00', '2026-09-23 21:22:00', 'Português',        28.00, 'Cancelada',    6,  6),  -- F6: 20:00+82min=21:22
('2026-09-25 14:00:00', '2026-09-25 16:02:00', 'Inglês Legendado', 32.00, 'Cancelada',   15,  2),  -- F15: 14:00+122min=16:02
-- Sessões em exibição agora (ids 13–14)
('2026-09-29 14:00:00', '2026-09-29 15:58:00', 'Português',        28.00, 'Em Exibição',  1,  1),  -- F1: +118min=15:58
('2026-09-29 16:30:00', '2026-09-29 18:44:00', 'Inglês Legendado', 32.00, 'Em Exibição',  9,  2),  -- F9: +134min=18:44
-- Sessões futuras agendadas (ids 15–40)
('2026-09-30 10:00:00', '2026-09-30 11:35:00', 'Português',        22.00, 'Agendada',     3,  4),  -- F3: +95min=11:35
('2026-09-30 14:00:00', '2026-09-30 15:58:00', 'Português',        28.00, 'Agendada',     1,  1),  -- F1: +118min=15:58
('2026-09-30 17:00:00', '2026-09-30 19:22:00', 'Inglês Legendado', 32.00, 'Agendada',     2,  2),  -- F2: +142min=19:22
('2026-10-01 15:00:00', '2026-10-01 17:35:00', 'Português',        38.00, 'Agendada',     5,  3),  -- F5: +155min=17:35 IMAX
('2026-10-01 20:00:00', '2026-10-01 22:14:00', 'Inglês Legendado', 35.00, 'Agendada',     9,  5),  -- F9: +134min=22:14 4DX
('2026-10-02 14:00:00', '2026-10-02 15:28:00', 'Português',        22.00, 'Agendada',    10,  4),  -- F10: +88min=15:28
('2026-10-03 19:00:00', '2026-10-03 21:40:00', 'Inglês Legendado', 40.00, 'Agendada',    12,  3),  -- F12: +160min=21:40 IMAX
('2026-10-04 14:00:00', '2026-10-04 15:49:00', 'Português',        28.00, 'Agendada',    13,  9),  -- F13: +109min=15:49
('2026-10-04 17:30:00', '2026-10-04 19:07:00', 'Inglês Legendado', 32.00, 'Agendada',    14,  6),  -- F14: +97min=19:07
('2026-10-05 10:00:00', '2026-10-05 11:37:00', 'Português',        22.00, 'Agendada',    17,  4),  -- F17: +97min=11:37
('2026-10-05 14:00:00', '2026-10-05 15:45:00', 'Inglês Legendado', 30.00, 'Agendada',    16, 10),  -- F16: +105min=15:45
('2026-10-06 19:00:00', '2026-10-06 21:12:00', 'Português',        35.00, 'Agendada',    18, 14),  -- F18: +132min=21:12
('2026-10-07 14:00:00', '2026-10-07 15:45:00', 'Inglês Legendado', 32.00, 'Agendada',    20,  2),  -- F20: +105min=15:45
('2026-10-07 20:00:00', '2026-10-07 22:28:00', 'Português',        38.00, 'Agendada',    21,  3),  -- F21: +148min=22:28 IMAX
('2026-10-08 15:00:00', '2026-10-08 16:18:00', 'Português',        22.00, 'Agendada',    22,  4),  -- F22: +78min=16:18
('2026-10-09 19:00:00', '2026-10-09 21:17:00', 'Inglês Legendado', 32.00, 'Agendada',    23, 16),  -- F23: +137min=21:17
('2026-10-10 14:00:00', '2026-10-10 15:14:00', 'Português',        25.00, 'Agendada',    26,  9),  -- F26: +74min=15:14
('2026-10-11 17:00:00', '2026-10-11 19:01:00', 'Inglês Legendado', 30.00, 'Agendada',    36, 10),  -- F36: +121min=19:01
('2026-10-12 20:00:00', '2026-10-12 22:15:00', 'Português',        35.00, 'Agendada',    37, 22),  -- F37: +135min=22:15
('2026-10-13 14:00:00', '2026-10-13 16:41:00', 'Inglês Legendado', 40.00, 'Agendada',    25, 14),  -- F25: +161min=16:41
('2026-10-14 19:00:00', '2026-10-14 21:06:00', 'Português',        32.00, 'Agendada',    40,  6),  -- F40: +126min=21:06
('2026-10-15 15:00:00', '2026-10-15 17:09:00', 'Inglês Legendado', 28.00, 'Agendada',    29,  2),  -- F29: +129min=17:09
('2026-10-16 20:00:00', '2026-10-16 22:40:00', 'Português',        38.00, 'Agendada',    12,  3),  -- F12: +160min=22:40 IMAX
('2026-10-17 14:00:00', '2026-10-17 16:25:00', 'Inglês Legendado', 42.00, 'Agendada',    30,  5),  -- F30: +145min=16:25 4DX
('2026-10-18 17:00:00', '2026-10-18 18:33:00', 'Português',        30.00, 'Agendada',    32, 36);  -- F32: +93min=18:33

-- =============================================================================
-- 12. HISTORICO_STATUS_SESSAO (registros para sessões encerradas/canceladas)
-- =============================================================================
INSERT INTO Historico_Status_Sessao (id_sessao, status_anterior, status_novo, data_hora_mudanca, id_funcionario) VALUES
(1,  NULL,          'Agendada',    '2026-09-15 09:00:00',  2),
(1,  'Agendada',    'Em Exibição', '2026-09-20 14:00:00', NULL),
(1,  'Em Exibição', 'Encerrada',   '2026-09-20 15:58:00', NULL),
(2,  NULL,          'Agendada',    '2026-09-15 09:05:00',  2),
(2,  'Agendada',    'Em Exibição', '2026-09-20 16:30:00', NULL),
(2,  'Em Exibição', 'Encerrada',   '2026-09-20 18:52:00', NULL),
(3,  NULL,          'Agendada',    '2026-09-16 10:00:00',  9),
(3,  'Agendada',    'Em Exibição', '2026-09-21 10:00:00', NULL),
(3,  'Em Exibição', 'Encerrada',   '2026-09-21 11:35:00', NULL),
(4,  NULL,          'Agendada',    '2026-09-16 10:05:00',  9),
(4,  'Agendada',    'Em Exibição', '2026-09-21 15:00:00', NULL),
(4,  'Em Exibição', 'Encerrada',   '2026-09-21 17:07:00', NULL),
(5,  NULL,          'Agendada',    '2026-09-17 11:00:00',  2),
(5,  'Agendada',    'Em Exibição', '2026-09-22 18:00:00', NULL),
(5,  'Em Exibição', 'Encerrada',   '2026-09-22 20:35:00', NULL),
(6,  NULL,          'Agendada',    '2026-09-18 08:00:00',  2),
(6,  'Agendada',    'Em Exibição', '2026-09-23 10:00:00', NULL),
(6,  'Em Exibição', 'Encerrada',   '2026-09-23 11:28:00', NULL),
(7,  NULL,          'Agendada',    '2026-09-18 09:00:00',  9),
(7,  'Agendada',    'Em Exibição', '2026-09-24 14:00:00', NULL),
(7,  'Em Exibição', 'Encerrada',   '2026-09-24 16:14:00', NULL),
(8,  NULL,          'Agendada',    '2026-09-19 08:30:00',  2),
(8,  'Agendada',    'Em Exibição', '2026-09-25 19:00:00', NULL),
(8,  'Em Exibição', 'Encerrada',   '2026-09-25 20:38:00', NULL),
(9,  NULL,          'Agendada',    '2026-09-20 09:00:00',  2),
(9,  'Agendada',    'Em Exibição', '2026-09-26 16:00:00', NULL),
(9,  'Em Exibição', 'Encerrada',   '2026-09-26 17:49:00', NULL),
(10, NULL,          'Agendada',    '2026-09-21 09:00:00',  9),
(10, 'Agendada',    'Em Exibição', '2026-09-27 20:00:00', NULL),
(10, 'Em Exibição', 'Encerrada',   '2026-09-27 21:37:00', NULL),
(11, NULL,          'Agendada',    '2026-09-17 11:30:00',  2),
(11, 'Agendada',    'Cancelada',   '2026-09-22 17:00:00',  1),
(12, NULL,          'Agendada',    '2026-09-19 10:00:00',  9),
(12, 'Agendada',    'Cancelada',   '2026-09-24 08:00:00',  1),
(13, NULL,          'Agendada',    '2026-09-22 09:00:00',  2),
(13, 'Agendada',    'Em Exibição', '2026-09-29 14:00:00', NULL),
(14, NULL,          'Agendada',    '2026-09-22 09:05:00',  9),
(14, 'Agendada',    'Em Exibição', '2026-09-29 16:30:00', NULL);

-- =============================================================================
-- 13. INGRESSO (110 registros distribuídos entre sessões encerradas e em exibição)
-- Casos de contorno: avulso, online, cancelado, cortesia, meia-entrada,
--                   com/sem promoção
-- =============================================================================

-- SESSÃO 1 (sala 1, cap. 120) — 25 ingressos
INSERT INTO Ingresso (id_sessao, numero_assento, tipo, valor_base, valor_final, status, data_venda, id_cliente, id_funcionario, id_promocao) VALUES
(1,  1, 'Inteira',      28.00, 14.00, 'Pago',      '2026-09-18 10:00:00',  1,  3, 1),
(1,  2, 'Inteira',      28.00, 14.00, 'Pago',      '2026-09-18 10:05:00',  2,  3, 1),
(1,  3, 'Meia-entrada', 28.00, 10.50, 'Pago',      '2026-09-18 10:10:00',  3,  4, 2),
(1,  4, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 10:15:00',  4,  4, NULL),
(1,  5, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 10:20:00',  5, NULL, NULL),
(1,  6, 'Meia-entrada', 28.00, 14.00, 'Pago',      '2026-09-18 10:25:00',  6, NULL, NULL),
(1,  7, 'Inteira',      28.00, 22.40, 'Pago',      '2026-09-18 10:30:00',  7,  3, 6),
(1,  8, 'Cortesia',     28.00,  0.00, 'Pago',      '2026-09-18 10:35:00', NULL, 3, NULL),
(1,  9, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 10:40:00',  8,  4, NULL),
(1, 10, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 10:45:00',  9,  4, NULL),
(1, 11, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 10:50:00', 10,  5, NULL),
(1, 12, 'Meia-entrada', 28.00, 14.00, 'Pago',      '2026-09-18 10:55:00', 11,  5, NULL),
(1, 13, 'Inteira',      28.00, 22.40, 'Pago',      '2026-09-18 11:00:00', 12, NULL, 6),
(1, 14, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 11:05:00', 13,  6, NULL),
(1, 15, 'Inteira',      28.00, 28.00, 'Cancelado', '2026-09-18 11:10:00', 14,  6, NULL),
(1, 16, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 11:15:00', 15,  7, NULL),
(1, 17, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 11:20:00', NULL, 7, NULL),
(1, 18, 'Inteira',      28.00, 14.00, 'Pago',      '2026-09-18 11:25:00',  1,  7, 1),
(1, 19, 'Meia-entrada', 28.00, 14.00, 'Pago',      '2026-09-18 11:30:00',  2,  8, NULL),
(1, 20, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 11:35:00',  3,  8, NULL),
(1, 21, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 11:40:00',  4, NULL, NULL),
(1, 22, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 11:45:00',  5, NULL, NULL),
(1, 23, 'Meia-entrada', 28.00, 14.00, 'Cancelado', '2026-09-18 11:50:00',  6,  3, NULL),
(1, 24, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 11:55:00',  7,  3, NULL),
(1, 25, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-18 12:00:00',  8,  4, NULL);

-- SESSÃO 2 (sala 2, cap. 150) — 20 ingressos
INSERT INTO Ingresso (id_sessao, numero_assento, tipo, valor_base, valor_final, status, data_venda, id_cliente, id_funcionario, id_promocao) VALUES
(2,  1, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 09:00:00',  9,  3, NULL),
(2,  2, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 09:05:00', 10,  3, NULL),
(2,  3, 'Meia-entrada', 32.00, 16.00, 'Pago',      '2026-09-19 09:10:00', 11,  4, NULL),
(2,  4, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 09:15:00', 12,  4, NULL),
(2,  5, 'Inteira',      32.00, 22.40, 'Pago',      '2026-09-19 09:20:00', 13, NULL, 6),
(2,  6, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 09:25:00', 14,  5, NULL),
(2,  7, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 09:30:00', 15,  5, NULL),
(2,  8, 'Meia-entrada', 32.00, 16.00, 'Pago',      '2026-09-19 09:35:00',  1, NULL, NULL),
(2,  9, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 09:40:00',  2,  6, NULL),
(2, 10, 'Inteira',      32.00, 16.00, 'Pago',      '2026-09-19 09:45:00',  3,  6, 1),
(2, 11, 'Cortesia',     32.00,  0.00, 'Pago',      '2026-09-19 09:50:00', NULL, 7, NULL),
(2, 12, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 09:55:00',  4,  7, NULL),
(2, 13, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 10:00:00',  5,  8, NULL),
(2, 14, 'Inteira',      32.00, 32.00, 'Cancelado', '2026-09-19 10:05:00',  6,  8, NULL),
(2, 15, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 10:10:00',  7, NULL, NULL),
(2, 16, 'Meia-entrada', 32.00, 24.00, 'Pago',      '2026-09-19 10:15:00',  8,  3, 2),
(2, 17, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 10:20:00', NULL, 3, NULL),
(2, 18, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 10:25:00',  9,  4, NULL),
(2, 19, 'Inteira',      32.00, 32.00, 'Pago',      '2026-09-19 10:30:00', 10,  4, NULL),
(2, 20, 'Inteira',      32.00, 22.40, 'Pago',      '2026-09-19 10:35:00', 11, NULL, 6);

-- SESSÃO 3 (sala 4, cap. 200) — 15 ingressos
INSERT INTO Ingresso (id_sessao, numero_assento, tipo, valor_base, valor_final, status, data_venda, id_cliente, id_funcionario, id_promocao) VALUES
(3,  1, 'Inteira',      22.00, 22.00, 'Pago',      '2026-09-20 08:00:00', 12,  3, NULL),
(3,  2, 'Meia-entrada', 22.00, 11.00, 'Pago',      '2026-09-20 08:05:00', 13,  3, NULL),
(3,  3, 'Inteira',      22.00, 11.00, 'Pago',      '2026-09-20 08:10:00', 14,  4, 1),
(3,  4, 'Inteira',      22.00, 22.00, 'Pago',      '2026-09-20 08:15:00', 15,  4, NULL),
(3,  5, 'Inteira',      22.00, 22.00, 'Pago',      '2026-09-20 08:20:00',  1, NULL, NULL),
(3,  6, 'Meia-entrada', 22.00, 11.00, 'Pago',      '2026-09-20 08:25:00',  2, NULL, NULL),
(3,  7, 'Cortesia',     22.00,  0.00, 'Pago',      '2026-09-20 08:30:00', NULL, 5, NULL),
(3,  8, 'Inteira',      22.00, 22.00, 'Pago',      '2026-09-20 08:35:00',  3,  5, NULL),
(3,  9, 'Inteira',      22.00, 17.60, 'Pago',      '2026-09-20 08:40:00',  4,  6, 6),
(3, 10, 'Inteira',      22.00, 22.00, 'Pago',      '2026-09-20 08:45:00',  5,  6, NULL),
(3, 11, 'Inteira',      22.00, 22.00, 'Cancelado', '2026-09-20 08:50:00',  6,  7, NULL),
(3, 12, 'Meia-entrada', 22.00, 11.00, 'Pago',      '2026-09-20 08:55:00',  7,  7, NULL),
(3, 13, 'Inteira',      22.00, 22.00, 'Pago',      '2026-09-20 09:00:00',  8,  8, NULL),
(3, 14, 'Inteira',      22.00, 22.00, 'Pago',      '2026-09-20 09:05:00', NULL, NULL, NULL),
(3, 15, 'Inteira',      22.00, 22.00, 'Pago',      '2026-09-20 09:10:00',  9,  3, NULL);

-- SESSÃO 4 (sala 3 IMAX, cap. 80) — 18 ingressos
INSERT INTO Ingresso (id_sessao, numero_assento, tipo, valor_base, valor_final, status, data_venda, id_cliente, id_funcionario, id_promocao) VALUES
(4,  1, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 14:00:00', 10,  4, NULL),
(4,  2, 'Inteira',      30.00, 21.00, 'Pago',      '2026-09-20 14:05:00', 11,  4, 1),
(4,  3, 'Meia-entrada', 30.00, 15.00, 'Pago',      '2026-09-20 14:10:00', 12,  5, NULL),
(4,  4, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 14:15:00', 13,  5, NULL),
(4,  5, 'Inteira',      30.00, 24.00, 'Pago',      '2026-09-20 14:20:00', 14, NULL, 6),
(4,  6, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 14:25:00', 15,  6, NULL),
(4,  7, 'Meia-entrada', 30.00, 15.00, 'Pago',      '2026-09-20 14:30:00',  1,  6, NULL),
(4,  8, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 14:35:00',  2,  7, NULL),
(4,  9, 'Inteira',      30.00, 30.00, 'Cancelado', '2026-09-20 14:40:00',  3,  7, NULL),
(4, 10, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 14:45:00',  4,  8, NULL),
(4, 11, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 14:50:00',  5,  8, NULL),
(4, 12, 'Cortesia',     30.00,  0.00, 'Pago',      '2026-09-20 14:55:00', NULL, 3, NULL),
(4, 13, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 15:00:00',  6,  3, NULL),
(4, 14, 'Meia-entrada', 30.00, 22.50, 'Pago',      '2026-09-20 15:05:00',  7,  4, 2),
(4, 15, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 15:10:00',  8,  4, NULL),
(4, 16, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 15:15:00',  9, NULL, NULL),
(4, 17, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 15:20:00', 10, NULL, NULL),
(4, 18, 'Inteira',      30.00, 30.00, 'Pago',      '2026-09-20 15:25:00', 11,  5, NULL);

-- SESSÃO 5 (sala 3 IMAX, cap. 80) — 15 ingressos
INSERT INTO Ingresso (id_sessao, numero_assento, tipo, valor_base, valor_final, status, data_venda, id_cliente, id_funcionario, id_promocao) VALUES
(5,  1, 'Inteira',      45.00, 45.00, 'Pago',      '2026-09-21 10:00:00', 12,  5, NULL),
(5,  2, 'Inteira',      45.00, 36.00, 'Pago',      '2026-09-21 10:05:00', 13,  5, 6),
(5,  3, 'Meia-entrada', 45.00, 22.50, 'Pago',      '2026-09-21 10:10:00', 14,  6, NULL),
(5,  4, 'Inteira',      45.00, 45.00, 'Pago',      '2026-09-21 10:15:00', 15,  6, NULL),
(5,  5, 'Inteira',      45.00, 45.00, 'Pago',      '2026-09-21 10:20:00',  1,  7, NULL),
(5,  6, 'Meia-entrada', 45.00, 22.50, 'Pago',      '2026-09-21 10:25:00',  2,  7, NULL),
(5,  7, 'Inteira',      45.00, 45.00, 'Pago',      '2026-09-21 10:30:00',  3,  8, NULL),
(5,  8, 'Inteira',      45.00, 45.00, 'Pago',      '2026-09-21 10:35:00',  4,  8, NULL),
(5,  9, 'Inteira',      45.00, 45.00, 'Pago',      '2026-09-21 10:40:00',  5, NULL, NULL),
(5, 10, 'Inteira',      45.00, 31.50, 'Pago',      '2026-09-21 10:45:00',  6,  3, 1),
(5, 11, 'Inteira',      45.00, 45.00, 'Pago',      '2026-09-21 10:50:00',  7,  3, NULL),
(5, 12, 'Cortesia',     45.00,  0.00, 'Pago',      '2026-09-21 10:55:00', NULL, 4, NULL),
(5, 13, 'Inteira',      45.00, 45.00, 'Pago',      '2026-09-21 11:00:00',  8,  4, NULL),
(5, 14, 'Meia-entrada', 45.00, 22.50, 'Pago',      '2026-09-21 11:05:00',  9,  5, NULL),
(5, 15, 'Inteira',      45.00, 45.00, 'Pago',      '2026-09-21 11:10:00', 10, NULL, NULL);

-- SESSÃO 13 (em exibição hoje, sala 1) — 17 ingressos
INSERT INTO Ingresso (id_sessao, numero_assento, tipo, valor_base, valor_final, status, data_venda, id_cliente, id_funcionario, id_promocao) VALUES
(13,  1, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-28 09:00:00', 11,  3, NULL),
(13,  2, 'Inteira',      28.00, 14.00, 'Pago',      '2026-09-28 09:05:00', 12,  3, 1),
(13,  3, 'Meia-entrada', 28.00, 14.00, 'Pago',      '2026-09-28 09:10:00', 13,  4, NULL),
(13,  4, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-28 09:15:00', 14,  4, NULL),
(13,  5, 'Inteira',      28.00, 22.40, 'Pago',      '2026-09-28 09:20:00', 15, NULL, 6),
(13,  6, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-28 09:25:00',  1,  5, NULL),
(13,  7, 'Meia-entrada', 28.00, 14.00, 'Pago',      '2026-09-28 09:30:00',  2,  5, NULL),
(13,  8, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-28 09:35:00',  3,  6, NULL),
(13,  9, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-28 09:40:00',  4,  6, NULL),
(13, 10, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-28 09:45:00',  5,  7, NULL),
(13, 11, 'Cortesia',     28.00,  0.00, 'Pago',      '2026-09-28 09:50:00', NULL, 7, NULL),
(13, 12, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-28 09:55:00',  6,  8, NULL),
(13, 13, 'Inteira',      28.00, 28.00, 'Pago',      '2026-09-28 10:00:00',  7,  8, NULL),
(13, 14, 'Inteira',      28.00, 28.00, 'Reservado', '2026-09-29 13:00:00',  8, NULL, NULL),
(13, 15, 'Inteira',      28.00, 28.00, 'Reservado', '2026-09-29 13:05:00',  9, NULL, NULL),
(13, 16, 'Meia-entrada', 28.00, 14.00, 'Reservado', '2026-09-29 13:10:00', 10,  3, NULL),
(13, 17, 'Inteira',      28.00, 28.00, 'Reservado', '2026-09-29 13:15:00', 11,  3, NULL);

-- =============================================================================
-- 14. AVALIACAO (20 registros — N:N com atributos; inclui sem comentário)
-- RN18: apenas clientes que assistiram ao filme podem avaliar
-- =============================================================================
INSERT INTO Avaliacao (id_cliente, id_filme, nota, comentario, data_avaliacao) VALUES
(1,  1, 5, 'Ação do início ao fim! Adorei cada cena.',                '2026-09-20 16:30:00'),
(2,  1, 4, 'Muito bom, roteiro bem construído.',                      '2026-09-20 16:45:00'),
(3,  1, 3, NULL,                                                      '2026-09-20 17:00:00'),
(4,  1, 4, 'Valeu o ingresso, recomendo.',                            '2026-09-20 17:15:00'),
(5,  1, 5, NULL,                                                      '2026-09-20 17:30:00'),
(9,  2, 4, 'Ficção científica muito bem produzida.',                  '2026-09-21 20:00:00'),
(10, 2, 3, 'Esperava mais do enredo, mas a fotografia é linda.',      '2026-09-21 20:15:00'),
(11, 2, 5, 'Melhor filme do ano! Efeitos visuais impressionantes.',   '2026-09-21 20:30:00'),
(12, 3, 4, 'Ótima comédia para assistir em família.',                 '2026-09-21 13:00:00'),
(13, 3, 2, 'Esperava mais, algumas piadas não funcionaram.',          '2026-09-21 13:15:00'),
(14, 3, 5, 'Ri do começo ao fim! Imperdível.',                        '2026-09-21 13:30:00'),
(10, 4, 4, 'Suspense muito bem executado.',                           '2026-09-21 18:30:00'),
(11, 4, 3, NULL,                                                      '2026-09-21 18:45:00'),
(12, 4, 5, 'Terror psicológico de alto nível.',                       '2026-09-21 19:00:00'),
(1,  5, 5, 'Épico! A melhor ficção científica que já vi no IMAX.',    '2026-09-22 22:00:00'),
(2,  5, 4, 'Trilha sonora incrível, roteiro sólido.',                 '2026-09-22 22:15:00'),
(3,  5, 1, 'Muito longo e arrastado, me decepcionei.',                '2026-09-22 22:30:00'),
(6,  5, 5, NULL,                                                      '2026-09-22 22:45:00'),
(8,  1, 2, 'Achei exagerado demais, muita ação sem substância.',      '2026-09-20 18:00:00'),
(9,  1, 4, 'Bom entretenimento, mas não espere profundidade.',        '2026-09-20 18:15:00');

-- =============================================================================
-- VERIFICAÇÃO DE VOLUME — execute após a carga para conferir os contadores:
-- SELECT 'Distribuidora' AS tabela, COUNT(*) AS total FROM Distribuidora
-- UNION ALL SELECT 'Genero',      COUNT(*) FROM Genero
-- UNION ALL SELECT 'Filme',       COUNT(*) FROM Filme
-- UNION ALL SELECT 'Sala',        COUNT(*) FROM Sala
-- UNION ALL SELECT 'Sessao',      COUNT(*) FROM Sessao
-- UNION ALL SELECT 'Ingresso',    COUNT(*) FROM Ingresso
-- UNION ALL SELECT 'Cliente',     COUNT(*) FROM Cliente
-- UNION ALL SELECT 'Funcionario', COUNT(*) FROM Funcionario
-- UNION ALL SELECT 'Promocao',    COUNT(*) FROM Promocao
-- UNION ALL SELECT 'Avaliacao',   COUNT(*) FROM Avaliacao;
-- Resultado esperado: todas as tabelas principais >= 40; Ingresso >= 110.
-- =============================================================================
-- FIM DO SCRIPT DE CARGA
-- =============================================================================
