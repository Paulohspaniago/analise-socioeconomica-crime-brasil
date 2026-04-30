CREATE OR REPLACE VIEW datamart_seguranca_publica.vw_indicadores_municipio_ano AS
SELECT
    f.ano,
    m.codigo_municipio,
    m.nome_municipio,
    u.sigla_uf,
    u.nome_uf,
    r.nome_regiao,
    f.populacao_total,
    f.populacao_crescimento_pct,
    f.idhm,
    f.idhm_renda,
    f.idhm_educacao,
    f.idhm_longevidade,
    f.ideb,
    f.fluxo,
    f.aprendizado,
    f.nota_mt,
    f.nota_lp,
    f.crimes_total,
    f.mortes_violentas_intencionais,
    f.homicidios_dolosos,
    f.feminicidios,
    f.estupros,
    f.furto_veiculos,
    f.taxa_crimes_100k,
    f.taxa_mortes_violentas_100k,
    f.taxa_homicidios_100k,
    f.taxa_feminicidios_100k,
    f.taxa_estupros_100k,
    f.taxa_furto_veiculos_100k,
    f.risco_indice
FROM dw.fact_municipio_ano f
JOIN dw.dim_municipio m ON m.sk_municipio = f.sk_municipio
JOIN dw.dim_uf u ON u.sk_uf = m.sk_uf
JOIN dw.dim_regiao r ON r.sk_regiao = u.sk_regiao;

COMMENT ON VIEW datamart_seguranca_publica.vw_indicadores_municipio_ano IS
'View analitica principal para Metabase, com indicadores por municipio e ano.';
