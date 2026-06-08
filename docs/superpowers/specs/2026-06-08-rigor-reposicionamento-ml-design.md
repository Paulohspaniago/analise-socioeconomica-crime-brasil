# Design — Rigor + Reposicionamento da Camada de ML

**Data:** 2026-06-08
**Autor:** Paulo Paniago (com Claude)
**Status:** Aprovado para planejamento
**Escopo escolhido:** Rigor + Reposicionamento (não inclui engenharia/deploy)
**Objetivo declarado:** Defesa acadêmica + Portfólio + Aprendizado (os três juntos)

---

## 1. Problema e princípio norteador

O notebook `01_machine_learning_baseline.ipynb` hoje afirma, nas conclusões, que o
Random Forest "apresentou o melhor desempenho em todas as categorias" e lista R²
por categoria lado a lado como se fossem comparáveis. A leitura dos resultados reais
salvos no notebook mostra que isso é **enganoso**:

- Os R² foram medidos em **splits temporais diferentes** por categoria (umas testam
  em 2023-2024, outras em 2019, a taxa geral testa em 2021 com anos de pandemia).
  Portanto **não são comparáveis entre si**.
- Não há baseline. Um R² de 0,72 não significa nada sem saber o que "prever o ano
  anterior" (persistência) entregaria — e, com `lag1` como feature forte, é provável
  que o modelo esteja capturando **inércia temporal**, não os fatores socioeconômicos
  que dão nome ao projeto.
- Feminicídios tem R² ≈ -0,01 (pior que prever a média) listado ao lado dos demais
  como se fosse um resultado válido.

**Princípio norteador (decisão de design):**

> O gargalo deste projeto é o **dataset**, não o modelo.
>
> São ~243 linhas (27 capitais × 9 anos), IDHM fixo em 2010, educação/IDEB apenas
> em 2017/2019/2021/2023, e cobertura de crimes irregular pós-pandemia. Nenhum
> algoritmo (XGBoost incluso) muda o teto preditivo de um dataset desse tamanho e
> dessa qualidade.

Logo, "elevar o nível" **não pode significar "melhorar o R²"**. Significa elevar o
**rigor metodológico e a honestidade científica**, e reorganizar o projeto em
**dois eixos com tese própria**. Essa é a forma de satisfazer simultaneamente
defesa acadêmica (conclusões defensáveis), portfólio (maturidade) e aprendizado
(fazer ML do jeito certo).

---

## 2. Limitações do dataset (contexto que justifica todas as decisões)

Estas limitações são **dadas** e não serão "resolvidas" — serão **declaradas e
respeitadas** no design.

| Dimensão | Limitação |
| --- | --- |
| Período — crimes | 2016 a 2024 (sem 2025) |
| Período — população | 2016 a 2024 |
| Período — educação/IDEB | apenas 2017, 2019, 2021, 2023 (propagado via forward-fill por UF) |
| Período — IDHM | municipal de **2010**, fixo; indicador estrutural, não série anual |
| Granularidade | capital + ano; sem mês/dia/semana; educação parcialmente agregada por UF |
| Cobertura crimes | 2016-2021 completa; 2022-2024 com lacunas (estupro, furto/roubo de veículos podem faltar em nível de capital) |
| NULL | significa "dado ausente na fonte", não "ausência de crime" |
| Volume | ~243 registros — pequeno para ML; modelos são **análise preditiva inicial**, não produção |
| Pandemia | 2020-2022 enviesa tendências; evitar no teste quando possível |
| Causalidade | o modelo aponta padrões/associações, **não prova causalidade** |

---

## 3. Arquitetura da solução: dois eixos

Reorganizar a modelagem em dois eixos independentes, cada um com objetivo, métrica
e conclusão próprios. A decisão (confirmada com o usuário) é **separar os dois
objetivos** em vez de fundir tudo numa afirmação única.

### Eixo A — Previsão (onde `lag1` legitimamente manda)

