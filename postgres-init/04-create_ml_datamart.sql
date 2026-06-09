CREATE SCHEMA IF NOT EXISTS ml;

DROP VIEW IF EXISTS ml.vw_resumo_metricas_modelos;
DROP VIEW IF EXISTS ml.vw_melhor_modelo_por_categoria;
DROP VIEW IF EXISTS ml.vw_maiores_erros_modelo;
DROP VIEW IF EXISTS ml.vw_importancia_variaveis_rf;
DROP VIEW IF EXISTS ml.vw_splits_modelagem;
DROP VIEW IF EXISTS ml.vw_eixo_b_socioeconomico;
DROP VIEW IF EXISTS ml.vw_correlacao_socioeconomica;

CREATE VIEW ml.vw_resumo_metricas_modelos AS
SELECT
    target,
    modelo,
    ROUND(mae::NUMERIC, 4) AS mae,
    ROUND(rmse::NUMERIC, 4) AS rmse,
    ROUND(rmse_baseline::NUMERIC, 4) AS rmse_baseline,
    ROUND(ganho_rmse_vs_baseline_pct::NUMERIC, 2) AS ganho_rmse_vs_baseline_pct,
    ROUND(r2::NUMERIC, 4) AS r2,
    ROUND(r2_medio_cv::NUMERIC, 4) AS r2_medio_cv,
    ROUND(r2_desvio_cv::NUMERIC, 4) AS r2_desvio_cv,
    ROUND(r2_baseline_cv::NUMERIC, 4) AS r2_baseline_cv,
    ROUND(ganho_r2_vs_baseline_cv::NUMERIC, 4) AS ganho_r2_vs_baseline_cv,
    comparavel_entre_categorias,
    status_categoria,
    previsoes_negativas,
    linhas_treino,
    linhas_teste
FROM ml.metricas_modelos;

CREATE VIEW ml.vw_melhor_modelo_por_categoria AS
SELECT
    target,
    modelo,
    ROUND(mae::NUMERIC, 4) AS mae,
    ROUND(rmse::NUMERIC, 4) AS rmse,
    ROUND(r2::NUMERIC, 4) AS r2,
    previsoes_negativas,
    linhas_treino,
    linhas_teste
FROM ml.melhores_modelos;

CREATE VIEW ml.vw_maiores_erros_modelo AS
SELECT
    ano,
    codigo_municipio,
    nome_municipio,
    sigla_uf,
    nome_regiao,
    target,
    modelo,
    ROUND(valor_real::NUMERIC, 4) AS valor_real,
    ROUND(valor_previsto::NUMERIC, 4) AS valor_previsto,
    ROUND(residuo::NUMERIC, 4) AS residuo,
    ROUND(erro_absoluto::NUMERIC, 4) AS erro_absoluto,
    DENSE_RANK() OVER (
        PARTITION BY target, modelo
        ORDER BY erro_absoluto DESC
    ) AS ranking_erro
FROM ml.previsoes_modelos;

CREATE VIEW ml.vw_importancia_variaveis_rf AS
SELECT
    target,
    modelo,
    feature,
    tipo_importancia,
    ROUND(valor::NUMERIC, 6) AS valor,
    DENSE_RANK() OVER (
        PARTITION BY target, modelo
        ORDER BY valor DESC
    ) AS ranking_importancia
FROM ml.importancia_variaveis
WHERE modelo = 'Random Forest';

CREATE VIEW ml.vw_splits_modelagem AS
SELECT
    target,
    coluna_target,
    estrategia,
    anos_treino,
    anos_teste,
    linhas_treino,
    linhas_teste
FROM ml.splits_modelagem;

CREATE VIEW ml.vw_eixo_b_socioeconomico AS
SELECT
    target,
    modelo,
    ROUND(rmse::NUMERIC, 4) AS rmse,
    ROUND(rmse_baseline::NUMERIC, 4) AS rmse_baseline,
    ROUND(ganho_rmse_vs_baseline_pct::NUMERIC, 2) AS ganho_rmse_vs_baseline_pct,
    ROUND(r2::NUMERIC, 4) AS r2
FROM ml.eixo_b_socioeconomico;

CREATE VIEW ml.vw_correlacao_socioeconomica AS
SELECT
    fator_socioeconomico,
    taxa_alvo,
    ROUND(correlacao::NUMERIC, 3) AS correlacao
FROM ml.correlacao_socioeconomica;

SELECT COUNT(*) AS total_metricas_modelos
FROM ml.metricas_modelos;

SELECT COUNT(*) AS total_previsoes_modelos
FROM ml.previsoes_modelos;

SELECT COUNT(*) AS total_importancia_variaveis
FROM ml.importancia_variaveis;
