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

-- 2. LEFT JOIN: All properties with their reviews (including properties with no reviews)
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
LEFT JOIN reviews r ON p.property_id = r.property_id;

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

-- Bonus: Complex join showing property bookings with host and guest info
-- SELECT
--     p.property_id,
--     p.name AS property_name,
--     h.first_name AS host_first_name,
--     h.last_name AS host_last_name,
--     b.booking_id,
--     b.start_date,
--     b.end_date,
--     g.first_name AS guest_first_name,
--     g.last_name AS guest_last_name,
--     r.rating,
--     r.comment
-- FROM properties p
-- JOIN users h ON p.host_id = h.user_id
-- JOIN bookings b ON p.property_id = b.property_id
-- JOIN users g ON b.user_id = g.user_id
-- LEFT JOIN reviews r ON (p.property_id = r.property_id AND b.user_id = r.user_id);