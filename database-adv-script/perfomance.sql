-- database-adv-script/perfomance.sql

-- ===================================================================================
-- Initial Complex Query (Before Optimization)
-- Objective: Retrieve all bookings along with associated user, property,
-- and payment details without specific performance considerations.
-- This query aims for comprehensiveness by joining all relevant tables.
-- ===================================================================================
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    u.user_id,
    u.first_name AS user_first_name,
    u.last_name AS user_last_name,
    u.email AS user_email,
    p.property_id,
    p.name AS property_name,
    p.location AS property_location,
    p.pricepernight AS property_price_per_night,
    py.payment_id,
    py.amount AS payment_amount,
    py.payment_date,
    py.payment_method
FROM
    bookings b
INNER JOIN
    users u ON b.user_id = u.user_id
INNER JOIN
    properties p ON b.property_id = p.property_id
LEFT JOIN
    payments py ON b.booking_id = py.booking_id
ORDER BY
    b.start_date DESC;

-- ===================================================================================
-- Optimized Query (After Refactoring)
-- Objective: Significantly improve query performance by reducing data scope,
-- optimizing join strategies, and restructuring data retrieval for efficiency.
-- This version focuses on recent bookings and aggregates payment details.
--
-- Note: This query uses PostgreSQL-specific functions (json_agg, CURRENT_DATE - INTERVAL)
-- ===================================================================================
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status AS booking_status,
    u.user_id,
    u.first_name AS user_first_name,
    u.last_name AS user_last_name,
    p.property_id,
    p.name AS property_name,
    p.location AS property_location,
    -- Aggregate payment details into a JSON array for each booking.
    -- This avoids row multiplication if a booking had multiple payments
    -- and optimizes data transfer by delivering payment info as a single object.
    (
        SELECT
            json_agg(
                json_build_object(
                    'payment_id', py_sub.payment_id,
                    'amount', py_sub.amount,
                    'payment_date', py_sub.payment_date,
                    'payment_method', py_sub.payment_method
                )
            )
        FROM
            payments AS py_sub
        WHERE
            py_sub.booking_id = b.booking_id
    ) AS payment_details
FROM
    bookings b
-- Use USING clause for cleaner syntax when join columns have identical names.
INNER JOIN
    users u USING (user_id)
INNER JOIN
    properties p USING (property_id)
WHERE
    -- Data Limitation: Filter for recent bookings to reduce dataset size.
    -- This leverages an index on b.start_date if available.
    b.start_date >= CURRENT_DATE - INTERVAL '6 months'
ORDER BY
    b.start_date DESC
LIMIT 1000; -- Data Limitation: Limit the number of rows returned to prevent excessive results.







