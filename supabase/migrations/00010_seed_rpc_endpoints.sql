-- Seed RPC endpoints for Mantle Mainnet
INSERT INTO rpc_endpoints (name, url, chain_id, score, status, is_active, supports_traces, created_at, updated_at) VALUES
    ('mantle-official', 'https://rpc.mantle.xyz', 5000, 100, 'healthy', true, false, EXTRACT(EPOCH FROM NOW())::BIGINT, EXTRACT(EPOCH FROM NOW())::BIGINT),
    ('mantle-ankr', 'https://rpc.ankr.com/mantle', 5000, 100, 'healthy', true, false, EXTRACT(EPOCH FROM NOW())::BIGINT, EXTRACT(EPOCH FROM NOW())::BIGINT),
    ('mantle-publicnode', 'https://mantle-rpc.publicnode.com', 5000, 100, 'healthy', true, false, EXTRACT(EPOCH FROM NOW())::BIGINT, EXTRACT(EPOCH FROM NOW())::BIGINT);
