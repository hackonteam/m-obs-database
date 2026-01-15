-- Create contracts table
CREATE TABLE contracts (
    id SERIAL PRIMARY KEY,
    address CHAR(42) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    tags VARCHAR(32)[] DEFAULT '{}',
    abi_json JSONB,
    is_watched BOOLEAN NOT NULL DEFAULT true,
    created_at BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT,
    updated_at BIGINT NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())::BIGINT
);

-- Create indexes
CREATE INDEX idx_contracts_address 
    ON contracts (lower(address));

CREATE INDEX idx_contracts_watched 
    ON contracts (is_watched) 
    WHERE is_watched = true;

CREATE INDEX idx_contracts_tags 
    ON contracts USING GIN (tags);

-- Add comment
COMMENT ON TABLE contracts IS 'Watchlist of contracts for filtering and ABI-based decoding';
