CREATE SCHEMA IF NOT EXISTS dw;

DROP TABLE IF EXISTS dw.fato_crime_municipio_ano_indicador CASCADE;
DROP TABLE IF EXISTS dw.fato_populacao_municipio_ano_demografia CASCADE;
DROP TABLE IF EXISTS dw.fato_educacao_uf_ano CASCADE;
DROP TABLE IF EXISTS dw.fato_municipio_ano CASCADE;
DROP TABLE IF EXISTS dw.dim_grupo_idade CASCADE;
DROP TABLE IF EXISTS dw.dim_sexo CASCADE;
DROP TABLE IF EXISTS dw.dim_municipio CASCADE;
DROP TABLE IF EXISTS dw.dim_uf CASCADE;
DROP TABLE IF EXISTS dw.dim_regiao CASCADE;
DROP TABLE IF EXISTS dw.dim_tempo CASCADE;
DROP TABLE IF EXISTS dw.dim_educacao CASCADE;
DROP TABLE IF EXISTS dw.dim_indicador_crime CASCADE;

CREATE TABLE dw.dim_regiao (
    id_regiao_dw SERIAL PRIMARY KEY,
    nome_regiao VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO dw.dim_regiao (nome_regiao)
VALUES
    ('Norte'),
    ('Nordeste'),
    ('Centro-Oeste'),
    ('Sudeste'),
    ('Sul');

CREATE TABLE dw.dim_uf (
    id_uf_dw SERIAL PRIMARY KEY,
    codigo_uf_ibge INTEGER NOT NULL UNIQUE,
    sigla_uf CHAR(2) NOT NULL UNIQUE,
    nome_uf VARCHAR(100) NOT NULL,
    id_regiao_dw INTEGER NOT NULL,
    CONSTRAINT fk_dim_uf_dim_regiao
        FOREIGN KEY (id_regiao_dw)
        REFERENCES dw.dim_regiao (id_regiao_dw)
);

INSERT INTO dw.dim_uf (
    codigo_uf_ibge,
    sigla_uf,
    nome_uf,
    id_regiao_dw
)
SELECT
    dados.codigo_uf_ibge,
    dados.sigla_uf,
    dados.nome_uf,
    regiao.id_regiao_dw
FROM (
    VALUES
        (11, 'RO', 'Rondonia', 'Norte'),
        (12, 'AC', 'Acre', 'Norte'),
        (13, 'AM', 'Amazonas', 'Norte'),
        (14, 'RR', 'Roraima', 'Norte'),
        (15, 'PA', 'Para', 'Norte'),
        (16, 'AP', 'Amapa', 'Norte'),
        (17, 'TO', 'Tocantins', 'Norte'),
        (21, 'MA', 'Maranhao', 'Nordeste'),
        (22, 'PI', 'Piaui', 'Nordeste'),
        (23, 'CE', 'Ceara', 'Nordeste'),
        (24, 'RN', 'Rio Grande do Norte', 'Nordeste'),
        (25, 'PB', 'Paraiba', 'Nordeste'),
        (26, 'PE', 'Pernambuco', 'Nordeste'),
        (27, 'AL', 'Alagoas', 'Nordeste'),
        (28, 'SE', 'Sergipe', 'Nordeste'),
        (29, 'BA', 'Bahia', 'Nordeste'),
        (31, 'MG', 'Minas Gerais', 'Sudeste'),
        (32, 'ES', 'Espirito Santo', 'Sudeste'),
        (33, 'RJ', 'Rio de Janeiro', 'Sudeste'),
        (35, 'SP', 'Sao Paulo', 'Sudeste'),
        (41, 'PR', 'Parana', 'Sul'),
        (42, 'SC', 'Santa Catarina', 'Sul'),
        (43, 'RS', 'Rio Grande do Sul', 'Sul'),
        (50, 'MS', 'Mato Grosso do Sul', 'Centro-Oeste'),
        (51, 'MT', 'Mato Grosso', 'Centro-Oeste'),
        (52, 'GO', 'Goias', 'Centro-Oeste'),
        (53, 'DF', 'Distrito Federal', 'Centro-Oeste')
) AS dados(codigo_uf_ibge, sigla_uf, nome_uf, nome_regiao)
JOIN dw.dim_regiao AS regiao
    ON regiao.nome_regiao = dados.nome_regiao;

CREATE TABLE dw.dim_tempo (
    id_tempo_dw SERIAL PRIMARY KEY,
    ano INTEGER NOT NULL UNIQUE,
    decada INTEGER NOT NULL,
    periodo_analise VARCHAR(100) NOT NULL
);

INSERT INTO dw.dim_tempo (
    ano,
    decada,
    periodo_analise
)
SELECT DISTINCT
    CAST(ano AS INTEGER) AS ano,
    (CAST(ano AS INTEGER) / 10) * 10 AS decada,
    CASE
        WHEN CAST(ano AS INTEGER) = 2010 THEN 'Referencia socioeconomica'
        WHEN CAST(ano AS INTEGER) BETWEEN 2016 AND 2024 THEN 'Periodo de analise'
        ELSE 'Outro periodo'
    END AS periodo_analise
FROM (
    SELECT ano FROM raw.dataset_crimes
    UNION
    SELECT ano FROM raw.dataset_populacao
    UNION
    SELECT ano FROM raw.dataset_educacao
    UNION
    SELECT '2010' AS ano
) AS anos;

CREATE TABLE dw.dim_educacao (
    id_educacao_dw SERIAL PRIMARY KEY,
    ciclo_id VARCHAR(10) NOT NULL,
    descricao_ciclo VARCHAR(100) NOT NULL,
    dependencia_id INTEGER NOT NULL,
    descricao_dependencia VARCHAR(100) NOT NULL,
    CONSTRAINT uk_dim_educacao UNIQUE (ciclo_id, dependencia_id)
);

INSERT INTO dw.dim_educacao (
    ciclo_id,
    descricao_ciclo,
    dependencia_id,
    descricao_dependencia
)
SELECT DISTINCT
    edu.ciclo_id,
    CASE edu.ciclo_id
        WHEN 'AI' THEN 'Anos Iniciais'
        WHEN 'AF' THEN 'Anos Finais'
        WHEN 'EM' THEN 'Ensino Medio'
        ELSE 'Nao informado'
    END AS descricao_ciclo,
    CAST(edu.dependencia_id AS INTEGER) AS dependencia_id,
    CASE CAST(edu.dependencia_id AS INTEGER)
        WHEN 0 THEN 'Total'
        WHEN 1 THEN 'Federal'
        WHEN 2 THEN 'Estadual'
        WHEN 3 THEN 'Municipal'
        WHEN 4 THEN 'Privada'
        WHEN 5 THEN 'Publica'
        ELSE 'Nao informado'
    END AS descricao_dependencia
FROM raw.dataset_educacao AS edu;

CREATE TABLE dw.dim_indicador_crime (
    id_indicador_crime_dw SERIAL PRIMARY KEY,
    nome_indicador VARCHAR(150) NOT NULL UNIQUE,
    categoria_indicador VARCHAR(100) NOT NULL,
    descricao_indicador TEXT
);

INSERT INTO dw.dim_indicador_crime (
    nome_indicador,
    categoria_indicador,
    descricao_indicador
)
VALUES
    ('quantidade_homicidio_doloso', 'Crimes contra a vida', 'Quantidade de homicidios dolosos registrados'),
    ('quantidade_feminicidio', 'Crimes contra a vida', 'Quantidade de feminicidios registrados'),
    ('quantidade_mortes_violentas_intencionais', 'Crimes contra a vida', 'Quantidade de mortes violentas intencionais'),
    ('quantidade_estupro', 'Crimes sexuais', 'Quantidade de estupros registrados'),
    ('quantidade_furto_veiculos', 'Crimes patrimoniais', 'Quantidade de furtos de veiculos registrados'),
    ('quantidade_roubo_veiculos', 'Crimes patrimoniais', 'Quantidade de roubos de veiculos registrados'),
    ('quantidade_latrocinio', 'Crimes patrimoniais violentos', 'Quantidade de latrocinios registrados'),
    ('quantidade_trafico_entorpecente', 'Drogas', 'Quantidade de ocorrencias de trafico de entorpecentes'),
    ('quantidade_posse_uso_entorpecente', 'Drogas', 'Quantidade de ocorrencias de posse ou uso de entorpecentes'),
    ('quantidade_porte_ilegal_arma_de_fogo', 'Armas', 'Quantidade de ocorrencias de porte ilegal de arma de fogo');

CREATE TABLE dw.dim_sexo (
    id_sexo_dw SERIAL PRIMARY KEY,
    sexo VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO dw.dim_sexo (sexo)
SELECT DISTINCT
    TRIM(pop.sexo) AS sexo
FROM raw.dataset_populacao AS pop
WHERE NULLIF(TRIM(pop.sexo), '') IS NOT NULL;

CREATE TABLE dw.dim_grupo_idade (
    id_grupo_idade_dw SERIAL PRIMARY KEY,
    grupo_idade VARCHAR(50) NOT NULL UNIQUE,
    ordem_grupo_idade INTEGER NOT NULL
);

INSERT INTO dw.dim_grupo_idade (
    grupo_idade,
    ordem_grupo_idade
)
SELECT DISTINCT
    TRIM(pop.grupo_idade) AS grupo_idade,
    CASE
        WHEN TRIM(pop.grupo_idade) ~ '^[0-9]+'
            THEN REGEXP_REPLACE(TRIM(pop.grupo_idade), '^([0-9]+).*$', '\1')::INTEGER
        ELSE 999
    END AS ordem_grupo_idade
FROM raw.dataset_populacao AS pop
WHERE NULLIF(TRIM(pop.grupo_idade), '') IS NOT NULL;

CREATE TABLE dw.dim_municipio (
    id_municipio_dw SERIAL PRIMARY KEY,
    codigo_municipio INTEGER NOT NULL UNIQUE,
    nome_municipio VARCHAR(150) NOT NULL,
    nome_municipio_padronizado VARCHAR(150) NOT NULL,
    id_uf_dw INTEGER NOT NULL,
    CONSTRAINT fk_dim_municipio_dim_uf
        FOREIGN KEY (id_uf_dw)
        REFERENCES dw.dim_uf (id_uf_dw)
);

INSERT INTO dw.dim_municipio (
    codigo_municipio,
    nome_municipio,
    nome_municipio_padronizado,
    id_uf_dw
)
SELECT
    dados.codigo_municipio,
    dados.nome_municipio,
    dados.nome_municipio_padronizado,
    uf.id_uf_dw
FROM (
    VALUES
        (1200401, 'Rio Branco', 'rio branco', 'AC'),
        (2704302, 'Maceio', 'maceio', 'AL'),
        (1302603, 'Manaus', 'manaus', 'AM'),
        (1600303, 'Macapa', 'macapa', 'AP'),
        (2927408, 'Salvador', 'salvador', 'BA'),
        (2304400, 'Fortaleza', 'fortaleza', 'CE'),
        (5300108, 'Brasilia', 'brasilia', 'DF'),
        (3205309, 'Vitoria', 'vitoria', 'ES'),
        (5208707, 'Goiania', 'goiania', 'GO'),
        (2111300, 'Sao Luis', 'sao luis', 'MA'),
        (3106200, 'Belo Horizonte', 'belo horizonte', 'MG'),
        (5002704, 'Campo Grande', 'campo grande', 'MS'),
        (5103403, 'Cuiaba', 'cuiaba', 'MT'),
        (1501402, 'Belem', 'belem', 'PA'),
        (2507507, 'Joao Pessoa', 'joao pessoa', 'PB'),
        (2611606, 'Recife', 'recife', 'PE'),
        (2211001, 'Teresina', 'teresina', 'PI'),
        (4106902, 'Curitiba', 'curitiba', 'PR'),
        (3304557, 'Rio de Janeiro', 'rio de janeiro', 'RJ'),
        (2408102, 'Natal', 'natal', 'RN'),
        (1100205, 'Porto Velho', 'porto velho', 'RO'),
        (1400100, 'Boa Vista', 'boa vista', 'RR'),
        (4314902, 'Porto Alegre', 'porto alegre', 'RS'),
        (4205407, 'Florianopolis', 'florianopolis', 'SC'),
        (2800308, 'Aracaju', 'aracaju', 'SE'),
        (3550308, 'Sao Paulo', 'sao paulo', 'SP'),
        (1721000, 'Palmas', 'palmas', 'TO')
) AS dados(codigo_municipio, nome_municipio, nome_municipio_padronizado, sigla_uf)
JOIN dw.dim_uf AS uf
    ON uf.sigla_uf = dados.sigla_uf;

SELECT COUNT(*) AS total_dim_regiao FROM dw.dim_regiao;
SELECT COUNT(*) AS total_dim_uf FROM dw.dim_uf;
SELECT COUNT(*) AS total_dim_municipio FROM dw.dim_municipio;
SELECT COUNT(*) AS total_dim_tempo FROM dw.dim_tempo;
SELECT COUNT(*) AS total_dim_educacao FROM dw.dim_educacao;
SELECT COUNT(*) AS total_dim_indicador_crime FROM dw.dim_indicador_crime;
SELECT COUNT(*) AS total_dim_sexo FROM dw.dim_sexo;
SELECT COUNT(*) AS total_dim_grupo_idade FROM dw.dim_grupo_idade;

SELECT
    nome_municipio,
    COUNT(*) AS qtd,
    STRING_AGG(codigo_municipio::TEXT, ', ') AS codigos
FROM dw.dim_municipio
GROUP BY nome_municipio
HAVING COUNT(*) > 1
ORDER BY nome_municipio;

DROP TABLE IF EXISTS dw.fato_municipio_ano;

CREATE TABLE dw.fato_municipio_ano (
    id_fato_municipio_ano_dw SERIAL PRIMARY KEY,
    id_tempo_dw INTEGER NOT NULL,
    id_municipio_dw INTEGER NOT NULL,
    id_educacao_dw INTEGER,
    codigo_municipio INTEGER NOT NULL,
    ano INTEGER NOT NULL,
    populacao_total NUMERIC(18, 2),
    populacao_crescimento_pct NUMERIC(12, 4),
    idhm NUMERIC(8, 4),
    idhm_renda NUMERIC(8, 4),
    idhm_educacao NUMERIC(8, 4),
    idhm_longevidade NUMERIC(8, 4),
    ano_referencia_idhm INTEGER,
    ideb NUMERIC(8, 4),
    fluxo NUMERIC(8, 4),
    aprendizado NUMERIC(8, 4),
    nota_mt NUMERIC(10, 4),
    nota_lp NUMERIC(10, 4),
    crimes_total_indicadores NUMERIC(18, 2),
    mortes_violentas_intencionais NUMERIC(18, 2),
    homicidios_dolosos NUMERIC(18, 2),
    feminicidios NUMERIC(18, 2),
    estupros NUMERIC(18, 2),
    furto_veiculos NUMERIC(18, 2),
    roubo_veiculos NUMERIC(18, 2),
    latrocinios NUMERIC(18, 2),
    taxa_crimes_100k NUMERIC(18, 6),
    taxa_mortes_violentas_100k NUMERIC(18, 6),
    taxa_homicidios_100k NUMERIC(18, 6),
    taxa_feminicidios_100k NUMERIC(18, 6),
    taxa_estupros_100k NUMERIC(18, 6),
    taxa_furto_veiculos_100k NUMERIC(18, 6),
    risco_indice NUMERIC(18, 6),
    CONSTRAINT fk_fato_tempo
        FOREIGN KEY (id_tempo_dw)
        REFERENCES dw.dim_tempo (id_tempo_dw),
    CONSTRAINT fk_fato_municipio
        FOREIGN KEY (id_municipio_dw)
        REFERENCES dw.dim_municipio (id_municipio_dw),
    CONSTRAINT fk_fato_educacao
        FOREIGN KEY (id_educacao_dw)
        REFERENCES dw.dim_educacao (id_educacao_dw),
    CONSTRAINT uk_fato_municipio_ano
        UNIQUE (id_municipio_dw, id_tempo_dw)
);

INSERT INTO dw.fato_municipio_ano (
    id_tempo_dw,
    id_municipio_dw,
    id_educacao_dw,
    codigo_municipio,
    ano,
    populacao_total,
    populacao_crescimento_pct,
    idhm,
    idhm_renda,
    idhm_educacao,
    idhm_longevidade,
    ano_referencia_idhm,
    ideb,
    fluxo,
    aprendizado,
    nota_mt,
    nota_lp,
    crimes_total_indicadores,
    mortes_violentas_intencionais,
    homicidios_dolosos,
    feminicidios,
    estupros,
    furto_veiculos,
    roubo_veiculos,
    latrocinios,
    taxa_crimes_100k,
    taxa_mortes_violentas_100k,
    taxa_homicidios_100k,
    taxa_feminicidios_100k,
    taxa_estupros_100k,
    taxa_furto_veiculos_100k,
    risco_indice
)
WITH populacao_agg AS (
    SELECT
        CAST(id_municipio AS INTEGER) AS codigo_municipio,
        CAST(ano AS INTEGER) AS ano,
        SUM(CAST(populacao AS NUMERIC)) AS populacao_total
    FROM raw.dataset_populacao
    GROUP BY
        CAST(id_municipio AS INTEGER),
        CAST(ano AS INTEGER)
),
populacao_final AS (
    SELECT
        *,
        (
            (
                populacao_total
                - LAG(populacao_total) OVER (
                    PARTITION BY codigo_municipio
                    ORDER BY ano
                )
            )
            / NULLIF(
                LAG(populacao_total) OVER (
                    PARTITION BY codigo_municipio
                    ORDER BY ano
                ),
                0
            )
        ) * 100 AS populacao_crescimento_pct
    FROM populacao_agg
),
crimes AS (
    SELECT
        CAST(id_municipio AS INTEGER) AS codigo_municipio,
        CAST(ano AS INTEGER) AS ano,
        NULLIF(REPLACE(quantidade_mortes_violentas_intencionais, ',', '.'), '')::NUMERIC AS mortes_violentas_intencionais,
        NULLIF(REPLACE(quantidade_homicidio_doloso, ',', '.'), '')::NUMERIC AS homicidios_dolosos,
        NULLIF(REPLACE(quantidade_feminicidio, ',', '.'), '')::NUMERIC AS feminicidios,
        NULLIF(REPLACE(quantidade_estupro, ',', '.'), '')::NUMERIC AS estupros,
        NULLIF(REPLACE(quantidade_furto_veiculos, ',', '.'), '')::NUMERIC AS furto_veiculos,
        NULLIF(REPLACE(quantidade_roubo_veiculos, ',', '.'), '')::NUMERIC AS roubo_veiculos,
        NULLIF(REPLACE(quantidade_latrocinio, ',', '.'), '')::NUMERIC AS latrocinios
    FROM raw.dataset_crimes
),
crimes_final AS (
    SELECT
        *,
        (
            mortes_violentas_intencionais
            + homicidios_dolosos
            + feminicidios
            + estupros
            + furto_veiculos
            + roubo_veiculos
            + latrocinios
        ) AS crimes_total_indicadores
    FROM crimes
),
idhm AS (
    SELECT
        municipio.id_municipio_dw,
        2010 AS ano_referencia_idhm,
        NULLIF(REPLACE(raw_idhm."IDHM 2010", ',', '.'), '')::NUMERIC AS idhm,
        NULLIF(REPLACE(raw_idhm."IDHM Renda 2010", ',', '.'), '')::NUMERIC AS idhm_renda,
        NULLIF(REPLACE(raw_idhm."IDHM Educação 2010", ',', '.'), '')::NUMERIC AS idhm_educacao,
        NULLIF(REPLACE(raw_idhm."IDHM Longevidade 2010", ',', '.'), '')::NUMERIC AS idhm_longevidade
    FROM raw.dataset_idhm AS raw_idhm
    JOIN dw.dim_municipio AS municipio
        ON municipio.nome_municipio_padronizado =
            LOWER(
                TRANSLATE(
                    REGEXP_REPLACE(raw_idhm."Territorialidades", '\s*\([A-Z]{2}\)$', ''),
                    'ÁÀÂÃÄáàâãäÉÈÊËéèêëÍÌÎÏíìîïÓÒÔÕÖóòôõöÚÙÛÜúùûüÇç',
                    'AAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuCc'
                )
            )
    WHERE raw_idhm."Territorialidades" ~ '\([A-Z]{2}\)$'
),
educacao AS (
    SELECT
        CAST(ibge_id AS INTEGER) AS codigo_uf_ibge,
        CAST(ano AS INTEGER) AS ano,
        NULLIF(REPLACE(ideb, ',', '.'), '')::NUMERIC AS ideb,
        NULLIF(REPLACE(fluxo, ',', '.'), '')::NUMERIC AS fluxo,
        NULLIF(REPLACE(aprendizado, ',', '.'), '')::NUMERIC AS aprendizado,
        NULLIF(REPLACE(nota_mt, ',', '.'), '')::NUMERIC AS nota_mt,
        NULLIF(REPLACE(nota_lp, ',', '.'), '')::NUMERIC AS nota_lp,
        ciclo_id,
        CAST(dependencia_id AS INTEGER) AS dependencia_id
    FROM raw.dataset_educacao
    WHERE ciclo_id = 'EM'
      AND CAST(dependencia_id AS INTEGER) = 0
),
base AS (
    SELECT
        tempo.id_tempo_dw,
        municipio.id_municipio_dw,
        educacao_dim.id_educacao_dw,
        municipio.codigo_municipio,
        tempo.ano,
        pop.populacao_total,
        pop.populacao_crescimento_pct,
        idhm.idhm,
        idhm.idhm_renda,
        idhm.idhm_educacao,
        idhm.idhm_longevidade,
        idhm.ano_referencia_idhm,
        edu.ideb,
        edu.fluxo,
        edu.aprendizado,
        edu.nota_mt,
        edu.nota_lp,
        crimes.crimes_total_indicadores,
        crimes.mortes_violentas_intencionais,
        crimes.homicidios_dolosos,
        crimes.feminicidios,
        crimes.estupros,
        crimes.furto_veiculos,
        crimes.roubo_veiculos,
        crimes.latrocinios,
        (crimes.crimes_total_indicadores / NULLIF(pop.populacao_total, 0)) * 100000 AS taxa_crimes_100k,
        (crimes.mortes_violentas_intencionais / NULLIF(pop.populacao_total, 0)) * 100000 AS taxa_mortes_violentas_100k,
        (crimes.homicidios_dolosos / NULLIF(pop.populacao_total, 0)) * 100000 AS taxa_homicidios_100k,
        (crimes.feminicidios / NULLIF(pop.populacao_total, 0)) * 100000 AS taxa_feminicidios_100k,
        (crimes.estupros / NULLIF(pop.populacao_total, 0)) * 100000 AS taxa_estupros_100k,
        (crimes.furto_veiculos / NULLIF(pop.populacao_total, 0)) * 100000 AS taxa_furto_veiculos_100k
    FROM populacao_final AS pop
    JOIN dw.dim_municipio AS municipio
        ON municipio.codigo_municipio = pop.codigo_municipio
    JOIN dw.dim_uf AS uf
        ON uf.id_uf_dw = municipio.id_uf_dw
    JOIN dw.dim_tempo AS tempo
        ON tempo.ano = pop.ano
    LEFT JOIN crimes_final AS crimes
        ON crimes.codigo_municipio = pop.codigo_municipio
       AND crimes.ano = pop.ano
    LEFT JOIN idhm
        ON idhm.id_municipio_dw = municipio.id_municipio_dw
    LEFT JOIN educacao AS edu
        ON edu.codigo_uf_ibge = uf.codigo_uf_ibge
       AND edu.ano = pop.ano
    LEFT JOIN dw.dim_educacao AS educacao_dim
        ON educacao_dim.ciclo_id = edu.ciclo_id
       AND educacao_dim.dependencia_id = edu.dependencia_id
),
base_risco AS (
    SELECT
        *,
        (
            COALESCE(taxa_mortes_violentas_100k / NULLIF(MAX(taxa_mortes_violentas_100k) OVER (), 0), 0)
            + COALESCE(taxa_homicidios_100k / NULLIF(MAX(taxa_homicidios_100k) OVER (), 0), 0)
            + COALESCE(taxa_feminicidios_100k / NULLIF(MAX(taxa_feminicidios_100k) OVER (), 0), 0)
            + COALESCE(taxa_estupros_100k / NULLIF(MAX(taxa_estupros_100k) OVER (), 0), 0)
        ) / NULLIF(
            (CASE WHEN taxa_mortes_violentas_100k IS NULL THEN 0 ELSE 1 END)
            + (CASE WHEN taxa_homicidios_100k IS NULL THEN 0 ELSE 1 END)
            + (CASE WHEN taxa_feminicidios_100k IS NULL THEN 0 ELSE 1 END)
            + (CASE WHEN taxa_estupros_100k IS NULL THEN 0 ELSE 1 END),
            0
        ) AS risco_indice
    FROM base
)
SELECT
    id_tempo_dw,
    id_municipio_dw,
    id_educacao_dw,
    codigo_municipio,
    ano,
    populacao_total,
    populacao_crescimento_pct,
    idhm,
    idhm_renda,
    idhm_educacao,
    idhm_longevidade,
    ano_referencia_idhm,
    ideb,
    fluxo,
    aprendizado,
    nota_mt,
    nota_lp,
    crimes_total_indicadores,
    mortes_violentas_intencionais,
    homicidios_dolosos,
    feminicidios,
    estupros,
    furto_veiculos,
    roubo_veiculos,
    latrocinios,
    taxa_crimes_100k,
    taxa_mortes_violentas_100k,
    taxa_homicidios_100k,
    taxa_feminicidios_100k,
    taxa_estupros_100k,
    taxa_furto_veiculos_100k,
    risco_indice
FROM base_risco;

SELECT COUNT(*) AS total_fato
FROM dw.fato_municipio_ano;

SELECT
    ano,
    COUNT(*) AS qtd_municipios
FROM dw.fato_municipio_ano
GROUP BY ano
ORDER BY ano;

SELECT
    municipio.nome_municipio,
    fato.ano,
    fato.populacao_total,
    fato.idhm,
    fato.ideb,
    fato.taxa_crimes_100k,
    fato.risco_indice
FROM dw.fato_municipio_ano AS fato
JOIN dw.dim_municipio AS municipio
    ON municipio.id_municipio_dw = fato.id_municipio_dw
WHERE fato.ano = 2019
ORDER BY municipio.nome_municipio ASC;

CREATE TABLE dw.fato_crime_municipio_ano_indicador (
    id_fato_crime_municipio_ano_indicador_dw SERIAL PRIMARY KEY,
    id_tempo_dw INTEGER NOT NULL,
    id_municipio_dw INTEGER NOT NULL,
    id_indicador_crime_dw INTEGER NOT NULL,
    codigo_municipio INTEGER NOT NULL,
    ano INTEGER NOT NULL,
    quantidade NUMERIC(18, 2),
    populacao_total NUMERIC(18, 2),
    taxa_100k NUMERIC(18, 6),
    CONSTRAINT fk_fato_crime_tempo
        FOREIGN KEY (id_tempo_dw)
        REFERENCES dw.dim_tempo (id_tempo_dw),
    CONSTRAINT fk_fato_crime_municipio
        FOREIGN KEY (id_municipio_dw)
        REFERENCES dw.dim_municipio (id_municipio_dw),
    CONSTRAINT fk_fato_crime_indicador
        FOREIGN KEY (id_indicador_crime_dw)
        REFERENCES dw.dim_indicador_crime (id_indicador_crime_dw),
    CONSTRAINT uk_fato_crime_municipio_ano_indicador
        UNIQUE (id_municipio_dw, id_tempo_dw, id_indicador_crime_dw)
);

INSERT INTO dw.fato_crime_municipio_ano_indicador (
    id_tempo_dw,
    id_municipio_dw,
    id_indicador_crime_dw,
    codigo_municipio,
    ano,
    quantidade,
    populacao_total,
    taxa_100k
)
WITH crimes_long AS (
    SELECT
        CAST(crime.id_municipio AS INTEGER) AS codigo_municipio,
        CAST(crime.ano AS INTEGER) AS ano,
        indicador.nome_indicador,
        indicador.quantidade
    FROM raw.dataset_crimes AS crime
    CROSS JOIN LATERAL (
        VALUES
            ('quantidade_homicidio_doloso', NULLIF(REPLACE(crime.quantidade_homicidio_doloso, ',', '.'), '')::NUMERIC),
            ('quantidade_feminicidio', NULLIF(REPLACE(crime.quantidade_feminicidio, ',', '.'), '')::NUMERIC),
            ('quantidade_mortes_violentas_intencionais', NULLIF(REPLACE(crime.quantidade_mortes_violentas_intencionais, ',', '.'), '')::NUMERIC),
            ('quantidade_estupro', NULLIF(REPLACE(crime.quantidade_estupro, ',', '.'), '')::NUMERIC),
            ('quantidade_furto_veiculos', NULLIF(REPLACE(crime.quantidade_furto_veiculos, ',', '.'), '')::NUMERIC),
            ('quantidade_roubo_veiculos', NULLIF(REPLACE(crime.quantidade_roubo_veiculos, ',', '.'), '')::NUMERIC),
            ('quantidade_latrocinio', NULLIF(REPLACE(crime.quantidade_latrocinio, ',', '.'), '')::NUMERIC),
            ('quantidade_trafico_entorpecente', NULLIF(REPLACE(crime.quantidade_trafico_entorpecente, ',', '.'), '')::NUMERIC),
            ('quantidade_posse_uso_entorpecente', NULLIF(REPLACE(crime.quantidade_posse_uso_entorpecente, ',', '.'), '')::NUMERIC),
            ('quantidade_porte_ilegal_arma_de_fogo', NULLIF(REPLACE(crime.quantidade_porte_ilegal_arma_de_fogo, ',', '.'), '')::NUMERIC)
    ) AS indicador(nome_indicador, quantidade)
)
SELECT
    tempo.id_tempo_dw,
    municipio.id_municipio_dw,
    indicador_crime.id_indicador_crime_dw,
    municipio.codigo_municipio,
    tempo.ano,
    crimes_long.quantidade,
    fato_municipio.populacao_total,
    (crimes_long.quantidade / NULLIF(fato_municipio.populacao_total, 0)) * 100000 AS taxa_100k
FROM crimes_long
JOIN dw.dim_municipio AS municipio
    ON municipio.codigo_municipio = crimes_long.codigo_municipio
JOIN dw.dim_tempo AS tempo
    ON tempo.ano = crimes_long.ano
JOIN dw.dim_indicador_crime AS indicador_crime
    ON indicador_crime.nome_indicador = crimes_long.nome_indicador
LEFT JOIN dw.fato_municipio_ano AS fato_municipio
    ON fato_municipio.id_municipio_dw = municipio.id_municipio_dw
   AND fato_municipio.id_tempo_dw = tempo.id_tempo_dw;

CREATE TABLE dw.fato_populacao_municipio_ano_demografia (
    id_fato_populacao_municipio_ano_demografia_dw SERIAL PRIMARY KEY,
    id_tempo_dw INTEGER NOT NULL,
    id_municipio_dw INTEGER NOT NULL,
    id_sexo_dw INTEGER NOT NULL,
    id_grupo_idade_dw INTEGER NOT NULL,
    codigo_municipio INTEGER NOT NULL,
    ano INTEGER NOT NULL,
    populacao NUMERIC(18, 2) NOT NULL,
    CONSTRAINT fk_fato_populacao_tempo
        FOREIGN KEY (id_tempo_dw)
        REFERENCES dw.dim_tempo (id_tempo_dw),
    CONSTRAINT fk_fato_populacao_municipio
        FOREIGN KEY (id_municipio_dw)
        REFERENCES dw.dim_municipio (id_municipio_dw),
    CONSTRAINT fk_fato_populacao_sexo
        FOREIGN KEY (id_sexo_dw)
        REFERENCES dw.dim_sexo (id_sexo_dw),
    CONSTRAINT fk_fato_populacao_grupo_idade
        FOREIGN KEY (id_grupo_idade_dw)
        REFERENCES dw.dim_grupo_idade (id_grupo_idade_dw),
    CONSTRAINT uk_fato_populacao_municipio_ano_demografia
        UNIQUE (id_municipio_dw, id_tempo_dw, id_sexo_dw, id_grupo_idade_dw)
);

INSERT INTO dw.fato_populacao_municipio_ano_demografia (
    id_tempo_dw,
    id_municipio_dw,
    id_sexo_dw,
    id_grupo_idade_dw,
    codigo_municipio,
    ano,
    populacao
)
SELECT
    tempo.id_tempo_dw,
    municipio.id_municipio_dw,
    sexo.id_sexo_dw,
    grupo_idade.id_grupo_idade_dw,
    municipio.codigo_municipio,
    tempo.ano,
    SUM(CAST(pop.populacao AS NUMERIC)) AS populacao
FROM raw.dataset_populacao AS pop
JOIN dw.dim_municipio AS municipio
    ON municipio.codigo_municipio = CAST(pop.id_municipio AS INTEGER)
JOIN dw.dim_tempo AS tempo
    ON tempo.ano = CAST(pop.ano AS INTEGER)
JOIN dw.dim_sexo AS sexo
    ON sexo.sexo = TRIM(pop.sexo)
JOIN dw.dim_grupo_idade AS grupo_idade
    ON grupo_idade.grupo_idade = TRIM(pop.grupo_idade)
GROUP BY
    tempo.id_tempo_dw,
    municipio.id_municipio_dw,
    sexo.id_sexo_dw,
    grupo_idade.id_grupo_idade_dw,
    municipio.codigo_municipio,
    tempo.ano;

CREATE TABLE dw.fato_educacao_uf_ano (
    id_fato_educacao_uf_ano_dw SERIAL PRIMARY KEY,
    id_tempo_dw INTEGER NOT NULL,
    id_uf_dw INTEGER NOT NULL,
    id_educacao_dw INTEGER NOT NULL,
    codigo_uf_ibge INTEGER NOT NULL,
    ano INTEGER NOT NULL,
    ideb NUMERIC(8, 4),
    fluxo NUMERIC(8, 4),
    aprendizado NUMERIC(8, 4),
    nota_mt NUMERIC(10, 4),
    nota_lp NUMERIC(10, 4),
    CONSTRAINT fk_fato_educacao_tempo
        FOREIGN KEY (id_tempo_dw)
        REFERENCES dw.dim_tempo (id_tempo_dw),
    CONSTRAINT fk_fato_educacao_uf
        FOREIGN KEY (id_uf_dw)
        REFERENCES dw.dim_uf (id_uf_dw),
    CONSTRAINT fk_fato_educacao_dim
        FOREIGN KEY (id_educacao_dw)
        REFERENCES dw.dim_educacao (id_educacao_dw),
    CONSTRAINT uk_fato_educacao_uf_ano
        UNIQUE (id_uf_dw, id_tempo_dw, id_educacao_dw)
);

INSERT INTO dw.fato_educacao_uf_ano (
    id_tempo_dw,
    id_uf_dw,
    id_educacao_dw,
    codigo_uf_ibge,
    ano,
    ideb,
    fluxo,
    aprendizado,
    nota_mt,
    nota_lp
)
SELECT
    tempo.id_tempo_dw,
    uf.id_uf_dw,
    educacao.id_educacao_dw,
    uf.codigo_uf_ibge,
    tempo.ano,
    NULLIF(REPLACE(raw_educacao.ideb, ',', '.'), '')::NUMERIC AS ideb,
    NULLIF(REPLACE(raw_educacao.fluxo, ',', '.'), '')::NUMERIC AS fluxo,
    NULLIF(REPLACE(raw_educacao.aprendizado, ',', '.'), '')::NUMERIC AS aprendizado,
    NULLIF(REPLACE(raw_educacao.nota_mt, ',', '.'), '')::NUMERIC AS nota_mt,
    NULLIF(REPLACE(raw_educacao.nota_lp, ',', '.'), '')::NUMERIC AS nota_lp
FROM raw.dataset_educacao AS raw_educacao
JOIN dw.dim_uf AS uf
    ON uf.codigo_uf_ibge = CAST(raw_educacao.ibge_id AS INTEGER)
JOIN dw.dim_tempo AS tempo
    ON tempo.ano = CAST(raw_educacao.ano AS INTEGER)
JOIN dw.dim_educacao AS educacao
    ON educacao.ciclo_id = raw_educacao.ciclo_id
   AND educacao.dependencia_id = CAST(raw_educacao.dependencia_id AS INTEGER);

SELECT COUNT(*) AS total_fato_crime_municipio_ano_indicador
FROM dw.fato_crime_municipio_ano_indicador;

SELECT COUNT(*) AS total_fato_populacao_municipio_ano_demografia
FROM dw.fato_populacao_municipio_ano_demografia;

SELECT COUNT(*) AS total_fato_educacao_uf_ano
FROM dw.fato_educacao_uf_ano;

SELECT
    tempo.ano,
    COUNT(*) AS qtd_indicadores_crime
FROM dw.fato_crime_municipio_ano_indicador AS fato_crime
JOIN dw.dim_tempo AS tempo
    ON tempo.id_tempo_dw = fato_crime.id_tempo_dw
GROUP BY tempo.ano
ORDER BY tempo.ano;
