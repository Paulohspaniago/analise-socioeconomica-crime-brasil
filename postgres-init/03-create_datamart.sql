CREATE SCHEMA IF NOT EXISTS datamart;

DROP VIEW IF EXISTS datamart.vw_base_modelagem_ml;
DROP VIEW IF EXISTS datamart.vw_educacao_criminalidade;
DROP VIEW IF EXISTS datamart.vw_ranking_risco_capitais;
DROP VIEW IF EXISTS datamart.vw_tendencia_criminalidade;
DROP VIEW IF EXISTS datamart.vw_crimes_por_tipo;
DROP VIEW IF EXISTS datamart.vw_indicadores_municipio_ano;

CREATE VIEW datamart.vw_indicadores_municipio_ano AS
SELECT
    fato.id_fato_municipio_ano_dw,

    tempo.ano,
    tempo.decada,
    tempo.periodo_analise,

    municipio.codigo_municipio,
    municipio.nome_municipio,
    municipio.nome_municipio_padronizado,

    uf.codigo_uf_ibge,
    uf.sigla_uf,
    uf.nome_uf,
    regiao.nome_regiao,

    educacao.ciclo_id,
    educacao.descricao_ciclo,
    educacao.dependencia_id,
    educacao.descricao_dependencia,

    fato.populacao_total,
    fato.populacao_crescimento_pct,

    fato.idhm,
    fato.idhm_renda,
    fato.idhm_educacao,
    fato.idhm_longevidade,
    fato.ano_referencia_idhm,

    fato.ideb,
    fato.fluxo,
    fato.aprendizado,
    fato.nota_mt,
    fato.nota_lp,

    fato.crimes_total_indicadores,
    fato.mortes_violentas_intencionais,
    fato.homicidios_dolosos,
    fato.feminicidios,
    fato.estupros,
    fato.furto_veiculos,
    fato.roubo_veiculos,
    fato.latrocinios,

    fato.taxa_crimes_100k,
    fato.taxa_mortes_violentas_100k,
    fato.taxa_homicidios_100k,
    fato.taxa_feminicidios_100k,
    fato.taxa_estupros_100k,
    fato.taxa_furto_veiculos_100k,

    fato.risco_indice,

    CASE
        WHEN fato.risco_indice IS NULL THEN 'Sem dados'
        WHEN fato.risco_indice >= 0.75 THEN 'Risco alto'
        WHEN fato.risco_indice >= 0.50 THEN 'Risco medio'
        WHEN fato.risco_indice >= 0.25 THEN 'Risco moderado'
        ELSE 'Risco baixo'
    END AS classificacao_risco,

    DENSE_RANK() OVER (
        PARTITION BY tempo.ano
        ORDER BY fato.risco_indice DESC NULLS LAST
    ) AS ranking_risco_ano,

    DENSE_RANK() OVER (
        PARTITION BY tempo.ano
        ORDER BY fato.taxa_crimes_100k DESC NULLS LAST
    ) AS ranking_taxa_crimes_ano,

    DENSE_RANK() OVER (
        PARTITION BY tempo.ano
        ORDER BY fato.taxa_homicidios_100k DESC NULLS LAST
    ) AS ranking_homicidios_ano
FROM dw.fato_municipio_ano AS fato
JOIN dw.dim_tempo AS tempo
    ON tempo.id_tempo_dw = fato.id_tempo_dw
JOIN dw.dim_municipio AS municipio
    ON municipio.id_municipio_dw = fato.id_municipio_dw
JOIN dw.dim_uf AS uf
    ON uf.id_uf_dw = municipio.id_uf_dw
JOIN dw.dim_regiao AS regiao
    ON regiao.id_regiao_dw = uf.id_regiao_dw
LEFT JOIN dw.dim_educacao AS educacao
    ON educacao.id_educacao_dw = fato.id_educacao_dw;

CREATE VIEW datamart.vw_crimes_por_tipo AS
SELECT
    tempo.ano,
    municipio.codigo_municipio,
    municipio.nome_municipio,
    uf.sigla_uf,
    uf.nome_uf,
    regiao.nome_regiao,
    indicador.nome_indicador,
    indicador.categoria_indicador,
    indicador.descricao_indicador,
    fato.quantidade,
    fato.populacao_total,
    fato.taxa_100k,
    DENSE_RANK() OVER (
        PARTITION BY tempo.ano, indicador.nome_indicador
        ORDER BY fato.taxa_100k DESC NULLS LAST
    ) AS ranking_tipo_crime_ano
FROM dw.fato_crime_municipio_ano_indicador AS fato
JOIN dw.dim_tempo AS tempo
    ON tempo.id_tempo_dw = fato.id_tempo_dw
JOIN dw.dim_municipio AS municipio
    ON municipio.id_municipio_dw = fato.id_municipio_dw
JOIN dw.dim_uf AS uf
    ON uf.id_uf_dw = municipio.id_uf_dw
JOIN dw.dim_regiao AS regiao
    ON regiao.id_regiao_dw = uf.id_regiao_dw
JOIN dw.dim_indicador_crime AS indicador
    ON indicador.id_indicador_crime_dw = fato.id_indicador_crime_dw;

