-- database-adv-script/partitioning.sql

-- ========================================================================
-- Table Partitioning Implementation for 'bookings' table (MySQL)
-- Objective: Optimize queries on large datasets by partitioning the
-- 'bookings' table based on the 'start_date' column.
-- This script demonstrates MySQL's RANGE partitioning syntax.
--
-- IMPORTANT: In a real-world scenario, migrating an existing, populated
-- table to a partitioned table involves more complex steps (e.g.,
-- creating the new partitioned table, migrating data, renaming tables,
-- re-establishing foreign keys and indexes, handling downtime).
-- This script focuses on illustrating the CREATE TABLE ... PARTITION BY
-- and subsequent data insertion for a new partitioned table.
-- ========================================================================

-- STEP 1: (Optional, for demonstration) Drop existing bookings table if it's not partitioned
-- In a real scenario, you would back up data, rename the original table,
-- or perform a more complex migration.
DROP TABLE IF EXISTS bookings CASCADE;

-- STEP 2: Create the master partitioned 'bookings' table
-- This table defines the partitioning scheme.
-- We are using RANGE partitioning on TO_DAYS(start_date) as MySQL requires an integer.
CREATE TABLE bookings (
    booking_id CHAR(36) PRIMARY KEY, -- UUIDs often stored as CHAR(36) in MySQL
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL, -- ENUM (pending, confirmed, canceled)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
PARTITION BY RANGE (TO_DAYS(start_date)) (
    -- Partition for historical data (before 2023)
    PARTITION p_historical VALUES LESS THAN (TO_DAYS('2023-01-01')),
    -- Partition for 2023 bookings
    PARTITION p_2023 VALUES LESS THAN (TO_DAYS('2024-01-01')),
    -- Partition for 2024 bookings
    PARTITION p_2024 VALUES LESS THAN (TO_DAYS('2025-01-01')),
    -- Partition for 2025 bookings
    PARTITION p_2025 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    -- Partition for future bookings (all dates beyond 2025)
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- STEP 3: Re-establish Foreign Key Constraints
-- These constraints are defined on the master partitioned table.
-- Ensure 'users' and 'properties' tables exist with UUID primary keys.
ALTER TABLE bookings ADD CONSTRAINT fk_user
FOREIGN KEY (user_id) REFERENCES users(user_id);

ALTER TABLE bookings ADD CONSTRAINT fk_property
FOREIGN KEY (property_id) REFERENCES properties(property_id);

-- STEP 4: Re-create Indexes on the partitioned table
-- Indexes should be created on the master partitioned table.
-- MySQL automatically applies these to all partitions.
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_property_dates ON bookings(start_date, end_date); -- Composite index for date range queries
CREATE INDEX idx_bookings_status ON bookings(status);


-- ========================================================================
-- STEP 5: Data Migration (if moving from an unpartitioned table)
-- If you have an existing 'bookings_old' table, you would insert its data here.
-- For a fresh setup, you would populate this table with new data.
-- Example: INSERT INTO bookings SELECT * FROM bookings_old;
-- For testing, ensure you insert data that falls into different partitions.
-- Example:
-- INSERT INTO bookings (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
-- ('b1-2023', 'p1', 'u1', '2023-05-10', '2023-05-15', 150.00, 'confirmed', NOW()),
-- ('b2-2024', 'p2', 'u2', '2024-01-20', '2024-01-25', 200.00, 'pending', NOW()),
-- ('b3-2024', 'p3', 'u3', '2024-07-01', '2024-07-07', 300.00, 'confirmed', NOW()),
-- ('b4-2025', 'p4', 'u4', '2025-03-15', '2025-03-20', 250.00, 'confirmed', NOW()),
-- ('b5-hist', 'p5', 'u5', '2022-11-01', '2022-11-05', 100.00, 'canceled', NOW());
-- ========================================================================

-- ========================================================================
-- STEP 6: Performance Testing with EXPLAIN ANALYZE
-- To observe the benefits of partitioning, you need to:
-- 1. Populate the 'bookings' table with a large amount of data spanning multiple years.
-- 2. Run the EXPLAIN ANALYZE queries below.
--    Replace dummy UUIDs with actual ones from your seeded data for meaningful results.
-- ========================================================================

-- Test Query 1: Fetch bookings for a specific date range within a single partition (e.g., within 2024)
-- Expected to show partition pruning, only scanning 'p_2024'.
EXPLAIN ANALYZE
SELECT *
FROM bookings
WHERE start_date >= '2024-03-01' AND start_date <= '2024-03-31';

-- Test Query 2: Fetch bookings for a date range spanning multiple partitions (e.g., late 2024 to early 2025)
-- Expected to show scanning of 'p_2024' and 'p_2025'.
EXPLAIN ANALYZE
SELECT *
FROM bookings
WHERE start_date >= '2024-11-01' AND start_date <= '2025-02-28';

-- Test Query 3: Fetch bookings from a specific partition using the partitioning key
EXPLAIN ANALYZE
SELECT *
FROM bookings
WHERE start_date >= '2023-01-01' AND start_date < '2024-01-01' AND status = 'confirmed';

-- Test Query 4: Query that might not benefit as much from partitioning (e.g., filtering only by status)
-- Expected to scan all partitions.
EXPLAIN ANALYZE
SELECT *
FROM bookings
WHERE status = 'pending';