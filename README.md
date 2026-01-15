# M-OBS Database

Database schema and migrations for M-OBS (Mantle Observability Stack).

## Repository

**GitHub:** https://github.com/hackonteam/m-obs-database  
**Main Project:** https://github.com/hackonteam/m-obs

## Overview

This repository contains all database migrations and schema definitions for the M-OBS project. The database is deployed on Supabase PostgreSQL and provides storage for:

- RPC endpoint registry and health monitoring
- Transaction records and traces
- Real-time metrics aggregation
- Alert rules and events
- Contract watchlist

## Database Structure

### Tables (9 total)

1. **`rpc_endpoints`** - RPC provider registry
   - Provider URLs and metadata
   - Health scores and status
   - Trace API support detection

2. **`rpc_health_samples`** - Time-series health data
   - Latency measurements
   - Availability tracking
   - Historical performance data

3. **`contracts`** - Contract watchlist
   - Tracked contract addresses
   - ABI definitions
   - Metadata and labels

4. **`txs`** - Transaction records
   - Focus on failed transactions
   - Error signatures and decoded messages
   - Gas usage and status

5. **`tx_traces`** - Execution traces
   - Optional detailed execution data
   - Call stack information
   - Bounded retention (7 days)

6. **`metrics_minute`** - Pre-aggregated metrics
   - Per-minute rollup data
   - Transaction counts and failure rates
   - Gas price statistics
   - Top errors tracking

7. **`alerts`** - Alert rule definitions
   - User-defined alert rules
   - Threshold configurations
   - Alert types: failure_rate, gas_spike, provider_down

8. **`alert_events`** - Alert trigger history
   - Alert event records
   - Cooldown enforcement
   - Historical alert data

9. **`worker_state`** - Worker coordination
   - Last processed block tracking
   - Worker heartbeats
   - State checkpoints for recovery

## Migrations

The migrations are located in `supabase/migrations/` and numbered sequentially:

```
supabase/migrations/
├── 00001_create_rpc_endpoints.sql
├── 00002_create_rpc_health_samples.sql
├── 00003_create_contracts.sql
├── 00004_create_txs.sql
├── 00005_create_tx_traces.sql
├── 00006_create_metrics_minute.sql
├── 00007_create_alerts.sql
├── 00008_create_alert_events.sql
├── 00009_create_worker_state.sql
├── 00010_seed_rpc_endpoints.sql
└── 00011_create_retention_policies.sql
```

### Migration Details

**00001 - RPC Endpoints**
- Creates `rpc_endpoints` table
- Indexes on `is_active` and `health_score`

**00002 - RPC Health Samples**
- Creates `rpc_health_samples` table
- Index on `(endpoint_id, sampled_at)` for time-series queries
- Foreign key to `rpc_endpoints`

**00003 - Contracts**
- Creates `contracts` table
- Unique constraint on `address`
- Index for active contract queries

**00004 - Transactions**
- Creates `txs` table
- Indexes optimized for filtering:
  - Status queries
  - Time range queries
  - Contract and address lookups
  - Error signature searches

**00005 - Transaction Traces**
- Creates `tx_traces` table
- Bounded retention (7 days default)
- Optional detailed execution data

**00006 - Metrics (Minute)**
- Creates `metrics_minute` table
- Unique constraint on `(bucket_start)`
- Index for time-series queries
- Stores pre-aggregated metrics

**00007 - Alerts**
- Creates `alerts` table
- Alert rule definitions
- Threshold configurations

**00008 - Alert Events**
- Creates `alert_events` table
- Index on `(alert_id, triggered_at)`
- Historical alert tracking

**00009 - Worker State**
- Creates `worker_state` table
- Worker coordination and checkpoints
- Unique constraint on `worker_name`

**00010 - Seed Data**
- Seeds initial RPC endpoints for Mantle mainnet:
  - https://rpc.mantle.xyz
  - https://rpc.ankr.com/mantle
  - https://mantle-rpc.publicnode.com

**00011 - Retention Policies**
- Creates cleanup functions:
  - `cleanup_old_health_samples()` - Removes samples older than 30 days
  - `cleanup_old_metrics()` - Removes metrics older than 90 days
  - `cleanup_old_tx_traces()` - Removes traces older than 7 days
  - `cleanup_old_alert_events()` - Removes events older than 30 days

## Deployment

### Prerequisites

