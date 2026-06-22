# Apresentação do Projeto e Dashboard de Machine Learning

Este documento reúne (1) o **roteiro de apresentação** para mostrar a força do projeto e
(2) os **cards do novo dashboard de ML no Metabase**, com a view, a query e o tipo de
gráfico de cada um.

> Fonte dos dados de ML: schema `ml` no PostgreSQL (`seguranca_publica`). As views já estão
> criadas por `postgres-init/04-create_ml_datamart.sql`. Rode o notebook 01 antes (cria as
> tabelas) e depois o SQL (cria as views).

---

## Parte 1 — Roteiro de Apresentação

**Princípio:** a força deste projeto não é "treinamos um modelo". É a **maturidade**:
arquitetura de dados real (DW dimensional), rigor (baseline, validação temporal) e
**honestidade científica** (dois eixos). A apresentação deve contar essa história, não só
mostrar telas.

### Estrutura sugerida (≈ 12–15 min)

| # | Etapa | Tempo | O que mostrar | Frase-chave |
| --- | --- | --- | --- | --- |
| 1 | **Contexto e pergunta** | 1–2 min | O problema: fatores socioeconômicos influenciam a criminalidade? | "Queremos entender e prever criminalidade nas capitais com dados públicos." |
| 2 | **Arquitetura de dados** | 2 min | Diagrama do README (raw → dw → datamart → Metabase/ML) | "Não é um CSV no pandas: é um Data Warehouse dimensional com camadas." |
| 3 | **Dashboards descritivos** | 3 min | Metabase: Dash 1 (visão geral), Dash 2 (categorias), Dash 3 (socioeconômico) | "Aqui está o panorama da segurança pública por capital e região." |
| 4 | **Dashboard de ML** | 3 min | O dashboard novo (Parte 2 deste doc) | "E aqui é onde fomos honestos sobre o que o modelo realmente faz." |
| 5 | **Notebooks (só o essencial)** | 2 min | Conclusões dos dois eixos + 2–3 gráficos-chave. NÃO rodar célula a célula. | "O código está aqui, mas o resultado importante é este." |
| 6 | **Punch line científico** | 1–2 min | As duas descobertas honestas | ver abaixo |
| 7 | **Limitações e próximos passos** | 1 min | Seção de limitações do README | "Sabemos exatamente onde o projeto pode crescer." |

### As duas descobertas que são a força do projeto (etapa 6)

Memorize estas duas frases — são o diferencial:

1. **"O modelo prevê por inércia, não por mágica."**
   Comparamos o Random Forest contra um baseline ingênuo (repetir o ano anterior). Em quase
   todas as categorias o ganho é pequeno ou nulo — exceto a **taxa geral de crimes**, onde o
   RF agrega valor real (+0,17 de R² sobre o baseline). Isso é honestidade que uma banca
   respeita.

2. **"Educação se associa à violência letal, mas não ao crime patrimonial."**
   No nível UF, IDEB e notas têm correlação negativa moderada e consistente com homicídios
   (−0,49 a −0,61), mas correlação ~0 com a taxa geral de crimes (que inclui furto/roubo).
   Dois notebooks independentes (01 e 02) e dois níveis (capital e UF) concordam.

### Erros a evitar na apresentação

- **Não rode o notebook ao vivo** célula a célula (entedia, arrisca travar/kernel). Mostre
  outputs já salvos.
- **Não diga "R² de 0,72, ótimo modelo"** sem citar o baseline — você mesmo provou que é
  inércia. Diga a verdade; é mais forte.
- **Não compare R² entre categorias** com splits diferentes (está sinalizado no notebook).
- Trate **feminicídios** como "não modelável com os dados atuais", não como resultado ruim.

---

## Parte 2 — Dashboard de ML no Metabase

**Nome sugerido:** `Modelagem Preditiva — Segurança Pública`
**Banco:** `seguranca_publica` · **Schema:** `ml`

Organizado em **duas seções**: (A) Performance do modelo e (B) Honestidade científica.
Cada card abaixo tem: **view**, **query/colunas**, **tipo de visualização** e **para que serve**.

> No Metabase: crie um card com "Pergunta nativa (SQL)" colando a query, ou use o editor
> visual apontando para a view indicada. As queries abaixo são prontas para colar.

---

### Seção A — Performance do Modelo

#### Card A1 — Comparação RMSE por modelo e categoria
- **View:** `ml.vw_resumo_metricas_modelos`
- **Tipo:** gráfico de barras (eixo X = `target`, série = `modelo`, valor = `rmse`)
- **Query:**
```sql
SELECT target, modelo, rmse
FROM ml.vw_resumo_metricas_modelos
WHERE status_categoria = 'modelavel'
ORDER BY target, rmse;
```
- **Serve para:** mostrar que o Random Forest tem RMSE menor que a Regressão Linear.

#### Card A2 — R² por categoria (somente Random Forest, modeláveis)
- **View:** `ml.vw_resumo_metricas_modelos`
- **Tipo:** barras horizontais (X = `r2`, Y = `target`)
- **Query:**
```sql
SELECT target, r2
FROM ml.vw_resumo_metricas_modelos
WHERE modelo = 'Random Forest' AND status_categoria = 'modelavel'
ORDER BY r2 DESC;
```
- **Serve para:** desempenho do candidato principal por categoria.

#### Card A3 — Importância das variáveis (Random Forest)
- **View:** `ml.vw_importancia_variaveis_rf`
- **Tipo:** barras horizontais (X = `valor`, Y = `feature`), com filtro por `target`
- **Query:**
```sql
SELECT feature, valor, ranking_importancia
FROM ml.vw_importancia_variaveis_rf
WHERE target = 'Taxa geral de crimes'
ORDER BY valor DESC;
```
- **Serve para:** mostrar que o `lag1` domina (sustenta a tese da inércia). Troque o `target`
  no filtro para explorar outras categorias.

