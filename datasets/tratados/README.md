# tratados

Pasta de saida dos notebooks de limpeza.

Os arquivos desta pasta sao derivados dos CSVs brutos em `datasets/` e devem servir como entrada limpa para:

- integracao no notebook 03
- cargas futuras no schema `staging`
- construcao do Data Warehouse

Arquivos esperados apos rodar `notebooks/02_limpeza_tratamento.ipynb`:

- `idh_municipio_2010_tratado.csv`
- `crimes_municipio_ano_tratado.csv`
- `populacao_municipio_ano_tratado.csv`
- `educacao_ideb_uf_ano_tratado.csv`
- `educacao_ideb_uf_ano_total_em_tratado.csv`
- `base_analitica_municipio_ano.csv`

Observacao:

- a base de educacao atual cobre 2017 a 2021
- por isso, a base analitica integrada fica com campos de educacao nulos para 2016