Objetivo: prever a taxa criminal do ano seguinte, assumindo abertamente que o
principal motor é a inércia temporal (histórico do ano anterior). Aqui o modelo
**funciona** e isso é honesto.

Componentes:

1. **Split temporal padronizado (ponto 1).**
   - Regra: usar **um único regime temporal** para todas as categorias sempre que
     a cobertura permitir.
   - Onde a cobertura impedir, manter o split alternativo MAS marcar explicitamente
     na tabela de resultados a coluna `split_usado` e uma flag
     `comparavel_entre_categorias = False`.
   - Nenhuma tabela de comparação pode mostrar R² de splits diferentes sem esse aviso.

2. **Baseline de persistência (ponto 2).**
   - Definir `baseline_persistencia`: `previsão(ano) = valor_real(ano-1)` = a feature `lag1`.
   - Calcular MAE/RMSE/R² do baseline para **cada** categoria, no mesmo split do modelo.
   - Toda métrica de modelo passa a ser reportada como **ganho relativo sobre o baseline**
     (ex.: "RF reduz RMSE em X% vs. persistência"). Se o modelo não bate o baseline por
     margem clara, isso é reportado como **achado**, não escondido.

3. **Validação cruzada temporal (ponto 3).**
   - Substituir o R² de número único por avaliação com `TimeSeriesSplit`
     (respeitando a ordem temporal), reportando **média ± desvio** de cada métrica.
   - Onde o número de anos for insuficiente para `TimeSeriesSplit` significativo,
     declarar isso explicitamente e reportar o split único com ressalva.

4. **Feminicídios marcado como "não modelável" (ponto 4).**
   - Critério objetivo: categorias cujo baseline/modelo não superam a previsão pela
     média (R² ≤ 0) ou com cobertura insuficiente são marcadas
     `status = "não modelável com os dados atuais"` e **removidas da comparação principal**.
   - Feminicídios entra aqui (evento raro, 27 capitais, R² ≈ 0).

5. **XGBoost — opcional, fora do caminho crítico (ponto 6).**
   - Implementado como **célula/seção opcional** cujo propósito é *demonstrar* que o
     ganho de um modelo de boosting é marginal — reforçando a tese de que o teto é do
     dataset, não do algoritmo.
   - Não é pré-requisito para nenhuma conclusão. Pode ser substituído por um comentário
     no README caso o usuário prefira não rodar.

### Eixo B — Exploração socioeconômica (sem prometer previsão)

Objetivo: investigar o sinal dos fatores socioeconômicos (IDHM, educação) sobre a
criminalidade, **sem** prometer poder preditivo. Conclusões são exploratórias e
honestas sobre força/fraqueza do sinal.

Componentes:

1. **Importância de variáveis honesta (ponto 5).**
   - Extrair e exibir a importância das variáveis do RF do Eixo A.
   - Se `lag1` dominar e IDHM/educação contribuírem pouco (esperado, dado IDHM 2010),
     isso **não é escondido** — é apresentado como o achado que motiva a separação dos
     dois eixos: "a previsão funciona por inércia; o sinal socioeconômico precisa ser
     investigado à parte".

2. **Análise socioeconômica isolada.**
   - Correlações entre IDHM/educação e as taxas criminais (e correlação parcial,
     controlando o que for viável), tratadas como **análise exploratória**.
   - Decisão pendente de confirmação do usuário (ver §6): incluir ou não um modelo
     **sem `lag1`** para isolar o sinal socioeconômico. Se incluído, é reportado como
     exploratório, com conclusão própria sobre o quão fraco/forte é o sinal — assumindo
     o risco de confirmar que é fraco (o que, ainda assim, é um resultado válido).

### Entregável final

- Notebook reorganizado nos dois eixos, com as seções de conclusão de cada eixo.
- **README e conclusões reescritas** refletindo a verdade: duas teses honestas
  (previsão por inércia que funciona; exploração socioeconômica com poder explicativo
  declarado) em vez de uma superafirmação ("RF é o melhor em tudo").

