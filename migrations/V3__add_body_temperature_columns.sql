-- ADF-3: Add body_temperature support to health_metrics hypertable
-- Migration: V3__add_body_temperature_columns.sql
-- Additive only — no existing rows affected.
-- Both columns are nullable; PostgreSQL 15 performs a metadata-only DDL change.
-- Safe to re-run (IF NOT EXISTS guards on both ADD COLUMN and CREATE INDEX).

ALTER TABLE health_metrics
  ADD COLUMN IF NOT EXISTS value_celsius       DOUBLE PRECISION NULL,
  ADD COLUMN IF NOT EXISTS measurement_method  VARCHAR(64)      NULL;

-- Partial index: covers device-filtered temperature chart queries (FR-011).
-- Empty at creation (no body_temperature rows yet); builds in microseconds.
CREATE INDEX IF NOT EXISTS idx_health_metrics_user_device_time
  ON health_metrics (user_id, device_source, recorded_at DESC)
  WHERE metric_type = 'body_temperature';
