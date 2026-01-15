-- Create rpc_endpoints table
CREATE TABLE rpc_endpoints (
    id SERIAL PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,
    url VARCHAR(256) NOT NULL UNIQUE,
    chain_id INTEGER NOT NULL DEFAULT 5000,
    score SMALLINT NOT NULL DEFAULT 100 CHECK (score >= 0 AND score <= 100),
    status VARCHAR(16) NOT NULL DEFAULT 'healthy' CHECK (status IN ('healthy', 'degraded', 'unhealthy')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    supports_traces BOOLEAN NOT NULL DEFAULT false,
    last_probe_at BIGINT,
    created_at BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT,
    updated_at BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT
);

-- Create indexes
CREATE INDEX idx_rpc_endpoints_status_score 
    ON rpc_endpoints (status, score DESC) 
    WHERE is_active = true;

CREATE INDEX idx_rpc_endpoints_chain_id 
    ON rpc_endpoints (chain_id);

-- Add comment
COMMENT ON TABLE rpc_endpoints IS 'Registry of configured RPC providers with current health scores';
