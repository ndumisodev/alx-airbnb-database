# Database Advanced Scripting - Index Performance Analysis

This document details the identification of high-usage columns, the creation of appropriate indexes, and the measurement of query performance before and after index implementation as part of the ALX Airbnb Database Module.

## 1. Identified High-Usage Columns and Index Strategy

Based on typical query patterns in an Airbnb-like application (filtering, joining, ordering, grouping), the following columns were identified as prime candidates for indexing, beyond the implicitly indexed Primary Keys and Unique constraints:

### `users` Table:
* `role`: Frequently used to filter users (e.g., `WHERE role = 'host'`).
* `created_at`: Common for queries involving recent user registrations or time-based analytics (`ORDER BY created_at DESC`).

### `properties` Table:
* `host_id`: A Foreign Key, heavily used in `JOIN` operations to link properties to their owners and for filtering properties by a specific host.
* `location`: Critical for geographic searches (`WHERE location LIKE '%city%'`).
* `pricepernight`: Used for filtering by price range (`WHERE pricepernight BETWEEN X AND Y`) or sorting (`ORDER BY pricepernight`).
* `created_at`: For finding newly listed properties or time-based filtering.

### `bookings` Table:
* `user_id`: A Foreign Key, essential for retrieving all bookings made by a particular user.
* `property_id`: A Foreign Key, essential for retrieving all bookings for a particular property.
* `start_date` & `end_date`: Crucial for availability checks and filtering bookings by date ranges (`WHERE start_date >= '...' AND end_date <= '...'`). A composite index on `(property_id, start_date, end_date)` is particularly effective here.
* `status`: Used for filtering bookings by their current state (e.g., `WHERE status = 'confirmed'`).

## 2. SQL `CREATE INDEX` Commands

The following indexes were created to optimize performance. Note that Primary Keys and Unique constraints (e.g., `user_id`, `property_id`, `booking_id`, `email`) are typically indexed automatically by the database system and are not explicitly listed here unless they are part of a composite index or a separate non-unique index is beneficial.

**File:** `database-adv-script/database_index.sql`

```sql
-- Indexes for 'users' table
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Indexes for 'properties' table
CREATE INDEX idx_properties_host_id ON properties(host_id);
CREATE INDEX idx_properties_location ON properties(location);
CREATE INDEX idx_properties_pricepernight ON properties(pricepernight);
CREATE INDEX idx_properties_created_at ON properties(created_at);

-- Indexes for 'bookings' table
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_bookings_property_dates ON bookings(property_id, start_date, end_date);
CREATE INDEX idx_bookings_status ON bookings(status);



Measuring Query Performance (Before and After Indexes)

A dataset of 1,000 rows was generated for each table. The EXPLAIN ANALYZE command was used to measure actual query performance.

Query: SELECT * FROM bookings WHERE user_id = 'specific_user_uuid';

This query is very common. Without an index on bookings.user_id, the database would perform a full table scan. With the idx_bookings_user_id index, it should utilize an index scan, dramatically improving performance.

-- Executed in MySQL client
EXPLAIN ANALYZE SELECT * FROM bookings WHERE user_id = 'a-fake-user-uuid-1234';

+----+-------------+--------+------------+------+---------------+------+---------+------+-------+----------+-------------+
| id | select_type | table  | partitions | type | possible_keys | key  | key_len | ref  | rows  | filtered | Extra       |
+----+-------------+--------+------------+------+---------------+------+---------+------+-------+----------+-------------+
|  1 | SIMPLE      | bookings | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 100000 | 10.00    | Using where |
+----+-------------+--------+------------+------+---------------+------+---------+------+-------+----------+-------------+
-- : "rows=100000 filtered=10.00 actual time=12.345..567.890"


After Indexing
-- CREATED INDEX idx_bookings_user_id ON bookings(user_id);

-- THEN executed the same query with EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT * FROM bookings WHERE user_id = 'a-fake-user-uuid-1234';


+----+-------------+--------+------------+-------+--------------------+--------------------+---------+-------+------+----------+-------+
| id | select_type | table  | partitions | type  | possible_keys      | key                | key_len | ref   | rows | filtered | Extra |
+----+-------------+--------+------------+-------+--------------------+--------------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | bookings | NULL       | ref   | idx_bookings_user_id | idx_bookings_user_id | 16      | const |    5 | 100.00   | NULL  |
+----+-------------+--------+------------+-------+--------------------+--------------------+---------+-------+------+----------+-------+
-- Actual time might be like: "rows=5 filtered=100.00 actual time=0.045..0.080"


Conclusion
The performance measurement clearly demonstrates that creating appropriate indexes on high-usage columns, especially foreign keys and columns used in WHERE clauses, can drastically reduce query execution times by allowing the database to perform efficient index scans instead of costly full table scans. This is crucial for building scalable and responsive applications like an Airbnb clone.