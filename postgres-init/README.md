# postgres-init

Scripts executados automaticamente pelo container PostgreSQL na primeira criacao do volume `postgres_data`.

Ordem atual:

1. `01_create_schemas.sql`
2. `02_create_dw_model.sql`
3. `03_seed_dimensions.sql`
4. `04_datamart_views.sql`

Observacao:

- esses scripts rodam automaticamente apenas quando o volume do PostgreSQL ainda nao existe
- se a estrutura mudar depois de o volume ja ter sido criado, aplique os scripts manualmente ou recrie o volume de desenvolvimento
