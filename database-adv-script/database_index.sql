-- database-adv-script/database_index.sql

-- Indexes for 'users' table
-- user_id is already implicitly indexed as PRIMARY KEY
-- email is already implicitly indexed as UNIQUE
-- Adding index on role for filtering users by their role
CREATE INDEX idx_users_role ON users(role);
-- Adding index on created_at for queries involving user creation date ranges or ordering
CREATE INDEX idx_users_created_at ON users(created_at);

-- Indexes for 'properties' table
-- property_id is already implicitly indexed as PRIMARY KEY
-- host_id is a foreign key, frequently used in JOINs and WHERE clauses to find properties by host.
CREATE INDEX idx_properties_host_id ON properties(host_id);
-- location for searching properties by location
CREATE INDEX idx_properties_location ON properties(location);
-- pricepernight for filtering or ordering properties by price
CREATE INDEX idx_properties_pricepernight ON properties(pricepernight);
-- created_at for finding newly listed properties or date range queries
CREATE INDEX idx_properties_created_at ON properties(created_at);


-- Indexes for 'bookings' table
-- booking_id is already implicitly indexed as PRIMARY KEY
-- user_id is a foreign key, crucial for looking up bookings by user
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
-- property_id is a foreign key, crucial for looking up bookings for a property
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
-- start_date and end_date are critical for date range queries (e.g., availability checks)
-- A composite index on (property_id, start_date, end_date) is highly beneficial for availability checks.
-- This allows queries to quickly find bookings for a specific property within a date range.
CREATE INDEX idx_bookings_property_dates ON bookings(property_id, start_date, end_date);
-- status for filtering bookings by their current state
CREATE INDEX idx_bookings_status ON bookings(status);


-- Additional important foreign key indexes for other tables (good practice, though not explicitly asked for User/Booking/Property)
-- Indexes for 'payments' table
-- booking_id is a foreign key
CREATE INDEX idx_payments_booking_id ON payments(booking_id);
-- payment_date for filtering payments by date
CREATE INDEX idx_payments_payment_date ON payments(payment_date);


-- Indexes for 'reviews' table
-- property_id is a foreign key
CREATE INDEX idx_reviews_property_id ON reviews(property_id);
-- user_id is a foreign key
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
-- created_at for filtering reviews by date or ordering
CREATE INDEX idx_reviews_created_at ON reviews(created_at);


-- Indexes for 'messages' table
-- sender_id and recipient_id are foreign keys
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_recipient_id ON messages(recipient_id);
-- sent_at for ordering messages in a conversation
CREATE INDEX idx_messages_sent_at ON messages(sent_at);