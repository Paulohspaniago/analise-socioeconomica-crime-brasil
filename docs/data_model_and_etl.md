# Data Model and ETL Design

## 1. Analytical Grain

The canonical grain for this project should be:

`1 document = 1 state (UF) + 1 year`

Why this is the right choice:

- All current sources can be aligned at `state + year`.
- It is simple enough for the first model and dashboard.
- It keeps feature engineering reproducible.
- It is easy to extend later to `state + month` or `municipality + year`.

For machine learning and Metabase, the curated dataset should be mostly flat.
MongoDB supports nested documents, but denormalized top-level fields make BI usage much easier.

## 2. Recommended MongoDB Collections

### `dim_state`

Reference collection with one document per Brazilian state.

Suggested fields:

```json
{
  "_id": "SP",
  "state_code": "SP",
  "state_name": "Sao Paulo",
  "region": "Sudeste",
  "ibge_state_code": 35,
  "is_active": true,
  "created_at": "2026-04-16T00:00:00Z",
  "updated_at": "2026-04-16T00:00:00Z"
}
```

Use this for reference and validation, but duplicate `state_name` and `region` inside the fact collection to avoid joins in dashboards.

### `fact_state_year`

Main analytical collection. This is the core dataset for notebooks, model training, and Metabase.

Suggested shape:

```json
{
  "_id": "SP_2020",
  "state_code": "SP",
  "state_name": "Sao Paulo",
  "region": "Sudeste",
  "year": 2020,

  "population": 46289333,
  "population_growth_pct": 0.74,

  "hdi": 0.826,

  "education_enrollment_rate": 94.1,
  "education_approval_rate": 91.7,
  "education_dropout_rate": 2.8,
  "education_ideb": 4.7,

  "crime_total": 315420,
  "crime_violent_total": 84510,
  "crime_homicide_total": 6234,

  "crime_rate_100k": 681.4,
  "violent_crime_rate_100k": 182.6,
  "homicide_rate_100k": 13.5,

  "lag_1_crime_rate_100k": 695.8,
  "lag_1_violent_crime_rate_100k": 190.1,

  "source_crime": "sinesp_2020_v1",
  "source_hdi": "atlas_brasil_2020_v1",
  "source_population": "ibge_2020_v1",
  "source_education": "inep_2020_v1",

  "missing_fields": [],
  "quality_status": "valid",
  "created_at": "2026-04-16T00:00:00Z",
  "updated_at": "2026-04-16T00:00:00Z"
}
```

Minimum first version fields:

- `state_code`
- `state_name`
- `region`
- `year`
- `population`
- `population_growth_pct`
- `hdi`
- `crime_total`
- `crime_rate_100k`
- 2 to 4 education indicators

That is enough for a strong first baseline.

### `etl_runs`

Operational collection for reproducibility.

Suggested fields:

```json
{
  "_id": "etl_2026_04_16_120000",
  "pipeline_version": "v1",
  "run_started_at": "2026-04-16T12:00:00Z",
  "run_finished_at": "2026-04-16T12:04:00Z",
  "status": "success",
  "input_files": [
    "data/raw/crime/crime_2014_2024.csv",
    "data/raw/population/population.csv"
  ],
  "row_counts": {
    "crime_standardized": 297,
    "population_standardized": 297,
    "fact_state_year": 297
  },
  "validation_summary": {
    "duplicate_keys": 0,
    "missing_population": 0,
    "missing_hdi": 3
  }
}
```

This is important for a group project because it gives traceability without adding much complexity.

### `model_runs`

Experiment metadata for the first regression model.

Suggested fields:

```json
{
  "_id": "linreg_2026_04_16_130000",
  "model_name": "linear_regression_baseline",
  "target": "crime_rate_100k",
  "feature_columns": [
    "population_growth_pct",
    "hdi",
    "education_enrollment_rate",
    "lag_1_crime_rate_100k"
  ],
  "train_period": {
    "start_year": 2014,
    "end_year": 2021
  },
  "test_period": {
    "start_year": 2022,
    "end_year": 2023
  },
  "metrics": {
    "mae": 12.4,
    "rmse": 18.1,
    "r2": 0.61
  },
  "artifact_path": "artifacts/models/linear_regression_baseline.joblib",
  "created_at": "2026-04-16T13:00:00Z"
}
```

## 3. Index Strategy

Recommended indexes:

### `dim_state`

- Unique index on `state_code`

### `fact_state_year`

- Unique compound index on `{ state_code: 1, year: 1 }`
- Index on `{ year: 1 }`
- Index on `{ region: 1, year: 1 }`

### `etl_runs`

