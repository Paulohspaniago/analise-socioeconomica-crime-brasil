# notebooks

Fluxo atual do projeto:

1. `01_machine_learning_baseline.ipynb`

Objetivo:

- consumir dados tratados e preparados no schema `datamart`
- preparar a base para modelagem
- comparar o baseline sem educação com o modelo principal com educação
- treinar Regressão Linear e Ridge Regression
- avaliar métricas como MAE, RMSE e R²
- futuramente salvar previsões/resultados para consumo no BI

Decisão de arquitetura:

- limpeza, padronização e integração acontecem no PostgreSQL
- o Jupyter fica reservado para Machine Learning e análises experimentais
- a fonte oficial para modelagem é o Data Mart

Fonte principal do notebook:

- `datamart.vw_base_modelagem_ml`

Modelos previstos:

- Modelo A: baseline sem educação
- Modelo B: modelo principal com educação
- Modelo B Ridge: versão regularizada do modelo principal

Observação:

O notebook usa split temporal. Com a base atual carregada até 2024, o plano oficial é treinar com 2017-2019 e testar com 2023-2024, evitando o período de pandemia.

O alvo principal do modelo é `target_taxa_mortes_violentas_100k`, pois esse indicador possui cobertura completa para as capitais no período atual. A taxa total de crimes permanece disponível para análise, mas não é usada como alvo principal enquanto houver indicadores pós-pandemia ausentes em nível de capital.
