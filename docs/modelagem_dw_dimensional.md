# Modelagem Dimensional do Data Warehouse

Este documento registra a construcao do schema `dw`, das dimensoes e da tabela fato principal do projeto.

O objetivo do Data Warehouse e apoiar analises sobre seguranca publica no Brasil, combinando:

- criminalidade
- populacao
- IDHM
- educacao / IDEB

## 1. Desenho Geral

O modelo segue uma arquitetura estrela com snowflake parcial.

Granularidade da tabela fato:

```text
1 linha = 1 capital brasileira + 1 ano
```

Tabela fato principal:

```sql
dw.fato_municipio_ano
```

Dimensoes criadas:

```text
dw.dim_regiao
dw.dim_uf
dw.dim_municipio
dw.dim_tempo
dw.dim_educacao
dw.dim_indicador_crime
```

Snowflake parcial:

```text
dim_municipio -> dim_uf -> dim_regiao
```

Conceitos aplicados:

- dimensao tempo: `dw.dim_tempo`
- dimensao conformada: `dw.dim_municipio`
- snowflake parcial: municipio, UF e regiao
- chaves primarias e estrangeiras
- fato com granularidade clara

## 2. Pre-Requisito

Antes de criar o DW, os dados brutos precisam estar carregados no schema `raw`:

```text
raw.dataset_crimes
raw.dataset_populacao
raw.dataset_idhm
raw.dataset_educacao
```

O script responsavel por isso e:

```text
postgres-init/01-create_and_populate_raw.sql
```

## 3. Momento 1 - Criacao Do Schema DW

Primeiro criamos o schema dimensional:

```sql
CREATE SCHEMA IF NOT EXISTS dw;
```

Depois removemos tabelas antigas para recriar o modelo de forma controlada:

```sql
DROP TABLE IF EXISTS dw.fato_municipio_ano CASCADE;
DROP TABLE IF EXISTS dw.dim_municipio CASCADE;
DROP TABLE IF EXISTS dw.dim_uf CASCADE;
DROP TABLE IF EXISTS dw.dim_regiao CASCADE;
DROP TABLE IF EXISTS dw.dim_tempo CASCADE;
DROP TABLE IF EXISTS dw.dim_educacao CASCADE;
DROP TABLE IF EXISTS dw.dim_indicador_crime CASCADE;
```

## 4. Momento 2 - Criacao E Carga Das Dimensoes

### 4.1 `dw.dim_regiao`

Finalidade:

Guardar as regioes brasileiras.

Essa tabela e usada pela `dim_uf`, formando parte do snowflake parcial.

Validacao esperada:

```sql
SELECT COUNT(*) FROM dw.dim_regiao;
```

Resultado esperado:

```text
5
```

### 4.2 `dw.dim_uf`

Finalidade:

Guardar as unidades federativas e relaciona-las com suas regioes.

Relacao:

```text
dim_uf.id_regiao_dw -> dim_regiao.id_regiao_dw
```

Validacao esperada:

```sql
SELECT COUNT(*) FROM dw.dim_uf;
```

Resultado esperado:

```text
27
```

### 4.3 `dw.dim_tempo`

Finalidade:

Permitir analises temporais.

Campos principais:

```text
ano
decada
periodo_analise
```

Observacao:

O ano `2010` representa a referencia socioeconomica do IDHM. Os anos `2016` a `2021` representam o periodo principal de analise.

Validacao:

```sql
SELECT *
FROM dw.dim_tempo
ORDER BY ano;
```

### 4.4 `dw.dim_educacao`

Finalidade:

Guardar o contexto educacional do IDEB.

Ela nao guarda o valor do IDEB. Os valores numericos ficam na fato.

Campos principais:

```text
ciclo_id
descricao_ciclo
dependencia_id
descricao_dependencia
```

Exemplo:

```text
EM + Total
EM + Estadual
EM + Privada
```

### 4.5 `dw.dim_indicador_crime`

Finalidade:

Documentar os indicadores criminais usados no projeto.

Ela ajuda a classificar crimes por categoria, como:

- crimes contra a vida
- crimes sexuais
- crimes patrimoniais
- drogas
- armas

