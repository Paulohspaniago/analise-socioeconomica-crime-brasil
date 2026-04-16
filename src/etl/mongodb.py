from __future__ import annotations

from datetime import datetime, timezone

import pandas as pd
from pymongo import ASCENDING, DESCENDING, MongoClient, ReplaceOne

from .config import PipelineConfig


class MongoPublisher:
    """Publish curated dataframes and ETL metadata to MongoDB."""

    def __init__(self, mongo_uri: str, config: PipelineConfig | None = None) -> None:
        self.config = config or PipelineConfig()
        self.client = MongoClient(mongo_uri)
        self.db = self.client[self.config.mongo_db_name]

    def ensure_indexes(self) -> None:
        self.db[self.config.dim_state_collection].create_index(
            [("state_code", ASCENDING)],
            unique=True,
        )
        self.db[self.config.fact_collection].create_index(
            [("state_code", ASCENDING), ("year", ASCENDING)],
            unique=True,
        )
        self.db[self.config.fact_collection].create_index([("year", ASCENDING)])
        self.db[self.config.fact_collection].create_index([("region", ASCENDING), ("year", ASCENDING)])
        self.db[self.config.etl_runs_collection].create_index([("run_started_at", DESCENDING)])
        self.db[self.config.model_runs_collection].create_index([("created_at", DESCENDING)])
        self.db[self.config.model_runs_collection].create_index([("model_name", ASCENDING)])

    def upsert_dataframe(
        self,
        df: pd.DataFrame,
        *,
        collection_name: str,
        key_fields: tuple[str, ...],
    ) -> int:
        records = df.where(pd.notnull(df), None).to_dict(orient="records")
        operations = []

        for record in records:
            filter_query = {field: record[field] for field in key_fields}
            operations.append(ReplaceOne(filter_query, record, upsert=True))

        if not operations:
            return 0

        result = self.db[collection_name].bulk_write(operations, ordered=False)
        return result.upserted_count + result.modified_count

    def log_etl_run(
        self,
        *,
        run_id: str,
        status: str,
        input_files: list[str],
        row_counts: dict[str, int],
        validation_summary: dict[str, object],
        pipeline_version: str = "v1",
    ) -> None:
        now = datetime.now(timezone.utc)
        payload = {
            "_id": run_id,
            "pipeline_version": pipeline_version,
            "run_started_at": now,
            "run_finished_at": now,
            "status": status,
            "input_files": input_files,
            "row_counts": row_counts,
            "validation_summary": validation_summary,
        }
        self.db[self.config.etl_runs_collection].replace_one({"_id": run_id}, payload, upsert=True)
