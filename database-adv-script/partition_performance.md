# Booking Table Partitioning Performance Report

This report details the implementation of table partitioning on the `bookings` table in a **MySQL** database environment and analyzes its impact on query performance.

## 1. Implementation Overview

To optimize query performance for date-based searches on the potentially large `bookings` table, we implemented **`RANGE` partitioning** based on the `start_date` column. MySQL requires the partitioning key to be an integer, so the `TO_DAYS()` function was used on `start_date`.

The partitioning strategy divides the data into logical time periods, allowing MySQL to use **partition pruning** to scan only relevant partitions during queries.

**Partitioning Scheme:**

* **`bookings_partitioned` (Master Table):**
    ```sql
    CREATE TABLE bookings (
        booking_id CHAR(36) PRIMARY KEY, -- Primary key must include partitioning key
        -- ... other columns ...
        start_date DATE NOT NULL
    )
    PARTITION BY RANGE (TO_DAYS(start_date)) (
        PARTITION p_historical VALUES LESS THAN (TO_DAYS('2023-01-01')),
        PARTITION p_2023 VALUES LESS THAN (TO_DAYS('2024-01-01')),
        PARTITION p_2024 VALUES LESS THAN (TO_DAYS('2025-01-01')),
        PARTITION p_2025 VALUES LESS THAN (TO_DAYS('2026-01-01')),
        PARTITION p_future VALUES LESS THAN MAXVALUE
    );
    ```
* **Partition Definitions:**
    1.  **`p_historical`**: Bookings with `start_date` before '2023-01-01'.
    2.  **`p_2023`**: Bookings from '2023-01-01' up to (but not including) '2024-01-01'.
    3.  **`p_2024`**: Bookings from '2024-01-01' up to (but not including) '2025-01-01'.
    4.  **`p_2025`**: Bookings from '2025-01-01' up to (but not including) '2026-01-01'.
    5.  **`p_future`**: All bookings with `start_date` on or after '2026-01-01' (or any date not covered by previous partitions).

**Key Implementation Points:**

* The `PRIMARY KEY` on the partitioned table (`booking_id, start_date`) **must** include the partitioning column (`start_date`).
* Foreign key constraints and secondary indexes (e.g., `idx_bookings_user_id`, `idx_bookings_property_id`) were created on the master `bookings` table, and MySQL automatically manages them across all partitions.

## 2. Performance Tests

To evaluate the impact of partitioning, the `bookings` table was populated with a large dataset (e.g., **5,000,000 rows** distributed across the defined partitions). `EXPLAIN ANALYZE` was used to compare query execution plans and actual performance.

### 2.1. Test Query 1: Date Range Query (Single Partition)

**Objective:** Fetch bookings for a specific period within a single partition.
**Query:**
```sql
SELECT * FROM bookings
WHERE start_date BETWEEN '2023-06-01' AND '2023-12-31';




