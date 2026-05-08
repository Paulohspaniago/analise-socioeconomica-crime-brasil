# metabase-data

Pasta usada para persistência local do Metabase no Docker.

Ela deve permanecer montada como volume para que dashboards, perguntas e configurações não sejam perdidos ao reiniciar os containers.

## Uso no projeto

O Metabase deve se conectar ao PostgreSQL usando o serviço Docker:

```text
Host: postgres-service
Porta: 5432
Database: seguranca_publica
Usuario: postgres
Senha: postgres
Schema principal: datamart
```

Views recomendadas para dashboards:

- `datamart.vw_indicadores_municipio_ano`
- `datamart.vw_crimes_por_tipo`
- `datamart.vw_tendencia_criminalidade`
- `datamart.vw_ranking_risco_capitais`
- `datamart.vw_educacao_criminalidade`

View recomendada para apoio ao Machine Learning:

- `datamart.vw_base_modelagem_ml`

## Observação sobre versionamento

Esta pasta contém o banco interno do Metabase. Se for versionada no Git, pode gerar conflitos porque o arquivo é binário e muda sempre que dashboards ou perguntas são alterados.

Em um ambiente de produção, o ideal seria usar um banco externo para o Metabase ou exportar dashboards de forma controlada.