---

## 4. Fluxo de dados

Sem mudança na origem: a fonte oficial continua sendo
`datamart.vw_indicadores_municipio_ano` (carregada via SQLAlchemy no notebook).

```
datamart.vw_indicadores_municipio_ano
  -> preparação (ffill educação por UF, cálculo de taxas, criação de lag1)
  -> Eixo A: split padronizado -> baseline persistência -> modelos -> TimeSeriesSplit -> métricas com ganho relativo
  -> Eixo B: importância de variáveis (do Eixo A) + correlações + (opcional) modelo sem lag1
  -> conclusões por eixo
  -> README reescrito
```

As exportações para o schema `ml` (`ml.metricas_modelos`, `ml.previsoes_modelos`,
`ml.importancia_variaveis`, `ml.splits_modelagem`, `ml.melhores_modelos`) são
**mantidas**, mas o schema das métricas ganha colunas novas: `metrica_baseline`,
`ganho_relativo_vs_baseline`, `r2_medio_cv`, `r2_desvio_cv`, `split_usado`,
`comparavel_entre_categorias`, `status_categoria`.

---

## 5. Tratamento de erros e casos de borda

- **Categoria sem anos suficientes para TimeSeriesSplit:** declarar e cair para split
  único com ressalva explícita (não falhar silenciosamente).
- **Baseline melhor que o modelo:** reportar como achado, não suprimir.
- **R² ≤ 0:** aciona automaticamente `status = "não modelável"` e exclusão da
  comparação principal.
- **NULL em features:** continuar tratando como ausência de dado (já feito via dropna
  por modelo); documentar quantas linhas cada categoria efetivamente usa.

---

## 6. Verificação / como saber que deu certo

Critérios de aceite (o projeto está "elevado" quando):

1. Nenhuma tabela compara R² de splits diferentes sem aviso explícito.
2. Toda categoria modelável reporta ganho relativo vs. baseline de persistência.
3. R² reportado como média ± desvio (onde TimeSeriesSplit é viável).
4. Feminicídios (e qualquer R² ≤ 0) fora da comparação principal, com status claro.
5. Importância de variáveis exibida e interpretada honestamente.
6. README e conclusões reescritas refletem os dois eixos e as limitações da §2.
7. Conclusões do projeto não afirmam nada que os dados não sustentem.

---

## 7. Fora de escopo (YAGNI — explicitamente NÃO faremos agora)

- Deploy / API de previsões.
- Migração de notebook para `src/` + scripts de produção.
- dbt / orquestração / engenharia de pipeline.
- Buscar novas fontes de dados (renda, desemprego, séries mensais).
- Modelos temporais (ARIMA/Prophet).

Tudo isso pertence à fase "Completo (rigor + engenharia)", que **não** foi escolhida
para este ciclo.

---

## 8. Decisão do Eixo B (confirmada)

**Decisão:** o Eixo B usará um **modelo treinado SEM `lag1`** (apenas IDHM, educação,
população e derivados) **+ correlações parciais**.

Justificativa: a *importância de variáveis* do modelo completo (Eixo A) **não isola**
o sinal socioeconômico — como `lag1` é forte, ele captura quase toda a variância antes,
e IDHM/educação aparecem com importância baixa mesmo que tenham sinal real. Remover o
`lag1` responde à pergunta correta do Eixo B: "quando o histórico não está disponível,
quanto os fatores socioeconômicos explicam sozinhos?".

Reaproveita toda a infraestrutura existente (`treinar_e_avaliar`, split, baseline) —
muda apenas a lista de features (sem `lag1`). É reuso da engrenagem, não construção nova.
O resultado é comparado ao mesmo baseline de persistência e reportado como **exploratório**;
se o sinal for fraco, isso é um achado válido e será declarado honestamente.
