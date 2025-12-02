-- clean.sql
-- Truncate all data and restart identity sequences for clean testing.
-- Run this after you've finished a test run to remove all data but keep the schema.

BEGIN;
TRUNCATE TABLE
    navigates,
    valid_in,
    certification,
    trip,
    authorized,
    reservation,
    senior,
    junior,
    sailor,
    boat,
    boat_class,
    location,
    jurisdiction,
    country
RESTART IDENTITY CASCADE;
COMMIT;

-- Notes:
-- - This preserves table structure but removes all rows and resets auto-increment sequences.
-- - If you prefer to completely drop and recreate the schema, re-run `\i schema.sql`.
-- - To remove only data for a subset of tables, adjust the TRUNCATE list above.
