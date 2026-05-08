CREATE SCHEMA IF NOT EXISTS raw;

DROP TABLE IF EXISTS raw.dataset_crimes;
DROP TABLE IF EXISTS raw.dataset_populacao;
DROP TABLE IF EXISTS raw.dataset_idhm;
DROP TABLE IF EXISTS raw.dataset_educacao;

CREATE TABLE raw.dataset_crimes (
    "quantidade_mortes_intervencao_policial_civil_fora_de_servico" TEXT,
    "quantidade_feminicidio" TEXT,
    "quantidade_mortes_intervencao_policial_militar_fora_de_servico" TEXT,
    "quantidade_furto_veiculos" TEXT,
    "quantidade_mortes_intervencao_policial_civil_em_servico" TEXT,
    "quantidade_estupro" TEXT,
    "quantidade_morte_policiais_civis_confronto_em_servico" TEXT,
    "quantidade_mortes_intervencao_policial_militar_em_servico" TEXT,
    "quantidade_mortes_policiais_confronto" TEXT,
    "quantidade_posse_uso_entorpecente" TEXT,
    "quantidade_mortes_violentas_intencionais" TEXT,
    "quantidade_morte_policiais_militares_fora_de_servico" TEXT,
    "quantidade_morte_policiais_civis_fora_de_servico" TEXT,
    "quantidade_latrocinio" TEXT,
    "quantidade_porte_ilegal_arma_de_fogo" TEXT,
    "quantidade_mortes_intervencao_policial" TEXT,
    "ano" TEXT,
    "quantidade_roubo_furto_veiculos" TEXT,
    "quantidade_posse_ilegal_arma_de_fogo" TEXT,
    "quantidade_lesao_corporal_dolosa_violencia_domestica" TEXT,
    "quantidade_trafico_entorpecente" TEXT,
    "quantidade_roubo_veiculos" TEXT,
    "quantidade_lesao_corporal_morte" TEXT,
    "proporcao_mortes_intenvencao_policial_x_mortes_violentas_intencionais" TEXT,
    "quantidade_morte_policiais_militares_confronto_em_servico" TEXT,
    "quantidade_posse_ilegal_porte_ilegal_arma_de_fogo" TEXT,
    "sigla_uf" TEXT,
    "sigla_uf_nome" TEXT,
    "id_municipio" TEXT,
    "id_municipio_nome" TEXT,
    "grupo" TEXT,
    "quantidade_homicidio_doloso" TEXT
);

CREATE TABLE raw.dataset_populacao (
    "ano" TEXT,
    "id_municipio" TEXT,
    "id_municipio_nome" TEXT,
    "sexo" TEXT,
    "grupo_idade" TEXT,
    "populacao" TEXT
);

CREATE TABLE raw.dataset_idhm (
    "Territorialidades" TEXT,
    "IDHM 2010" TEXT,
    "IDHM Renda 2010" TEXT,
    "IDHM Longevidade 2010" TEXT,
    "IDHM Educação 2010" TEXT
);

CREATE TABLE raw.dataset_educacao (
    "ibge_id" TEXT,
    "dependencia_id" TEXT,
    "ciclo_id" TEXT,
    "ano" TEXT,
    "ideb" TEXT,
    "fluxo" TEXT,
    "aprendizado" TEXT,
    "nota_mt" TEXT,
    "nota_lp" TEXT
);

COPY raw.dataset_crimes
FROM '/datasets/crimes/2016-2021.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

COPY raw.dataset_crimes
FROM '/datasets/crimes/2022-2024.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

SELECT COUNT(*) AS total_dataset_crimes
FROM raw.dataset_crimes;

COPY raw.dataset_populacao
FROM '/datasets/populacao/2016-2021.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

COPY raw.dataset_populacao
FROM '/datasets/populacao/2022-2024.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

SELECT COUNT(*) AS total_dataset_populacao
FROM raw.dataset_populacao;

COPY raw.dataset_idhm
FROM '/datasets/idh/data_idhm_2010.csv'
DELIMITER ';'
CSV HEADER
ENCODING 'UTF8';

SELECT COUNT(*) AS total_dataset_idhm
FROM raw.dataset_idhm;

COPY raw.dataset_educacao
FROM '/datasets/educacao/2017-2021idep.csv'
DELIMITER ';'
CSV HEADER
ENCODING 'UTF8';

COPY raw.dataset_educacao
FROM '/datasets/educacao/idep2023.csv'
DELIMITER ';'
CSV HEADER
ENCODING 'UTF8';

SELECT COUNT(*) AS total_dataset_educacao
FROM raw.dataset_educacao;
