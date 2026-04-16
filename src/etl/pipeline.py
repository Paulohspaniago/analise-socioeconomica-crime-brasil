from __future__ import annotations

from collections.abc import Iterable
from typing import Any

import pandas as pd

from .config import PipelineConfig


def standardize_keys(
    df: pd.DataFrame,
    *,
    dataset_name: str,
    state_column: str = "state_code",
    year_column: str = "year",
    rename_map: dict[str, str] | None = None,
    config: PipelineConfig | None = None,
) -> pd.DataFrame:
    """Rename and normalize the canonical merge keys used across all sources."""

    config = config or PipelineConfig()
    result = df.copy()

    if rename_map:
        result = result.rename(columns=rename_map)

    if state_column not in result.columns or year_column not in result.columns:
        raise KeyError(f"{dataset_name} must contain `{state_column}` and `{year_column}` after renaming.")

    result[state_column] = result[state_column].astype(str).str.strip().str.upper()
    result[year_column] = pd.to_numeric(result[year_column], errors="raise").astype(int)
    result = result[result[state_column].isin(config.valid_state_codes)].copy()
    result = result.dropna(subset=[state_column, year_column])

    return result


def build_backbone(
    state_dimension: pd.DataFrame,
    years: Iterable[int],
    *,
    state_column: str = "state_code",
    state_name_column: str = "state_name",
    region_column: str = "region",
) -> pd.DataFrame:
    """Build the complete state-year panel used as the merge backbone."""

    years_frame = pd.DataFrame({"year": sorted(set(int(year) for year in years))})
    states_frame = state_dimension[[state_column, state_name_column, region_column]].drop_duplicates()
    backbone = states_frame.merge(years_frame, how="cross")

    return backbone.sort_values([state_column, "year"]).reset_index(drop=True)


def merge_sources(
    backbone: pd.DataFrame,
    sources: Iterable[pd.DataFrame],
    *,
    on: tuple[str, str] = ("state_code", "year"),
) -> pd.DataFrame:
    """Left-join standardized sources onto the base state-year panel."""

    result = backbone.copy()
    for source in sources:
        merge_columns = [column for column in source.columns if column not in result.columns or column in on]
        result = result.merge(source[merge_columns], how="left", on=list(on), validate="one_to_one")

    return result


def add_rate_per_100k(
    df: pd.DataFrame,
    *,
    numerator_column: str,
    population_column: str = "population",
    output_column: str,
) -> pd.DataFrame:
    """Create rate-per-100k indicators from absolute counts."""

    result = df.copy()
    result[output_column] = (result[numerator_column] / result[population_column]) * 100000
    return result


def add_population_growth(
    df: pd.DataFrame,
    *,
    group_column: str = "state_code",
    population_column: str = "population",
    year_column: str = "year",
    output_column: str = "population_growth_pct",
) -> pd.DataFrame:
    """Create year-over-year population growth percentages by state."""

    result = df.sort_values([group_column, year_column]).copy()
    result[output_column] = result.groupby(group_column)[population_column].pct_change() * 100
    return result


def add_group_lag(
    df: pd.DataFrame,
    *,
    value_column: str,
    group_column: str = "state_code",
    year_column: str = "year",
    lag_periods: int = 1,
    output_column: str | None = None,
) -> pd.DataFrame:
    """Create lagged features for time-aware modeling baselines."""

    result = df.sort_values([group_column, year_column]).copy()
    target_column = output_column or f"lag_{lag_periods}_{value_column}"
    result[target_column] = result.groupby(group_column)[value_column].shift(lag_periods)
    return result


def validate_panel(
    df: pd.DataFrame,
    *,
    required_columns: Iterable[str] | None = None,
    key_columns: tuple[str, str] = ("state_code", "year"),
) -> dict[str, Any]:
    """Run lightweight validation checks before persistence or modeling."""

    required_columns = list(required_columns or [])
    duplicate_keys = int(df.duplicated(subset=list(key_columns)).sum())
    missing_required = {
        column: int(df[column].isna().sum())
        for column in required_columns
        if column in df.columns
    }

    summary = {
        "row_count": int(len(df)),
        "duplicate_keys": duplicate_keys,
        "missing_required": missing_required,
    }

    if duplicate_keys:
        raise ValueError(f"Duplicate {key_columns} keys found: {duplicate_keys}")

    return summary


def build_fact_state_year(
    *,
    state_dimension: pd.DataFrame,
    crime_df: pd.DataFrame,
    population_df: pd.DataFrame,
    hdi_df: pd.DataFrame,
    education_df: pd.DataFrame,
) -> pd.DataFrame:
    """Build the first analytical panel for modeling and BI."""

    all_years = set(population_df["year"]).union(crime_df["year"], hdi_df["year"], education_df["year"])
    backbone = build_backbone(state_dimension, all_years)
    panel = merge_sources(backbone, [population_df, crime_df, hdi_df, education_df])

    if "crime_total" in panel.columns:
        panel = add_rate_per_100k(
            panel,
            numerator_column="crime_total",
            output_column="crime_rate_100k",
        )

    if "crime_violent_total" in panel.columns:
        panel = add_rate_per_100k(
            panel,
            numerator_column="crime_violent_total",
            output_column="violent_crime_rate_100k",
        )

    if "crime_homicide_total" in panel.columns:
        panel = add_rate_per_100k(
            panel,
            numerator_column="crime_homicide_total",
            output_column="homicide_rate_100k",
        )

    if "population" in panel.columns:
        panel = add_population_growth(panel)

    if "crime_rate_100k" in panel.columns:
        panel = add_group_lag(panel, value_column="crime_rate_100k")

    if "violent_crime_rate_100k" in panel.columns:
        panel = add_group_lag(panel, value_column="violent_crime_rate_100k")

    panel["_id"] = panel["state_code"] + "_" + panel["year"].astype(str)
    return panel
