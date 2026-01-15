-- Retention policy functions for automated cleanup

-- Function to clean old health samples (7 days)
CREATE OR REPLACE FUNCTION cleanup_rpc_health_samples()
RETURNS void AS $$
BEGIN
    DELETE FROM rpc_health_samples
    WHERE sampled_at < EXTRACT(EPOCH FROM NOW())::BIGINT - 604800;
END;
$$ LANGUAGE plpgsql;

-- Function to clean old transactions (30 days success, 90 days failed)
CREATE OR REPLACE FUNCTION cleanup_txs()
RETURNS void AS $$
BEGIN
    -- Delete successful txs older than 30 days
    DELETE FROM txs
    WHERE status = 1 
    AND block_timestamp < EXTRACT(EPOCH FROM NOW())::BIGINT - 2592000;
    
    -- Delete failed txs older than 90 days
    DELETE FROM txs
    WHERE status = 0 
    AND block_timestamp < EXTRACT(EPOCH FROM NOW())::BIGINT - 7776000;
END;
$$ LANGUAGE plpgsql;

-- Function to clean old traces (14 days, max 10k)
CREATE OR REPLACE FUNCTION cleanup_tx_traces()
RETURNS void AS $$
BEGIN
    -- Delete traces older than 14 days
    DELETE FROM tx_traces
    WHERE created_at < EXTRACT(EPOCH FROM NOW())::BIGINT - 1209600;
    
    -- Keep only newest 10k traces if over limit
    DELETE FROM tx_traces
    WHERE id NOT IN (
        SELECT id FROM tx_traces
        ORDER BY created_at DESC
        LIMIT 10000
    );
END;
$$ LANGUAGE plpgsql;

-- Function to clean old metrics (30 days)
CREATE OR REPLACE FUNCTION cleanup_metrics_minute()
RETURNS void AS $$
BEGIN
    DELETE FROM metrics_minute
    WHERE bucket_ts < EXTRACT(EPOCH FROM NOW())::BIGINT - 2592000;
END;
$$ LANGUAGE plpgsql;

-- Function to clean old alert events (90 days)
CREATE OR REPLACE FUNCTION cleanup_alert_events()
RETURNS void AS $$
BEGIN
    DELETE FROM alert_events
    WHERE triggered_at < EXTRACT(EPOCH FROM NOW())::BIGINT - 7776000;
END;
$$ LANGUAGE plpgsql;

-- Add comments
COMMENT ON FUNCTION cleanup_rpc_health_samples IS 'Remove health samples older than 7 days';
COMMENT ON FUNCTION cleanup_txs IS 'Remove success txs > 30d, failed txs > 90d';
COMMENT ON FUNCTION cleanup_tx_traces IS 'Remove traces > 14d and keep max 10k';
COMMENT ON FUNCTION cleanup_metrics_minute IS 'Remove metrics older than 30 days';
COMMENT ON FUNCTION cleanup_alert_events IS 'Remove alert events older than 90 days';
