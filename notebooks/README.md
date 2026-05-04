# notebooks

Fluxo atual do projeto:

1. `01_machine_learning_baseline.ipynb`

Objetivo:

- consumir dados tratados e integrados do schema `dw`
- preparar a base para modelagem
- treinar o primeiro baseline de regressao linear
- avaliar metricas como MAE, RMSE e R2
- futuramente salvar previsoes/resultados para consumo no BI

Decisao de arquitetura:

- limpeza, padronizacao e integracao acontecem no PostgreSQL
- o Jupyter fica reservado para Machine Learning e analises experimentais
- a fonte oficial dos dados tratados e o Data Warehouse

Fonte principal:

- `dw.fato_municipio_ano`

