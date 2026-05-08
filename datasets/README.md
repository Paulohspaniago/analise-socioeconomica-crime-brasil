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
- `datasets/crimes/2022-2024.csv`
- `datasets/populacao/2016-2021.csv`
- `datasets/populacao/2022-2024.csv`
- `datasets/idh/data_idhm_2010.csv`
- `datasets/educacao/2017-2021idep.csv`
- `datasets/educacao/idep2023.csv`

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

## Observação sobre os dados pós-pandemia

O arquivo `datasets/crimes/2022-2024.csv` consolida os dados pós-pandemia de segurança pública no mesmo layout usado pelo arquivo histórico `2016-2021.csv`.

Importante:

- a base de crimes cobre atualmente `2016` a `2024`;
- a base de população cobre atualmente `2016` a `2024`;
- a base de educação possui dados de `2017`, `2019`, `2021` e `2023`;
- ainda não há dados de `2025` carregados no projeto.

Limitação:

As tabelas de capitais dos anuários pós-pandemia trazem indicadores de violência letal, como MVI, homicídio doloso, feminicídio, latrocínio e lesão corporal seguida de morte. Outros indicadores, como estupro e roubo/furto de veículos, aparecem nos anuários em nível de UF, não em nível de capital. Por isso, esses campos ficam vazios no CSV pós-pandemia e são preservados como `NULL` no Data Warehouse.