### 4.6 `dw.dim_municipio`

Finalidade:

Guardar as capitais brasileiras analisadas.

Esta dimensao e conformada, pois conecta crimes, populacao, IDHM e educacao.

Ponto importante:

Inicialmente tentamos popular `dim_municipio` a partir de `raw.dataset_populacao`. Isso trouxe municipios homonimos, como:

```text
Belem
Boa Vista
Campo Grande
Palmas
Rio Branco
```

Por isso, a versao final da `dim_municipio` usa uma lista controlada das 27 capitais com codigo IBGE correto.

Validacao:

```sql
SELECT COUNT(*) AS total_municipios
FROM dw.dim_municipio;
```

Resultado esperado:

```text
27
```

Validacao para homonimos:

```sql
SELECT
    nome_municipio,
    COUNT(*) AS qtd,
    STRING_AGG(codigo_municipio::TEXT, ', ') AS codigos
FROM dw.dim_municipio
GROUP BY nome_municipio
HAVING COUNT(*) > 1
ORDER BY nome_municipio;
```

Resultado esperado:

```text
0 linhas
```

## 5. Momento 3 - Criacao Da Fato

Tabela:

```sql
dw.fato_municipio_ano
```

Granularidade:

```text
1 capital + 1 ano
```

Chaves estrangeiras:

```text
id_tempo_dw
id_municipio_dw
id_educacao_dw
```

Medidas principais:

```text
populacao_total
populacao_crescimento_pct
idhm
idhm_renda
idhm_educacao
idhm_longevidade
ideb
fluxo
aprendizado
nota_mt
nota_lp
crimes_total_indicadores
mortes_violentas_intencionais
homicidios_dolosos
feminicidios
estupros
furto_veiculos
roubo_veiculos
latrocinios
taxa_crimes_100k
taxa_mortes_violentas_100k
taxa_homicidios_100k
taxa_feminicidios_100k
taxa_estupros_100k
taxa_furto_veiculos_100k
risco_indice
```

## 6. Como A Fato E Populada

A carga da fato usa CTEs para organizar as transformacoes:

```text
populacao_agg
populacao_final
crimes
crimes_final
idhm
educacao
base
base_risco
```

Papel de cada etapa:

- `populacao_agg`: agrega populacao por municipio e ano
- `populacao_final`: calcula crescimento populacional percentual
- `crimes`: converte os campos criminais da raw para numerico
- `crimes_final`: calcula total agregado de indicadores criminais
- `idhm`: relaciona IDHM 2010 com a capital correspondente
- `educacao`: filtra IDEB de Ensino Medio e dependencia Total
- `base`: junta dimensoes e medidas
- `base_risco`: calcula um indice simples de risco

## 7. Validacoes Da Fato

Total de linhas:

```sql
SELECT COUNT(*) AS total_fato
FROM dw.fato_municipio_ano;
```

Quantidade de municipios por ano:

```sql
SELECT
    ano,
    COUNT(*) AS qtd_municipios
FROM dw.fato_municipio_ano
GROUP BY ano
ORDER BY ano;
```

Resultado esperado:

```text
27 municipios por ano
```

Consulta analitica de conferencia:

```sql
SELECT
    municipio.nome_municipio,
    fato.ano,
    fato.populacao_total,
    fato.idhm,
    fato.ideb,
    fato.taxa_crimes_100k,
    fato.risco_indice
FROM dw.fato_municipio_ano AS fato
JOIN dw.dim_municipio AS municipio
    ON municipio.id_municipio_dw = fato.id_municipio_dw
WHERE fato.ano = 2019
ORDER BY municipio.nome_municipio ASC;
```

Resultado esperado:

```text
27 linhas para 2019
```

## 8. Scripts Oficiais

Os scripts versionados sao:

```text
postgres-init/01-create_and_populate_raw.sql
postgres-init/02-create_and_populate_dw.sql
postgres-init/03-create_datamart.sql
```

Ordem de execucao:

```text
1. Executar raw
2. Executar dw
3. Validar contagens
4. Executar datamart
5. Conectar Metabase / ML
```
