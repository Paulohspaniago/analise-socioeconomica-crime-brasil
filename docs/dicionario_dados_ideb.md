# Dicionario de Dados - IDEB

Este documento descreve os campos do dataset de IDEB e indicadores educacionais associados.

Observação:

O dicionário abaixo cobre o layout amplo do dataset de educação/IDEB. No pipeline atual do projeto, o arquivo carregado em `raw.dataset_educacao` usa um recorte menor, com os campos:

```text
ibge_id
dependencia_id
ciclo_id
ano
ideb
fluxo
aprendizado
nota_mt
nota_lp
```

Esses campos alimentam `dw.dim_educacao`, `dw.fato_educacao_uf_ano`, `dw.fato_municipio_ano` e as views educacionais no `datamart`.

| Campo | Descricao | Valores / Formato |
| --- | --- | --- |
| `ibge_id` | Codigo IBGE da unidade da federacao e municipios | `7` - Brasil; `11` - RO; `12` - AC; `13` - AM; `14` - RR; `15` - PA; `16` - AP; `17` - TO; `21` - MA; `22` - PI; `23` - CE; `24` - RN; `25` - PB; `26` - PE; `27` - AL; `28` - SE; `29` - BA; `31` - MG; `32` - ES; `33` - RJ; `35` - SP; `41` - PR; `42` - SC; `43` - RS; `50` - MS; `51` - MT; `52` - GO; `53` - DF; 7 digitos - codigo dos municipios |
| `inep_id` | Codigo Inep para as escolas | 8 digitos |
| `ano` | Ano de coleta do indicador selecionado | 4 digitos |
| `ciclo_id` | Etapa da educacao basica | `AI` - Anos Iniciais; `AF` - Anos Finais; `EM` - Ensino Medio |
| `dependencia_id` | Dependencia administrativa | `0` - Total; `1` - Federal; `2` - Estadual; `3` - Municipal; `4` - Privada; `5` - Publica |
| `localizacao_id` | Localizacao | `0` - Total; `1` - Urbana; `2` - Rural |
| `serie_id` | Ano escolar | `1` - 1o ano EF; `2` - 2o ano EF; `3` - 3o ano EF; `4` - 4o ano EF; `5` - 5o ano EF; `6` - 6o ano EF; `7` - 7o ano EF; `8` - 8o ano EF; `9` - 9o ano EF; `10` - 1o ano EM; `11` - 2o ano EM; `12` - 3o ano EM |
| `lp_adequado` | Percentual de alunos com aprendizado adequado em Lingua Portuguesa | 1o ano |
| `mt_adequado` | Percentual de alunos com aprendizado adequado em Matematica | 1o ano |
| `lp_insuficiente` | Percentual de alunos com aprendizado insuficiente em Lingua Portuguesa | Valor entre 0 e 1 |
| `lp_basico` | Percentual de alunos com aprendizado basico em Lingua Portuguesa | Valor entre 0 e 1 |
| `lp_proficiente` | Percentual de alunos com aprendizado proficiente em Lingua Portuguesa | Valor entre 0 e 1 |
| `lp_avancado` | Percentual de alunos com aprendizado avancado em Lingua Portuguesa | Valor entre 0 e 1 |
| `mt_insuficiente` | Percentual de alunos com aprendizado insuficiente em Matematica | Valor entre 0 e 1 |
| `mt_basico` | Percentual de alunos com aprendizado basico em Matematica | Valor entre 0 e 1 |
| `mt_proficiente` | Percentual de alunos com aprendizado proficiente em Matematica | Valor entre 0 e 1 |
| `mt_avancado` | Percentual de alunos com aprendizado avancado em Matematica | Valor entre 0 e 1 |
| `ideb` | Valor do indice | Valor entre 0 e 10 |
| `fluxo` | Media harmonica do percentual de alunos aprovados da etapa | Valor entre 0 e 1 |
| `aprendizado` | Media das notas padronizadas de aprendizado de Lingua Portuguesa e Matematica dos alunos | Valor entre 0 e 10 |
| `nota_mt` | Proficiencia do aluno em Matematica transformada na escala unica do SAEB, com media = 250 e desvio = 50, conforme SAEB/97 | Valor entre 0 e 1000 |
| `nota_lp` | Proficiencia em Lingua Portuguesa transformada na escala unica do SAEB, com media = 250 e desvio = 50, conforme SAEB/97 | Valor entre 0 e 1000 |
| `matriculas` | Numero de matriculados | Valor inteiro |
| `aprovados` | Percentual de alunos aprovados no ano escolar | Valor entre 0 e 100 |
| `reprovados` | Percentual de alunos reprovados no ano escolar | Valor entre 0 e 100 |
| `abandonos` | Percentual de alunos que abandonaram o ano escolar | Valor entre 0 e 100 |
| `ef_1ano` | Percentual de alunos em distorcao idade-serie no 1o ano EF | Valor entre 0 e 100 |
| `ef_2ano` | Percentual de alunos em distorcao idade-serie no 2o ano EF | Valor entre 0 e 100 |
| `ef_3ano` | Percentual de alunos em distorcao idade-serie no 3o ano EF | Valor entre 0 e 100 |
| `ef_4ano` | Percentual de alunos em distorcao idade-serie no 4o ano EF | Valor entre 0 e 100 |
| `ef_5ano` | Percentual de alunos em distorcao idade-serie no 5o ano EF | Valor entre 0 e 100 |
| `ef_6ano` | Percentual de alunos em distorcao idade-serie no 6o ano EF | Valor entre 0 e 100 |
| `ef_7ano` | Percentual de alunos em distorcao idade-serie no 7o ano EF | Valor entre 0 e 100 |
| `ef_8ano` | Percentual de alunos em distorcao idade-serie no 8o ano EF | Valor entre 0 e 100 |
| `ef_9ano` | Percentual de alunos em distorcao idade-serie no 9o ano EF | Valor entre 0 e 100 |
| `ef_total_ai` | Percentual de alunos em distorcao idade-serie dos Anos Iniciais | Valor entre 0 e 100 |
| `ef_total_af` | Percentual de alunos em distorcao idade-serie dos Anos Finais | Valor entre 0 e 100 |
| `ef_total` | Percentual de alunos em distorcao idade-serie no Ensino Fundamental | Valor entre 0 e 100 |
| `em_1ano` | Percentual de alunos em distorcao idade-serie no 1o ano EM | Valor entre 0 e 100 |
| `em_2ano` | Percentual de alunos em distorcao idade-serie no 2o ano EM | Valor entre 0 e 100 |
| `em_3ano` | Percentual de alunos em distorcao idade-serie no 3o ano EM | Valor entre 0 e 100 |
| `em_4ano` | Percentual de alunos em distorcao idade-serie no 4o ano EM | Valor entre 0 e 100 |
| `em_total` | Percentual de alunos em distorcao idade-serie no Ensino Medio | Valor entre 0 e 100 |
| `ano_nascimento` | Ano de nascimento da geracao | 4 digitos |
| `ano_censo` | Ano do Censo avaliado | 4 digitos |
| `permanencia` | Percentual de nascidos na geracao matriculado na escola | Valor entre 0 e 1 |
| `fora` | Percentual de nascidos na geracao fora da escola | Valor entre 0 e 1 |
