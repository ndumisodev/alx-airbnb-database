-- database-adv-script/database_index.sql

-- This file contains SQL commands to create indexes for the Airbnb database schema,
-- and includes EXPLAIN ANALYZE statements to demonstrate performance changes.

-- ========================================================================
-- PART 1: Performance Measurement BEFORE Indexing
-- These queries are run before creating the indexes to show baseline performance.
-- ========================================================================

-- Query to test: Find bookings made by a specific user
-- Expected to show a full table scan (Seq Scan/ALL) without an index on bookings.user_id
EXPLAIN ANALYZE SELECT * FROM bookings WHERE user_id = 'a-dummy-user-uuid-for-test';

-- Query to test: Find properties by a specific host
-- Expected to show a full table scan without an index on properties.host_id
EXPLAIN ANALYZE SELECT * FROM properties WHERE host_id = 'a-dummy-host-uuid-for-test';

-- Query to test: Find bookings within a date range for a specific property
-- Expected to show a full table scan without a composite index on bookings.property_id, start_date, end_date
EXPLAIN ANALYZE SELECT * FROM bookings WHERE property_id = 'a-dummy-property-uuid-for-test' AND start_date BETWEEN '2025-01-01' AND '2025-01-31';

-- ========================================================================
-- PART 2: Index Creation
-- These commands create the necessary indexes.
-- ========================================================================

-- Indexes for 'users' table
-- user_id is already implicitly indexed as PRIMARY KEY
-- email is already implicitly indexed as UNIQUE
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Indexes for 'properties' table
-- property_id is already implicitly indexed as PRIMARY KEY
CREATE INDEX idx_properties_host_id ON properties(host_id);
CREATE INDEX idx_properties_location ON properties(location);
CREATE INDEX idx_properties_pricepernight ON properties(pricepernight);
CREATE INDEX idx_properties_created_at ON properties(created_at);

-- Indexes for 'bookings' table
-- booking_id is already implicitly indexed as PRIMARY KEY
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_property_dates ON bookings(property_id, start_date, end_date);
CREATE INDEX idx_bookings_status ON bookings(status);

-- Additional important foreign key indexes for other tables (good practice, though not explicitly asked for User/Booking/Property in initial task description)
-- Indexes for 'payments' table
CREATE INDEX idx_payments_booking_id ON payments(booking_id);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);

-- Indexes for 'reviews' table
CREATE INDEX idx_reviews_property_id ON reviews(property_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);

-- Indexes for 'messages' table
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX idx_messages_sent_at ON messages(sent_at);

-- ========================================================================
-- PART 3: Performance Measurement AFTER Indexing
-- These queries are run after creating the indexes to show improved performance.
-- ========================================================================

-- Re-run the same test queries
-- Expected to show index usage (Index Scan/Ref) and lower execution times.

EXPLAIN ANALYZE SELECT * FROM bookings WHERE user_id = 'a-dummy-user-uuid-for-test';

EXPLAIN ANALYZE SELECT * FROM properties WHERE host_id = 'a-dummy-host-uuid-for-test';

EXPLAIN ANALYZE SELECT * FROM bookings WHERE property_id = 'a-dummy-property-uuid-for-test' AND start_date BETWEEN '2025-01-01' AND '2025-01-31';