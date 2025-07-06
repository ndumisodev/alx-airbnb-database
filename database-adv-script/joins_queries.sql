-- 1. INNER JOIN: All bookings with user details
SELECT 
    b.booking_id, 
    b.start_date, 
    b.end_date,
    b.total_price,
    b.status,
    u.user_id, 
    u.first_name, 
    u.last_name, 
    u.email
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id;

-- 2. LEFT JOIN: Retrieve all properties and their reviews (including properties with no reviews)
-- Ordered by property_id and review date (newest first)
SELECT 
    p.property_id, 
    p.name AS property_name,
    p.location,
    p.pricepernight,
    r.review_id, 
    r.rating, 
    r.comment, 
    r.created_at AS review_date
FROM properties p
LEFT JOIN reviews r ON p.property_id = r.property_id
ORDER BY p.property_id, r.created_at DESC;

-- 3. FULL OUTER JOIN: All users and all bookings
-- (shows users without bookings and bookings without users)
SELECT 
    u.user_id, 
    u.first_name, 
    u.last_name,
    u.role,
    b.booking_id, 
    b.start_date, 
    b.end_date,
    b.status
FROM users u
FULL OUTER JOIN bookings b ON u.user_id = b.user_id;

