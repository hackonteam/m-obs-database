-- Create worker_state table
CREATE TABLE worker_state (
    id SERIAL PRIMARY KEY,
    key VARCHAR(64) NOT NULL UNIQUE,
    value JSONB NOT NULL,
    updated_at BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT
);

-- Create indexes
CREATE UNIQUE INDEX idx_worker_state_key 
    ON worker_state (key);

-- Add comment
COMMENT ON TABLE worker_state IS 'Worker coordination, checkpoints, and health tracking';

-- Insert initial state keys
INSERT INTO worker_state (key, value, updated_at) VALUES
    ('last_scanned_block', '{"block_number": 0, "block_hash": "0x0"}', EXTRACT(EPOCH FROM NOW())::BIGINT),
    ('provider_scores', '{}', EXTRACT(EPOCH FROM NOW())::BIGINT),
    ('heartbeat', '{"worker_id": null, "started_at": null, "last_beat": null}', EXTRACT(EPOCH FROM NOW())::BIGINT),
    ('metrics_rollup_cursor', '{"last_bucket_ts": 0}', EXTRACT(EPOCH FROM NOW())::BIGINT),
    ('alert_eval_cursor', '{"last_eval_ts": 0}', EXTRACT(EPOCH FROM NOW())::BIGINT),
    ('trace_queue_depth', '{"depth": 0}', EXTRACT(EPOCH FROM NOW())::BIGINT);
