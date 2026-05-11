# notebooks

Fluxo atual do projeto:

1. `01_machine_learning_baseline.ipynb`

Objetivo:

- consumir dados tratados e preparados no schema `datamart`
- preparar a base para modelagem por categoria criminal
- comparar a Regressão Linear com o Random Forest Regressor para cada target
- avaliar métricas como MAE, RMSE, R² e previsões negativas
- gerar gráficos de avaliação: real vs previsto, resíduos, comparação de RMSE, maiores erros e importância das variáveis
- futuramente salvar previsões/resultados para consumo no BI

Decisão de arquitetura:

- limpeza, padronização e integração acontecem no PostgreSQL
- o Jupyter fica reservado para Machine Learning e análises experimentais
- a fonte oficial para modelagem é o Data Mart

Fonte principal do notebook:

- `datamart.vw_indicadores_municipio_ano`

Targets modelados:

- taxa geral de crimes
- mortes violentas intencionais
- homicídios dolosos
- feminicídios
- estupros
- furto de veículos
- roubo de veículos

Modelos previstos:

- Linear Regression: baseline simples e interpretável
- Random Forest Regressor: candidato principal por capturar relações não lineares

Decisão metodológica:

Cada categoria criminal é treinada separadamente, porque cada tipo de crime possui escala, comportamento e cobertura histórica próprios. Quando uma categoria não possui dados suficientes para o split pós-pandemia, o notebook usa uma estratégia temporal alternativa ou marca a categoria como insuficiente.

Observação:

O notebook usa split temporal. Com a base atual carregada até 2024, o plano oficial é treinar com 2017-2019 e testar com 2023-2024, evitando o período de pandemia.

Algumas categorias pós-pandemia podem ter cobertura limitada em nível de capital. Por isso, a análise de cobertura por target é parte obrigatória do notebook.
