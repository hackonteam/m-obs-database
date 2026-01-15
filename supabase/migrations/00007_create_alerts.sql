-- Create alerts table
CREATE TABLE alerts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    alert_type VARCHAR(32) NOT NULL CHECK (alert_type IN ('failure_rate', 'gas_spike', 'provider_down', 'custom')),
    conditions JSONB NOT NULL,
    threshold NUMERIC(18,6) NOT NULL,
    window_minutes SMALLINT NOT NULL DEFAULT 5,
    cooldown_minutes SMALLINT NOT NULL DEFAULT 15,
    severity VARCHAR(16) NOT NULL DEFAULT 'warning' CHECK (severity IN ('info', 'warning', 'critical')),
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    contract_ids INTEGER[] DEFAULT '{}',
    last_triggered_at BIGINT,
    created_at BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT,
    updated_at BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT
);

-- Create indexes
CREATE INDEX idx_alerts_enabled 
    ON alerts (is_enabled, alert_type) 
    WHERE is_enabled = true;

CREATE INDEX idx_alerts_contracts 
    ON alerts USING GIN (contract_ids);

-- Add comment
COMMENT ON TABLE alerts IS 'User-defined alert rules';
