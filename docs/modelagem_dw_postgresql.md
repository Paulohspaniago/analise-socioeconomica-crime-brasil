# Modelagem DW - PostgreSQL

## Objetivo Analitico

O data warehouse deve apoiar a analise e previsao de incidentes de seguranca publica no Brasil, combinando criminalidade, IDH, populacao e educacao.

Objetivos principais:

- analisar relacao entre criminalidade e fatores socioeconomicos
- avaliar impacto de educacao, IDH e populacao na seguranca publica
- preparar dados para BI no Metabase
- preparar uma base analitica para regressao linear e modelos futuros

## Arquitetura De Dados

```text
raw
-> staging
-> dw
-> datamart_seguranca_publica
-> Metabase / ML
```

## Schemas

| Schema | Finalidade |
| --- | --- |
| `raw` | Guarda dados brutos ou quase brutos, preservando origem e carga |
| `staging` | Guarda dados limpos, tipados e padronizados |
| `dw` | Guarda o modelo dimensional em Star Schema com snowflake parcial |
| `datamart_seguranca_publica` | Guarda views analiticas preparadas para BI |

## Granularidade Da Fato Principal

Tabela fato:

```text
dw.fact_municipio_ano
```

Granularidade:

```text
1 linha = 1 municipio + 1 ano
```

Essa granularidade permite cruzar:

- criminalidade anual
- populacao anual
- IDHM de referencia
- indicadores educacionais anuais

## Dimensoes

Dimensoes iniciais:

- `dw.dim_tempo`
- `dw.dim_municipio`
- `dw.dim_uf`
- `dw.dim_regiao`
- `dw.dim_dependencia_administrativa`
- `dw.dim_ciclo_educacao`
- `dw.dim_localizacao`
- `dw.dim_sexo`
- `dw.dim_faixa_etaria`

## Conceitos Avancados Aplicados

| Conceito | Aplicacao |
| --- | --- |
| Dimensao tempo | `dw.dim_tempo` |
| Dimensao conformada | `dw.dim_municipio`, usada por crime, populacao, IDH e educacao |
| Snowflake parcial | `dim_municipio -> dim_uf -> dim_regiao` |
| Dimensao degenerada | `id_lote_carga` dentro da fato principal |

## Data Mart

Schema:

```text
datamart_seguranca_publica
```

View principal:

```text
datamart_seguranca_publica.vw_indicadores_municipio_ano
```

Uso:

- Metabase
- dashboards
- KPIs
- analise exploratoria
- exportacao para modelagem preditiva

## Indicadores Planejados

- populacao total
- crescimento populacional percentual
- IDHM
- IDHM renda
- IDHM educacao
- IDHM longevidade
- IDEB
- fluxo escolar
- aprendizado
- nota de matematica
- nota de lingua portuguesa
- total de crimes
- mortes violentas intencionais
- homicidios dolosos
- feminicidios
- estupros
- furtos de veiculos
- taxa de crimes por 100 mil habitantes
- taxa de mortes violentas por 100 mil habitantes
- taxa de homicidios por 100 mil habitantes
- taxa de feminicidios por 100 mil habitantes
- taxa de estupros por 100 mil habitantes
- taxa de furto de veiculos por 100 mil habitantes
- indice de risco

## Proxima Etapa

Depois da criacao da estrutura no PostgreSQL, o proximo passo e carregar os CSVs para o schema `raw` e transformar os dados para `staging`.