- Index on `{ run_started_at: -1 }`

### `model_runs`

- Index on `{ created_at: -1 }`
- Index on `{ model_name: 1 }`

## 4. Canonical Data Contract

Every standardized dataframe should expose the same key fields before merge:

- `state_code`
- `year`

Then each source adds only its own metric columns.

Example:

- Crime standardized dataset:
  - `state_code`, `year`, `crime_total`, `crime_violent_total`, `crime_homicide_total`
- Population standardized dataset:
  - `state_code`, `year`, `population`
- HDI standardized dataset:
  - `state_code`, `year`, `hdi`
- Education standardized dataset:
  - `state_code`, `year`, `education_enrollment_rate`, `education_approval_rate`, `education_dropout_rate`, `education_ideb`

This contract is the key to keeping notebook work modular.

## 5. ETL Pipeline Proposal

Recommended flow:

```text
Extract raw files
-> Standardize each source
-> Validate keys and duplicates
-> Build state-year backbone
-> Join standardized sources
-> Engineer features
-> Validate analytical panel
-> Save parquet/csv locally
-> Publish to MongoDB
-> Log ETL run
```

### Step 1. Extract

Read raw files from versioned folders:

- `data/raw/crime/`
- `data/raw/hdi/`
- `data/raw/population/`
- `data/raw/education/`

Keep raw files unchanged.
All transformations should happen in notebooks or `src/etl`.

### Step 2. Standardize

For each source:

- rename columns to canonical names
- normalize `state_code`
- convert `year` to integer
- remove totals and invalid rows
- aggregate to state-year if the source is more granular

Output of each source should be saved to `data/processed/intermediate/`.

### Step 3. Validate

Before merging:

- no duplicate `state_code + year`
- `year` within expected range
- `state_code` in the 27 valid UFs
- metric columns numeric

If validation fails, stop and fix the source-specific transform.

### Step 4. Build Backbone

Create a base panel with:

- all 27 states
- all years available in the common analytical window

This avoids silent row loss during joins.

### Step 5. Join Sources

Merge standardized sources onto the backbone with `left` joins on:

- `state_code`
- `year`

Recommended order:

1. backbone
2. population
3. crime
4. hdi
5. education

Population and crime should come earlier because they drive the main target and normalization.

### Step 6. Feature Engineering

First features to implement:

- `crime_rate_100k = crime_total / population * 100000`
- `violent_crime_rate_100k = crime_violent_total / population * 100000`
- `homicide_rate_100k = crime_homicide_total / population * 100000`
- `population_growth_pct = population.pct_change() * 100` by state
- `lag_1_crime_rate_100k`
- `lag_1_violent_crime_rate_100k`

Good first modeling target:

- `crime_rate_100k`

Good optional second target:

- `violent_crime_rate_100k`

### Step 7. Publish

Persist two outputs:

- local analytical file in `data/processed/fact_state_year.parquet`
- MongoDB collection `fact_state_year`

This dual persistence is a good engineering choice:

- parquet is fast for notebook work and debugging
- MongoDB feeds dashboards and application layers

### Step 8. Log the Run

Write a run summary into `etl_runs`.

This prevents "which notebook version created this data?" problems later.

## 6. Jupyter Notebook Workflow

Recommended notebook sequence:

1. `notebooks/01_source_profiling.ipynb`
2. `notebooks/02_standardize_crime.ipynb`
3. `notebooks/03_standardize_socioeconomic.ipynb`
4. `notebooks/04_build_panel.ipynb`
5. `notebooks/05_model_baseline.ipynb`
6. `notebooks/06_publish_mongodb.ipynb`

Notebook rule:

- notebooks orchestrate
- reusable logic lives in `src/etl`

That gives the team fast iteration now and a cleaner migration path later.

## 7. Team Working Agreement

To keep collaboration simple:

- One owner per source standardization notebook
- Shared canonical column contract
- Shared validation rules in code
- Shared `fact_state_year` schema as the only modeling input

Recommended role split:

- Data engineering: standardization, validation, Mongo publishing
- Data science: feature engineering, regression baseline, evaluation
- BI: Metabase questions, dashboards, KPI definitions
- Documentation: data dictionary, assumptions, limitations

## 8. Practical Decision Summary

Key decisions:

- Use `state + year` as the canonical analytical grain.
- Keep raw data on disk, not in MongoDB.
- Store one denormalized fact collection for dashboards and model input.
- Track ETL and model runs for reproducibility.
- Keep notebook orchestration thin and reusable logic in `src/etl`.

This is the simplest design that is still strong enough for a group project and easy to scale later.