#### Card A4 — Maiores erros de previsão (tabela)
- **View:** `ml.vw_maiores_erros_modelo`
- **Tipo:** tabela
- **Query:**
```sql
SELECT ano, nome_municipio, sigla_uf, target,
       valor_real, valor_previsto, erro_absoluto
FROM ml.vw_maiores_erros_modelo
WHERE modelo = 'Random Forest'
ORDER BY erro_absoluto DESC
LIMIT 15;
```
- **Serve para:** transparência — onde o modelo erra mais (geralmente capitais atípicas).

#### Card A5 — Estratégia de split por categoria (tabela)
- **View:** `ml.vw_splits_modelagem`
- **Tipo:** tabela
- **Query:**
```sql
SELECT target, estrategia, anos_treino, anos_teste, linhas_treino, linhas_teste
FROM ml.vw_splits_modelagem
ORDER BY target;
```
- **Serve para:** mostrar rigor — cada categoria tem seu split temporal documentado.

---

### Seção B — Honestidade Científica (o diferencial)

#### Card B1 — Ganho do RF sobre o baseline de persistência (o card mais importante)
- **View:** `ml.vw_resumo_metricas_modelos`
- **Tipo:** barras (X = `target`, valor = `ganho_r2_vs_baseline_cv`), com linha de referência em 0
- **Query:**
```sql
SELECT target, ROUND(ganho_r2_vs_baseline_cv, 3) AS ganho_r2_vs_baseline
FROM ml.vw_resumo_metricas_modelos
WHERE modelo = 'Random Forest' AND status_categoria = 'modelavel'
ORDER BY ganho_r2_vs_baseline_cv DESC;
```
- **Serve para:** prova da tese. Barras > 0 = modelo agrega; ≤ 0 = só inércia. A "Taxa geral
  de crimes" deve aparecer como a única claramente positiva (+0,17).

#### Card B2 — R² do modelo vs. R² do baseline (lado a lado)
- **View:** `ml.vw_resumo_metricas_modelos`
- **Tipo:** barras agrupadas (X = `target`, séries = R² modelo e R² baseline)
- **Query:**
```sql
SELECT target,
       r2_medio_cv     AS r2_random_forest,
       r2_baseline_cv  AS r2_baseline
FROM ml.vw_resumo_metricas_modelos
WHERE modelo = 'Random Forest' AND status_categoria = 'modelavel'
ORDER BY target;
```
- **Serve para:** visual que mostra o quão perto o baseline chega do modelo.

#### Card B3 — Status das categorias (modelável vs. não modelável)
- **View:** `ml.vw_resumo_metricas_modelos`
- **Tipo:** tabela ou cartão com contagem
- **Query:**
```sql
SELECT DISTINCT target, status_categoria
FROM ml.vw_resumo_metricas_modelos
ORDER BY status_categoria, target;
```
- **Serve para:** mostrar que feminicídios foi honestamente marcado como não modelável.

#### Card B4 — Eixo B: poder dos fatores socioeconômicos (modelo sem lag1)
- **View:** `ml.vw_eixo_b_socioeconomico`
- **Tipo:** tabela ou barras (X = `target`, valor = `r2`)
- **Query:**
```sql
SELECT target, r2, ganho_rmse_vs_baseline_pct
FROM ml.vw_eixo_b_socioeconomico
ORDER BY r2 DESC;
```
- **Serve para:** mostrar que, sem o histórico, IDHM/educação preveem pouco (R² baixos).

#### Card B5 — Correlação socioeconômica × criminalidade (heatmap)
- **View:** `ml.vw_correlacao_socioeconomica`
- **Tipo:** mapa de calor (linhas = `fator_socioeconomico`, colunas = `taxa_alvo`, valor = `correlacao`)
- **Query:**
```sql
SELECT fator_socioeconomico, taxa_alvo, correlacao
FROM ml.vw_correlacao_socioeconomica
ORDER BY fator_socioeconomico, taxa_alvo;
```
- **Serve para:** o achado do Eixo B — IDHM negativamente associado à violência letal.

---

## Resumo dos cards

| Card | Seção | View | Visualização |
| --- | --- | --- | --- |
| A1 | Performance | `vw_resumo_metricas_modelos` | Barras (RMSE × modelo) |
| A2 | Performance | `vw_resumo_metricas_modelos` | Barras horizontais (R²) |
| A3 | Performance | `vw_importancia_variaveis_rf` | Barras horizontais |
| A4 | Performance | `vw_maiores_erros_modelo` | Tabela |
| A5 | Performance | `vw_splits_modelagem` | Tabela |
| B1 | Honestidade | `vw_resumo_metricas_modelos` | Barras (ganho vs. baseline) |
| B2 | Honestidade | `vw_resumo_metricas_modelos` | Barras agrupadas |
| B3 | Honestidade | `vw_resumo_metricas_modelos` | Tabela / cartão |
| B4 | Honestidade | `vw_eixo_b_socioeconomico` | Barras / tabela |
| B5 | Honestidade | `vw_correlacao_socioeconomica` | Mapa de calor |

---

## Observações

- Todas as queries usam apenas colunas que existem nas views (`postgres-init/04-create_ml_datamart.sql`).
- O **heatmap (B5)** pode exigir o formato "pivot" no Metabase; se a versão não tiver heatmap
  nativo, use uma tabela com formatação condicional por valor.
- Card **B1** é o que mais comunica a tese — destaque-o no topo da Seção B.
