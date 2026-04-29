# notebooks

Fluxo sugerido para o projeto:

1. `01_exploracao_dados.ipynb`
2. `02_limpeza_tratamento.ipynb`
3. `03_integracao_feature_engineering.ipynb`
4. `04_modelagem_regressao_linear.ipynb`
5. `05_exportacao_mongodb.ipynb`

Objetivo:

- explorar os arquivos brutos
- limpar e padronizar as bases
- integrar os datasets por `codigo_municipio + ano`
- gerar features
- treinar o baseline de regressao linear
- salvar os resultados no MongoDB

Organizacao dos notebooks:

- cada notebook e organizado por fonte de dados
- cada fonte deve gerar um dataframe tratado proprio
- a integracao entre fontes acontece apenas no notebook 03

Fontes previstas:

- IDH
- crimes
- populacao
- educacao
