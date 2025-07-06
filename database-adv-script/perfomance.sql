-- database-adv-script/perfomance.sql

-- ===================================================================================
-- Initial Complex Query (Before Optimization)
-- Objective: Retrieve all bookings along with associated user, property,
-- and payment details without specific performance considerations.
-- This query aims for comprehensiveness by joining all relevant tables.
-- ===================================================================================
-- Initial query with all joins
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    py.payment_id,
    py.amount,
    py.payment_date,
    py.payment_method
FROM 
    bookings b
JOIN 
    users u ON b.user_id = u.user_id
JOIN 
    properties p ON b.property_id = p.property_id
LEFT JOIN 
    payments py ON b.booking_id = py.booking_id
ORDER BY 
    b.start_date DESC;

-- EXPLAIN ANALYZE of initial query
EXPLAIN ANALYZE 
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    py.payment_id,
    py.amount,
    py.payment_date,
    py.payment_method
FROM 
    bookings b
JOIN 
    users u ON b.user_id = u.user_id
JOIN 
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
-- Optimized query with date filter
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    p.property_id,
    p.name AS property_name,
    p.location,
    (
        SELECT json_agg(py)
        FROM (
            SELECT 
                payment_id,
                amount,
                payment_date,
                payment_method
            FROM 
                payments
            WHERE 
                booking_id = b.booking_id
        ) py
    ) AS payment_details
FROM 
    bookings b
JOIN 
    users u ON b.user_id = u.user_id
JOIN 
    properties p ON b.property_id = p.property_id
WHERE 
    b.start_date >= CURRENT_DATE - INTERVAL '6 months'
    AND b.status = 'confirmed'
ORDER BY 
    b.start_date DESC
LIMIT 1000;

-- EXPLAIN ANALYZE of optimized query
EXPLAIN ANALYZE 
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    p.property_id,
    p.name AS property_name,
    p.location,
    (
        SELECT json_agg(py)
        FROM (
            SELECT 
                payment_id,
                amount,
                payment_date,
                payment_method
            FROM 
                payments
            WHERE 
                booking_id = b.booking_id
        ) py
    ) AS payment_details
FROM 
    bookings b
JOIN 
    users u ON b.user_id = u.user_id
JOIN 
    properties p ON b.property_id = p.property_id
WHERE 
    b.start_date >= CURRENT_DATE - INTERVAL '6 months'
    AND b.status = 'confirmed'
ORDER BY 
    b.start_date DESC
LIMIT 1000;







