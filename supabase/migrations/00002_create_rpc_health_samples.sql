-- Create rpc_health_samples table
CREATE TABLE rpc_health_samples (
    id BIGSERIAL PRIMARY KEY,
    endpoint_id INTEGER NOT NULL REFERENCES rpc_endpoints(id) ON DELETE CASCADE,
    sampled_at BIGINT NOT NULL,
    latency_ms INTEGER,
    block_number BIGINT,
    is_success BOOLEAN NOT NULL,
    error_code VARCHAR(32)
);

-- Create indexes
CREATE INDEX idx_health_samples_endpoint_time 
    ON rpc_health_samples (endpoint_id, sampled_at DESC);

CREATE INDEX idx_health_samples_time 
    ON rpc_health_samples (sampled_at DESC);

-- Add comment
COMMENT ON TABLE rpc_health_samples IS 'Time-series health samples for provider comparison charts (7 day retention)';
