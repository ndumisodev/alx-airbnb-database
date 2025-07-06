# Database Performance Monitoring and Refinement Report

## Objective
This report documents the continuous process of monitoring and refining database performance for the ALX Airbnb clone. It includes analyzing query execution plans, identifying bottlenecks, suggesting and implementing schema adjustments (primarily new indexes), and reporting the observed performance improvements. The analysis is conducted using MySQL's `EXPLAIN ANALYZE` command.

## Monitoring Process
For continuous database performance, `EXPLAIN ANALYZE` is a crucial tool. It provides insights into how MySQL executes a query, including table access methods, join order, index usage, and details about actual rows processed and time spent. By regularly analyzing frequently used or slow queries, we can pinpoint inefficiencies and optimize them.

Below, we'll examine a few typical queries for an Airbnb application, identify their bottlenecks, propose and implement solutions, and demonstrate the resulting performance gains.

## 1. Query Analysis and Refinement: Finding Available Properties
This is a critical query for guests searching for accommodation.

### 1.1. Initial Query
This query aims to find properties in a specific location that are not booked during a given date range.

**Query SQL:**
```sql
SELECT
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    p.description
FROM
    properties AS p
LEFT JOIN
    bookings AS b
ON
    p.property_id = b.property_id AND
    b.status = 'confirmed' AND
    (
        ('2025-08-01' <= b.end_date AND '2025-08-31' >= b.start_date) 
    )
WHERE
    p.location = 'Cape Town' AND
    b.booking_id IS NULL; 


---


1.2. Initial EXPLAIN ANALYZE and Bottleneck IdentificationAssuming properties.location is not specifically indexed for WHERE clauses, and the bookings table is partitioned by start_date but might lack a specific composite index for this availability check.Command:sql

EXPLAIN ANALYZE
SELECT
    p.property_id, p.name, p.location, p.pricepernight, p.description
FROM
    properties AS p
LEFT JOIN
    bookings AS b
ON
    p.property_id = b.property_id AND b.status = 'confirmed' AND
    (('2025-08-01' <= b.end_date AND '2025-08-31' >= b.start_date))
WHERE
    p.location = 'Cape Town' AND b.booking_id IS NULL;

Simulated EXPLAIN ANALYZE Output (Before Refinement - MySQL):

+----+-------------+-------+------------+------+---------------------------+------+---------+------+---------+----------+------------------------------------------------------------------------------------+
| id | select_type | table | partitions | type | possible_keys             | key  | key_len | ref  | rows    | filtered | Extra                                                                              |
+----+-------------+-------+------------+------+---------------------------+------+---------+------+---------+----------+------------------------------------------------------------------------------------+
|  1 | SIMPLE      | p     | NULL       | ALL  | idx_properties_location   | NULL | NULL    | NULL | 1000000 | 10.00    | Using where                                                                        |
|  1 | SIMPLE      | b     | p_2025     | ALL  | idx_bookings_property_id  | NULL | NULL    | NULL | 2000000 | 0.05     | Using where; Not exists; Using join buffer (Block Nested Loop)                     |
+----+-------------+-------+------------+------+---------------------------+------+---------+------+---------+----------+------------------------------------------------------------------------------------+
-- Actual time: (actual time=0.000..1500.000 rows=X loops=1)
-- Execution Time: ~1500ms

Bottleneck Identification:
type: ALL for properties p: 
Indicates a full table scan on the properties table. Even with idx_properties_location as possible_keys, MySQL is not using it because location is often low cardinality or the optimizer decides a full scan is better with many matches (or it's just a general index, not optimized for range queries).
type: ALL for bookings b: 
The LEFT JOIN combined with the complex date range overlap condition and b.status filter might prevent effective use of existing indexes like idx_bookings_property_dates for the join. The Using join buffer (Block Nested Loop) suggests an inefficient join strategy.
High rows scanned: Millions of rows scanned for both tables.

1.3. Suggested Changes (Schema Adjustment)Composite Index on properties: 
Create a composite index on (location, property_id) to speed up filtering by location and subsequent joins.
Refined Composite Index on bookings: Ensure idx_bookings_property_dates is effectively covering property_id and the date range for availability. A more specific index might be needed if idx_bookings_property_dates is (property_id, start_date, end_date) and the date range is not always at the start of the index.

SQL to Implement Changes:sql

CREATE INDEX idx_properties_location_id ON properties(location, property_id);

-- Ensure a robust index for booking availability checks on the partitioned table
-- The existing idx_bookings_property_dates (property_id, start_date, end_date) should be sufficient.
-- If not, a covering index including status might be considered:
-- CREATE INDEX idx_bookings_availability ON bookings(property_id, start_date, end_date, status);
-- However, let's assume the existing idx_bookings_property_dates (which is on the master table)
-- combined with partition pruning, will be the main beneficiary here.

1.4. EXPLAIN ANALYZE After Changes and Observed ImprovementCommand: (Same query as before)sql

EXPLAIN ANALYZE
SELECT
    p.property_id, p.name, p.location, p.pricepernight, p.description
FROM
    properties AS p
LEFT JOIN
    bookings AS b
ON
    p.property_id = b.property_id AND b.status = 'confirmed' AND
    (('2025-08-01' <= b.end_date AND '2025-08-31' >= b.start_date))
WHERE
    p.location = 'Cape Town' AND b.booking_id IS NULL;

Simulated EXPLAIN ANALYZE Output (After Refinement - MySQL):

+----+-------------+-------+------------+------+---------------------------+--------------------------+---------+-------------------+---------+----------+----------------------------------------------------+
| id | select_type | table | partitions | type | possible_keys             | key                      | key_len | ref               | rows    | filtered | Extra                                              |
+----+-------------+-------+------------+------+---------------------------+--------------------------+---------+-------------------+---------+----------+----------------------------------------------------+
|  1 | SIMPLE      | p     | NULL       | ref  | PRIMARY,idx_properties_location_id | idx_properties_location_id | 768     | const             | 10000   | 100.00   | Using where; Using index                           |
|  1 | SIMPLE      | b     | p_2025     | ref  | idx_bookings_property_id,idx_bookings_property_dates | idx_bookings_property_dates | 36      | p.property_id | 5       | 0.05     | Using where; Not exists                            |
+----+-------------+-------+------------+------+---------------------------+--------------------------+---------+-------------------+---------+----------+----------------------------------------------------+
-- Actual time: (actual time=0.000..50.000 rows=X loops=1)
-- Execution Time: ~50ms

Observed Improvement:
type: ref for properties p: 
The new idx_properties_location_id is now effectively used, dramatically reducing the rows scanned for properties in 'Cape Town'.
type: ref for bookings b: 
The idx_bookings_property_dates (combined with partition pruning for p_2025) is now better utilized for the join and date range check. The Using join buffer is gone, indicating a more efficient nested loop or hash join.

Execution Time: Reduced from ~1500ms to ~50ms, a 30x improvement. This is critical for a high-traffic search feature.

2. Query Analysis and Refinement: User's Recent BookingsThis query fetches a user's recent bookings, commonly displayed on a user's dashboard.2.1. Initial Querysql

SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.name AS property_name,
    p.location
FROM
    bookings AS b
INNER JOIN
    properties AS p ON b.property_id = p.property_id
WHERE
    b.user_id = 'a-dummy-user-uuid-for-test' AND b.status IN ('confirmed', 'pending')
ORDER BY
    b.start_date DESC
LIMIT 10;

2.2. Initial EXPLAIN ANALYZE and Bottleneck IdentificationAssuming idx_bookings_user_id and idx_bookings_status exist, but a composite index for sorting might be missing.Command:sql

EXPLAIN ANALYZE
SELECT
    b.booking_id, b.start_date, b.end_date, b.total_price, b.status,
    p.name AS property_name, p.location
FROM
    bookings AS b
INNER JOIN
    properties AS p ON b.property_id = p.property_id
WHERE
    b.user_id = 'a-dummy-user-uuid-for-test' AND b.status IN ('confirmed', 'pending')
ORDER BY
    b.start_date DESC
LIMIT 10;

Simulated EXPLAIN ANALYZE Output (Before Refinement - MySQL):

+----+-------------+-------+------------+--------+---------------------------------------+---------------------+---------+-------+---------+----------+----------------------------------------------------+
| id | select_type | table | partitions | type   | possible_keys                         | key                 | key_len | ref   | rows    | filtered | Extra                                              |
+----+-------------+-------+------------+--------+---------------------------------------+---------------------+---------+-------+---------+----------+----------------------------------------------------+
|  1 | SIMPLE      | b     | p_2023,p_2024,p_2025 | ref    | idx_bookings_user_id,idx_bookings_status | idx_bookings_user_id| 36      | const | 100000  | 50.00    | Using where; Using filesort                        |
|  1 | SIMPLE      | p     | NULL       | eq_ref | PRIMARY                               | PRIMARY             | 36      | b.property_id | 1       | 100.00   | Using where                                        |
+----+-------------+-------+------------+--------+---------------------------------------+---------------------+---------+-------+---------+----------+----------------------------------------------------+
-- Actual time: (actual time=0.000..800.000 rows=X loops=1)
-- Execution Time: ~800ms

Bottleneck Identification:Using filesort in Extra for bookings b:
 This is a major red flag. It means MySQL has to collect all qualifying rows, sort them in a temporary buffer (potentially on disk if too large), and then apply the LIMIT. This bypasses index-based sorting.
 While idx_bookings_user_id is used, the ORDER BY b.start_date DESC with status filtering leads to the filesort.

2.3. Suggested Changes (New Index)Create a composite index that covers the WHERE clause conditions and the ORDER BY clause in the correct order.SQL to Implement Changes:sql

-- Create a covering index for user-specific bookings with sorting and status filtering
CREATE INDEX idx_bookings_user_status_startdate ON bookings(user_id, status, start_date DESC);

2.4. EXPLAIN ANALYZE After Changes and Observed ImprovementCommand: (Same query as before)sql

EXPLAIN ANALYZE
SELECT
    b.booking_id, b.start_date, b.end_date, b.total_price, b.status,
    p.name AS property_name, p.location
FROM
    bookings AS b
INNER JOIN
    properties AS p ON b.property_id = p.property_id
WHERE
    b.user_id = 'a-dummy-user-uuid-for-test' AND b.status IN ('confirmed', 'pending')
ORDER BY
    b.start_date DESC
LIMIT 10;

Simulated EXPLAIN ANALYZE Output (After Refinement - MySQL):

+----+-------------+-------+------------+--------+-----------------------------------------------------------------+---------------------------------+---------+-------+---------+----------+-----------------------+
| id | select_type | table | partitions | type   | possible_keys                                                   | key                             | key_len | ref   | rows    | filtered | Extra                 |
+----+-------------+-------+------------+--------+-----------------------------------------------------------------+---------------------------------+---------+-------+---------+----------+-----------------------+
|  1 | SIMPLE      | b     | p_2023,p_2024,p_2025 | range  | idx_bookings_user_id,idx_bookings_status,idx_bookings_user_status_startdate | idx_bookings_user_status_startdate | 36      | NULL  | 10      | 100.00   | Using where; Using index |
|  1 | SIMPLE      | p     | NULL       | eq_ref | PRIMARY                                                         | PRIMARY                         | 36      | b.property_id | 1       | 100.00   | Using where           |
+----+-------------+-------+------------+--------+-----------------------------------------------------------------+---------------------------------+---------+-------+---------+----------+-----------------------+
-- Actual time: (actual time=0.000..15.000 rows=X loops=1)
-- Execution Time: ~15ms

Observed Improvement:
Using filesort eliminated: The Extra column no longer shows Using filesort. MySQL can now use the idx_bookings_user_status_startdate index to get the top 10 rows in the correct order directly.
type: range for bookings b: Shows efficient index usage for both filtering and ordering.
Execution Time: Reduced from 800ms to ~15ms, a **53x improvement**. This is crucial for fast user dashboard loading.

3. Query Analysis and Refinement: Properties with High Average ReviewsThis query helps identify popular or highly-rated properties.3.1. Initial Querysql

SELECT
    p.property_id,
    p.name,
    AVG(r.rating) AS avg_rating
FROM
    properties AS p
INNER JOIN
    reviews AS r ON p.property_id = r.property_id
GROUP BY
    p.property_id, p.name
HAVING
    AVG(r.rating) >= 4.5
ORDER BY
    avg_rating DESC
LIMIT 5;

3.2. Initial EXPLAIN ANALYZE and Bottleneck IdentificationAssuming idx_reviews_property_id exists, but no specific index to aid AVG(rating) or ORDER BY avg_rating.Command:sql

EXPLAIN ANALYZE
SELECT
    p.property_id, p.name, AVG(r.rating) AS avg_rating
FROM
    properties AS p
INNER JOIN
    reviews AS r ON p.property_id = r.property_id
GROUP BY
    p.property_id, p.name
HAVING
    AVG(r.rating) >= 4.5
ORDER BY
    avg_rating DESC
LIMIT 5;

Simulated EXPLAIN ANALYZE Output (Before Refinement - MySQL):

+----+-------------+-------+------------+--------+--------------------------+---------------------+---------+-----------------+---------+----------+----------------------------------------------------------------+
| id | select_type | table | partitions | type   | possible_keys            | key                 | key_len | ref             | rows    | filtered | Extra                                                          |
+----+-------------+-------+------------+--------+--------------------------+---------------------+---------+-----------------+---------+----------+----------------------------------------------------------------+
|  1 | SIMPLE      | p     | NULL       | ALL    | PRIMARY                  | NULL                | NULL    | NULL            | 1000000 | 100.00   | Using temporary; Using filesort                                |
|  1 | SIMPLE      | r     | NULL       | ref    | idx_reviews_property_id  | idx_reviews_property_id | 36      | p.property_id   | 10      | 100.00   | Using where                                                    |
+----+-------------+-------+------------+--------+--------------------------+---------------------+---------+-----------------+---------+----------+----------------------------------------------------------------+
-- Actual time: (actual time=0.000..2500.000 rows=X loops=1)
-- Execution Time: ~2500ms

Bottleneck Identification:
Using temporary; Using filesort for properties p: This indicates that MySQL is creating a temporary table (likely in memory or on disk) to perform the GROUP BY and then sorting that temporary table for the ORDER BY avg_rating DESC. This is very inefficient for large datasets.
type: ALL for properties p: The join might not be optimized if the properties table is large and not starting efficiently.

3.3. Suggested Changes (New Index)Create a composite index on the reviews table that can cover the GROUP BY and AVG calculation, and potentially aid the join.SQL to Implement Changes:sql

-- Create a covering index for reviews that supports grouping and aggregation
-- The order of columns matters: property_id for grouping, rating for aggregation.
CREATE INDEX idx_reviews_property_rating ON reviews(property_id, rating);

3.4. EXPLAIN ANALYZE After Changes and Observed ImprovementCommand: (Same query as before)sql

EXPLAIN ANALYZE
SELECT
    p.property_id, p.name, AVG(r.rating) AS avg_rating
FROM
    properties AS p
INNER JOIN
    reviews AS r ON p.property_id = r.property_id
GROUP BY
    p.property_id, p.name
HAVING
    AVG(r.rating) >= 4.5
ORDER BY
    avg_rating DESC
LIMIT 5;

Simulated EXPLAIN ANALYZE Output (After Refinement - MySQL):

+----+-------------+-------+------------+--------+---------------------------------------+---------------------------+---------+-----------------+---------+----------+----------------------------------------------------------------+
| id | select_type | table | partitions | type   | possible_keys                         | key                       | key_len | ref             | rows    | filtered | Extra                                                          |
+----+-------------+-------+------------+--------+---------------------------------------+---------------------------+---------+-----------------+---------+----------+----------------------------------------------------------------+
|  1 | SIMPLE      | r     | NULL       | ref    | idx_reviews_property_id,idx_reviews_property_rating | idx_reviews_property_rating | 36      | p.property_id   | 10      | 100.00   | Using where; Using index for group-by                        |
|  1 | SIMPLE      | p     | NULL       | eq_ref | PRIMARY                               | PRIMARY                   | 36      | r.property_id   | 1       | 100.00   |                                                                |
+----+-------------+-------+------------+--------+---------------------------------------+---------------------------+---------+-----------------+---------+----------+----------------------------------------------------------------+
-- Actual time: (actual time=0.000..150.000 rows=X loops=1)
-- Execution Time: ~150ms

Observed Improvement:
Using index for group-by for reviews r: The idx_reviews_property_rating index is now effectively used to accelerate the GROUP BY operation. This significantly reduces the work required to calculate average ratings.
Reduced rows scanned for reviews: The index helps narrow down the data faster.
Execution Time: Reduced from 2500ms to ~150ms, a **16x improvement**. While Using filesort for the ORDER BY avg_rating might persist if the result set is large, the GROUP BY step is dramatically optimized, leading to overall significant speedup.

Summary of Refinements
properties table: Added a composite index idx_properties_location_id on (location, property_id) to optimize location-based searches and joins.
bookings table: Added a composite index idx_bookings_user_status_startdate on (user_id, status, start_date DESC) to optimize user-specific booking queries with filtering and sorting.
reviews table: Added a composite index idx_reviews_property_rating on (property_id, rating) to accelerate aggregation (AVG) and grouping for review-based queries.

Conclusion
Continuous monitoring and refinement are essential for maintaining optimal database performance, 
especially as data volume grows and application query patterns evolve. By diligently using tools 
like EXPLAIN ANALYZE, we can proactively identify bottlenecks, implement targeted schema adjustments 
(primarily new and refined indexes), and achieve significant performance improvements. The exercises above 
demonstrate how such an iterative process can transform slow, resource-intensive queries into fast and efficient operations, directly contributing to a responsive and scalable application experience.




