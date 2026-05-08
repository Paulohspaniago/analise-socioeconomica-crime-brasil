# datasets

Pasta destinada aos arquivos de dados do projeto.

Organização atual:

```text
datasets/
├── auxiliares/
├── crimes/
├── educacao/
├── idh/
└── populacao/
```

Arquivos principais esperados:

- `datasets/crimes/2016-2021.csv`
- `datasets/populacao/2016-2021.csv`
- `datasets/idh/data_idhm_2010.csv`
- `datasets/educacao/2017-2021idep.csv`

Boas práticas:

- manter os arquivos brutos sem sobrescrever o original;
- usar nomes consistentes por fonte e ano;
- documentar a origem de cada arquivo na documentação do projeto;
- evitar salvar aqui arquivos finais tratados;
- não versionar arquivos temporários, exportações manuais ou bases derivadas.

Arquivos tratados e consolidados não devem ser versionados nesta pasta. A fonte oficial dos dados tratados é o PostgreSQL, principalmente o schema `dw`.

Fluxo oficial:

```text
datasets/
-> raw
-> dw
-> datamart
-> Metabase / Machine Learning
```