CREATE VIEW datamart.vw_tendencia_criminalidade AS
WITH base AS (
    SELECT
        indicadores.*,
        LAG(indicadores.taxa_crimes_100k) OVER (
            PARTITION BY indicadores.codigo_municipio
            ORDER BY indicadores.ano
        ) AS taxa_crimes_100k_ano_anterior,
        LAG(indicadores.taxa_mortes_violentas_100k) OVER (
            PARTITION BY indicadores.codigo_municipio
            ORDER BY indicadores.ano
        ) AS taxa_mortes_violentas_100k_ano_anterior,
        LAG(indicadores.risco_indice) OVER (
            PARTITION BY indicadores.codigo_municipio
            ORDER BY indicadores.ano
        ) AS risco_indice_ano_anterior
    FROM datamart.vw_indicadores_municipio_ano AS indicadores
)
SELECT
    ano,
    codigo_municipio,
    nome_municipio,
    sigla_uf,
    nome_regiao,
    taxa_crimes_100k,
    taxa_crimes_100k_ano_anterior,
    (
        (taxa_crimes_100k - taxa_crimes_100k_ano_anterior)
        / NULLIF(taxa_crimes_100k_ano_anterior, 0)
    ) * 100 AS variacao_taxa_crimes_pct,
    taxa_mortes_violentas_100k,
    taxa_mortes_violentas_100k_ano_anterior,
    risco_indice,
    risco_indice_ano_anterior,
    CASE
        WHEN taxa_crimes_100k_ano_anterior IS NULL THEN 'Sem comparacao'
        WHEN (
            (taxa_crimes_100k - taxa_crimes_100k_ano_anterior)
            / NULLIF(taxa_crimes_100k_ano_anterior, 0)
        ) * 100 > 5 THEN 'Aumento'
        WHEN (
            (taxa_crimes_100k - taxa_crimes_100k_ano_anterior)
            / NULLIF(taxa_crimes_100k_ano_anterior, 0)
        ) * 100 < -5 THEN 'Queda'
        ELSE 'Estabilidade'
    END AS tendencia_criminalidade
FROM base;

CREATE VIEW datamart.vw_ranking_risco_capitais AS
SELECT
    ano,
    codigo_municipio,
    nome_municipio,
    sigla_uf,
    nome_uf,
    nome_regiao,
    taxa_crimes_100k,
    taxa_homicidios_100k,
    taxa_mortes_violentas_100k,
    risco_indice,
    classificacao_risco,
    ranking_risco_ano
FROM datamart.vw_indicadores_municipio_ano
ORDER BY
    ano,
    ranking_risco_ano;

CREATE VIEW datamart.vw_educacao_criminalidade AS
SELECT
    ano,
    codigo_municipio,
    nome_municipio,
    sigla_uf,
    nome_regiao,
    ciclo_id,
    descricao_ciclo,
    dependencia_id,
    descricao_dependencia,
    ideb,
    fluxo,
    aprendizado,
    nota_mt,
    nota_lp,
    idhm_educacao,
    taxa_crimes_100k,
    taxa_homicidios_100k,
    taxa_mortes_violentas_100k,
    risco_indice
FROM datamart.vw_indicadores_municipio_ano
WHERE ideb IS NOT NULL;

CREATE VIEW datamart.vw_base_modelagem_ml AS
WITH base AS (
    SELECT
        indicadores.*,
        LAG(indicadores.taxa_crimes_100k) OVER (
            PARTITION BY indicadores.codigo_municipio
            ORDER BY indicadores.ano
        ) AS taxa_crimes_100k_lag1,
        LAG(indicadores.taxa_mortes_violentas_100k) OVER (
            PARTITION BY indicadores.codigo_municipio
            ORDER BY indicadores.ano
        ) AS taxa_mortes_violentas_100k_lag1,
        LAG(indicadores.risco_indice) OVER (
            PARTITION BY indicadores.codigo_municipio
            ORDER BY indicadores.ano
        ) AS risco_indice_lag1
    FROM datamart.vw_indicadores_municipio_ano AS indicadores
)
SELECT
    ano,
    codigo_municipio,
    nome_municipio,
    sigla_uf,
    nome_regiao,
    populacao_total,
    populacao_crescimento_pct,
    idhm,
    idhm_renda,
    idhm_educacao,
    idhm_longevidade,
    ideb,
    fluxo,
    aprendizado,
    nota_mt,
    nota_lp,
    taxa_crimes_100k_lag1,
    taxa_mortes_violentas_100k_lag1,
    risco_indice_lag1,
    taxa_mortes_violentas_100k AS target_taxa_mortes_violentas_100k,
    taxa_crimes_100k AS target_taxa_crimes_100k
FROM base;

SELECT COUNT(*) AS total_vw_indicadores_municipio_ano
FROM datamart.vw_indicadores_municipio_ano;

SELECT COUNT(*) AS total_vw_crimes_por_tipo
FROM datamart.vw_crimes_por_tipo;

SELECT COUNT(*) AS total_vw_tendencia_criminalidade
FROM datamart.vw_tendencia_criminalidade;

SELECT COUNT(*) AS total_vw_ranking_risco_capitais
FROM datamart.vw_ranking_risco_capitais;

SELECT COUNT(*) AS total_vw_educacao_criminalidade
FROM datamart.vw_educacao_criminalidade;

SELECT COUNT(*) AS total_vw_base_modelagem_ml
FROM datamart.vw_base_modelagem_ml;

SELECT
    ano,
    COUNT(*) AS qtd_municipios,
    ROUND(AVG(taxa_crimes_100k), 2) AS media_taxa_crimes_100k,
    ROUND(AVG(risco_indice), 4) AS media_risco_indice
FROM datamart.vw_indicadores_municipio_ano
GROUP BY ano
ORDER BY ano;

SELECT
    ano,
    nome_municipio,
    sigla_uf,
    nome_regiao,
    taxa_crimes_100k,
    risco_indice,
    classificacao_risco,
    ranking_risco_ano
FROM datamart.vw_ranking_risco_capitais
WHERE ano = 2019
ORDER BY ranking_risco_ano;
