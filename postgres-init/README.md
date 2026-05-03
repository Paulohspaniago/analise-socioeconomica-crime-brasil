# postgres-init

Esta pasta contém os scripts SQL usados para criar e popular o banco analítico no PostgreSQL.

O pipeline atual é:

```text
datasets/
-> raw
-> dw
-> Metabase / Machine Learning
```

## Ordem de Execução

Execute os scripts nesta ordem:

1. `01-create_and_populate_raw.sql`
2. `02-create_and_populate_dw.sql`

O prefixo numérico é intencional. Ele facilita o entendimento do pipeline e deixa a ordem de execução explícita.

## Scripts

### `01-create_and_populate_raw.sql`

Cria o schema `raw` e carrega os arquivos CSV originais em tabelas brutas.

Tabelas criadas:

- `raw.dataset_crimes`
- `raw.dataset_populacao`
- `raw.dataset_idhm`
- `raw.dataset_educacao`

Finalidade:

- preservar a estrutura original dos datasets;
- manter as colunas próximas aos arquivos de origem;
- armazenar os valores majoritariamente como `TEXT`;
- evitar transformações de negócio na camada bruta.

Arquivos CSV carregados:

- `/datasets/crimes/2016-2021.csv`
- `/datasets/populacao/2016-2021.csv`
- `/datasets/idh/data_idhm_2010.csv`
- `/datasets/educacao/2017-2021idep.csv`

### `02-create_and_populate_dw.sql`

Cria o schema `dw` e constrói o modelo dimensional usado para análise, BI e Machine Learning.

Principais dimensões:

- `dw.dim_regiao`
- `dw.dim_uf`
- `dw.dim_municipio`
- `dw.dim_tempo`
- `dw.dim_educacao`
- `dw.dim_indicador_crime`

Tabela fato principal:

- `dw.fato_municipio_ano`

Granularidade da fato:

```text
1 linha = 1 capital brasileira + 1 ano
```

O script também realiza transformações como:

- padronização de nomes de municípios;
- integração dos datasets por município/ano;
- cálculo do crescimento populacional;
- inclusão dos indicadores de IDHM;
- inclusão dos indicadores de IDEB;
- cálculo das taxas de criminalidade por 100 mil habitantes;
- cálculo do índice de risco.

## Como Executar

### Opção 1: Inicialização pelo Docker

Quando o volume do PostgreSQL é criado pela primeira vez, o Docker executa automaticamente os arquivos `.sql` montados na pasta de inicialização do container.

Use esta opção quando for iniciar o banco do zero.

### Opção 2: Query Tool do pgAdmin

Abra o pgAdmin e execute:

1. todo o conteúdo de `01-create_and_populate_raw.sql`;
2. todo o conteúdo de `02-create_and_populate_dw.sql`.

Esta é a opção mais simples durante o desenvolvimento.

### Opção 3: psql

De dentro do container do PostgreSQL:

```bash
psql -U postgres -d seguranca_publica -f /docker-entrypoint-initdb.d/01-create_and_populate_raw.sql
psql -U postgres -d seguranca_publica -f /docker-entrypoint-initdb.d/02-create_and_populate_dw.sql
```

## Observações Importantes

- Estes scripts recriam as tabelas de destino usando `DROP TABLE IF EXISTS`.
- Ao executar novamente, as tabelas atuais dos schemas `raw` e `dw` serão substituídas.
- Os comandos `COPY` dependem do volume de datasets montado no Docker como `/datasets`.
- Não coloque CSVs tratados em `datasets/`; a camada oficial de dados tratados é o schema `dw`.
- A documentação oficial do DW está em `docs/modelagem_dw_dimensional.md`.

