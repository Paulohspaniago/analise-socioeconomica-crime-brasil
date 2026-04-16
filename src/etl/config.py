from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path


@dataclass(slots=True)
class PipelineConfig:
    """Project-level ETL configuration shared by notebooks and scripts."""

    project_root: Path = field(default_factory=lambda: Path(__file__).resolve().parents[2])
    raw_dir: Path = field(init=False)
    processed_dir: Path = field(init=False)
    intermediate_dir: Path = field(init=False)
    curated_file: Path = field(init=False)
    mongo_db_name: str = "crime_brazil"
    dim_state_collection: str = "dim_state"
    fact_collection: str = "fact_state_year"
    etl_runs_collection: str = "etl_runs"
    model_runs_collection: str = "model_runs"
    valid_state_codes: tuple[str, ...] = (
        "AC",
        "AL",
        "AP",
        "AM",
        "BA",
        "CE",
        "DF",
        "ES",
        "GO",
        "MA",
        "MT",
        "MS",
        "MG",
        "PA",
        "PB",
        "PR",
        "PE",
        "PI",
        "RJ",
        "RN",
        "RS",
        "RO",
        "RR",
        "SC",
        "SP",
        "SE",
        "TO",
    )

    def __post_init__(self) -> None:
        self.raw_dir = self.project_root / "data" / "raw"
        self.processed_dir = self.project_root / "data" / "processed"
        self.intermediate_dir = self.processed_dir / "intermediate"
        self.curated_file = self.processed_dir / "fact_state_year.parquet"

