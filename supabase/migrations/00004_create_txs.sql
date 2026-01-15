-- Create txs table
CREATE TABLE txs (
    id BIGSERIAL PRIMARY KEY,
    hash CHAR(66) NOT NULL UNIQUE,
    block_number BIGINT NOT NULL,
    block_timestamp BIGINT NOT NULL,
    from_address CHAR(42) NOT NULL,
    to_address CHAR(42),
    contract_id INTEGER REFERENCES contracts(id) ON DELETE SET NULL,
    value_wei NUMERIC(78,0) NOT NULL DEFAULT 0,
    gas_used BIGINT NOT NULL,
    gas_price BIGINT NOT NULL,
    status SMALLINT NOT NULL CHECK (status IN (0, 1)),
    error_raw TEXT,
    error_signature VARCHAR(10),
    error_decoded VARCHAR(256),
    error_params JSONB,
    method_id VARCHAR(10),
    method_name VARCHAR(128),
    has_trace BOOLEAN NOT NULL DEFAULT false,
    is_tentative BOOLEAN NOT NULL DEFAULT false,
    ingested_at BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT
);

-- Create indexes
CREATE INDEX idx_txs_hash 
    ON txs (hash);

CREATE INDEX idx_txs_block 
    ON txs (block_number DESC, status);

CREATE INDEX idx_txs_contract_status 
    ON txs (contract_id, status, block_timestamp DESC);

CREATE INDEX idx_txs_from 
    ON txs (from_address, block_timestamp DESC);

CREATE INDEX idx_txs_to 
    ON txs (to_address, block_timestamp DESC) 
    WHERE to_address IS NOT NULL;

CREATE INDEX idx_txs_status_time 
    ON txs (status, block_timestamp DESC);

CREATE INDEX idx_txs_error_sig 
    ON txs (error_signature) 
    WHERE status = 0;

-- Add comment
COMMENT ON TABLE txs IS 'Transaction records with focus on failed transactions (30d success, 90d failed retention)';
