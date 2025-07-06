-- File: aggregations_and_window_functions.sql

-- Query 1: Count bookings per user
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings
FROM 
    users u
LEFT JOIN 
    bookings b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name
ORDER BY 
    total_bookings DESC;


-- Query 2: Rank properties by booking count
WITH property_booking_counts AS (
    SELECT 
        p.property_id,
        p.name AS property_name,
        COUNT(b.booking_id) AS booking_count
    FROM 
        properties p
    LEFT JOIN 
        bookings b ON p.property_id = b.property_id
    GROUP BY 
        p.property_id, p.name
)
SELECT 
    property_id,
    property_name,
    booking_count,
    RANK() OVER (ORDER BY booking_count DESC) AS property_rank,
    DENSE_RANK() OVER (ORDER BY booking_count DESC) AS dense_property_rank,
    ROW_NUMBER() OVER (ORDER BY booking_count DESC) AS row_num
FROM 
    property_booking_counts
ORDER BY 
    property_rank;