-- Create alert_events table
CREATE TABLE alert_events (
    id BIGSERIAL PRIMARY KEY,
    alert_id INTEGER NOT NULL REFERENCES alerts(id) ON DELETE CASCADE,
    triggered_at BIGINT NOT NULL,
    severity VARCHAR(16) NOT NULL CHECK (severity IN ('info', 'warning', 'critical')),
    value_observed NUMERIC(18,6) NOT NULL,
    threshold NUMERIC(18,6) NOT NULL,
    context JSONB,
    acknowledged_at BIGINT,
    acknowledged_by VARCHAR(64)
);

-- Create indexes
CREATE INDEX idx_alert_events_alert_time 
    ON alert_events (alert_id, triggered_at DESC);

CREATE INDEX idx_alert_events_time 
    ON alert_events (triggered_at DESC);

CREATE INDEX idx_alert_events_unacked 
    ON alert_events (triggered_at DESC) 
    WHERE acknowledged_at IS NULL;

-- Add comment
COMMENT ON TABLE alert_events IS 'Historical record of triggered alerts (90 day retention)';
