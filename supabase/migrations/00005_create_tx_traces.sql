-- Create tx_traces table
CREATE TABLE tx_traces (
    id BIGSERIAL PRIMARY KEY,
    tx_id BIGINT NOT NULL REFERENCES txs(id) ON DELETE CASCADE,
    trace_type VARCHAR(16) NOT NULL CHECK (trace_type IN ('callTracer', 'prestateTracer')),
    trace_json JSONB NOT NULL,
    depth_max SMALLINT,
    call_count INTEGER,
    created_at BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT,
    UNIQUE (tx_id, trace_type)
);

-- Create indexes
CREATE UNIQUE INDEX idx_traces_tx_id 
    ON tx_traces (tx_id, trace_type);

-- Add comment
COMMENT ON TABLE tx_traces IS 'Optional execution traces for failed transactions (14 day retention, max 10k traces)';
