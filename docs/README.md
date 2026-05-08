# docs

Esta pasta centraliza a documentação técnica complementar do projeto.

Documentos principais:

- `modelagem_dw_dimensional.md`: documentação oficial da modelagem dimensional, fatos, dimensões, Data Mart e scripts SQL.
- `dicionario_dados_ideb.md`: dicionário de dados do dataset de educação/IDEB.

Fluxo documentado:

```text
datasets/
-> raw
-> dw
-> datamart
-> Metabase / Machine Learning
```

Quando atualizar esta pasta:

- ao criar novas tabelas fato ou dimensões;
- ao criar novas views no Data Mart;
- ao alterar a granularidade de alguma tabela;
- ao adicionar ou substituir datasets;
- ao mudar a estratégia de Machine Learning.

