-- Create metrics_minute table
CREATE TABLE metrics_minute (
    id BIGSERIAL PRIMARY KEY,
    bucket_ts BIGINT NOT NULL UNIQUE,
    tx_count INTEGER NOT NULL DEFAULT 0,
    tx_failed_count INTEGER NOT NULL DEFAULT 0,
    gas_used_total NUMERIC(38,0) NOT NULL DEFAULT 0,
    gas_price_avg BIGINT NOT NULL DEFAULT 0,
    block_count SMALLINT NOT NULL DEFAULT 0,
    unique_senders INTEGER NOT NULL DEFAULT 0,
    top_errors JSONB DEFAULT '[]'
);

-- Create indexes
CREATE UNIQUE INDEX idx_metrics_bucket 
    ON metrics_minute (bucket_ts);

CREATE INDEX idx_metrics_time 
    ON metrics_minute (bucket_ts DESC);

-- Add comment
COMMENT ON TABLE metrics_minute IS 'Pre-aggregated per-minute metrics for dashboard charts (30 day retention)';