- Supabase account (https://supabase.com)
- Supabase CLI installed: `npm install -g supabase`

### Setup

1. **Create Supabase Project**
   ```bash
   # Create project at https://supabase.com
   # Note your project reference ID
   ```

2. **Link to Project**
   ```bash
   cd supabase
   supabase link --project-ref <your-project-ref>
   ```

3. **Apply Migrations**
   ```bash
   supabase db push
   ```

4. **Verify Setup**
   ```bash
   # Check tables created
   supabase db list
   ```

### Configuration

After deployment, configure your backend services with the connection details:

```bash
# Get from Supabase dashboard > Settings > Database
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres
```

Or use Supabase client libraries:

```bash
SUPABASE_URL=https://[YOUR-PROJECT-REF].supabase.co
SUPABASE_KEY=[YOUR-SERVICE-ROLE-KEY]
```

## Database Features

### Indexes

All tables have optimized indexes for:
- Time-series queries (using `sampled_at`, `created_at`, `bucket_start`)
- Foreign key lookups
- Status and type filtering
- Full-text search readiness

### Constraints

- Foreign keys with CASCADE delete for related data
- Unique constraints for deduplication
- Check constraints for data validation
- NOT NULL constraints for required fields

### Retention Policies

Automated cleanup functions remove old data:
- **Health samples:** 30 days
- **Metrics:** 90 days
- **Transaction traces:** 7 days
- **Alert events:** 30 days

Schedule these functions to run periodically:
```sql
-- Example: Run daily via cron job or Supabase Edge Functions
SELECT cleanup_old_health_samples();
SELECT cleanup_old_metrics();
SELECT cleanup_old_tx_traces();
SELECT cleanup_old_alert_events();
```

## Development

### Adding New Migrations

```bash
# Create new migration
cd supabase
supabase migration new <migration_name>

# Edit the created file in supabase/migrations/

# Test locally
supabase db reset  # Resets local database
supabase db push   # Applies migrations

# Push to production
supabase db push --linked
```

### Migration Best Practices

1. **Incremental Changes:** Each migration should be atomic
2. **Backwards Compatible:** Avoid breaking changes when possible
3. **Rollback Plan:** Document how to reverse changes
4. **Test Locally:** Always test migrations before production
5. **Data Migration:** Separate schema changes from data migrations

### Local Development

```bash
# Start local Supabase
supabase start

# Apply migrations locally
supabase db push

# Reset local database
supabase db reset

# Stop local Supabase
supabase stop
```

## Schema Diagram

```
┌─────────────────┐
│ rpc_endpoints   │
└────────┬────────┘
         │
         ▼
┌─────────────────────┐
│ rpc_health_samples  │
└─────────────────────┘

┌─────────────┐
│ contracts   │
└──────┬──────┘
       │
       ▼
┌─────────────┐      ┌──────────────┐
│    txs      │─────►│ tx_traces    │
└─────────────┘      └──────────────┘

┌─────────────────┐
│ metrics_minute  │
└─────────────────┘

┌─────────────┐
│   alerts    │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│ alert_events    │
└─────────────────┘

┌─────────────────┐
│ worker_state    │
└─────────────────┘
```

## Statistics

- **Total Migrations:** 11
- **Total Tables:** 9
- **Total Indexes:** 20+
- **Storage Features:** Time-series optimized, automated retention

## Related Repositories

- **Main Repository:** https://github.com/hackonteam/m-obs
- **Backend (API + Worker):** https://github.com/hackonteam/m-obs-backend
- **Frontend (Web App):** https://github.com/hackonteam/m-obs-frontend

## Team

**HackOn Team Vietnam**

- **Bernie Nguyen** - Founder/Leader/Full-stack/Main developer
- **Thien Vo** - Front-end developer intern
- **Canh Trinh** - Researcher, Back-end developer intern
- **Sharkyz Duong Pham** - Business developer lead
- **Hieu Tran** - Business developer

**Collaboration:** Phu Nhuan Builder

**Contact:**
- Email: work.hackonteam@gmail.com
- Telegram: https://t.me/hackonteam

## License

MIT License - see LICENSE file

Copyright (c) 2026 HackOn Team Vietnam and Phu Nhuan Builder

## Contributing

Contributions are welcome! To contribute:

1. Fork this repository
2. Create a new migration file
3. Test locally with `supabase db reset && supabase db push`
4. Submit a pull request

Make sure migrations are:
- Properly numbered
- Idempotent when possible
- Well-documented
- Tested locally

## Support

For issues or questions:
- Open an issue in the main repository: https://github.com/hackonteam/m-obs/issues
- Contact: work.hackonteam@gmail.com
