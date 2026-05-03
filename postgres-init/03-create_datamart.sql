CREATE SCHEMA IF NOT EXISTS datamart;

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

SELECT COUNT(*) AS total_vw_indicadores_municipio_ano
FROM datamart.vw_indicadores_municipio_ano;

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
FROM datamart.vw_indicadores_municipio_ano
WHERE ano = 2019
ORDER BY ranking_risco_ano;
