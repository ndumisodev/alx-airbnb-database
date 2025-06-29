-- Schema Definition for Airbnb Clone Database

-- Table: users
-- Stores user information, including guests, hosts, and administrators.
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Primary Key, UUID, automatically indexed
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL, -- Unique constraint on email
    password_hash VARCHAR(255) NOT NULL, -- Stores hashed password
    phone_number VARCHAR(50), -- Can be NULL
    role VARCHAR(50) NOT NULL CHECK (role IN ('guest', 'host', 'admin')), -- ENUM type simulation
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster lookups by email
CREATE INDEX idx_users_email ON users (email);


-- Table: properties
-- Stores details about properties listed by hosts.
CREATE TABLE properties (
    property_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Primary Key, UUID, automatically indexed
    host_id UUID NOT NULL, -- Foreign Key to users table (host)
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    pricepernight DECIMAL(10, 2) NOT NULL, -- DECIMAL for currency, 10 total digits, 2 after decimal
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraint for host_id
    CONSTRAINT fk_host
        FOREIGN KEY (host_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE -- If a user (host) is deleted, their properties are also deleted
);

-- Index for faster lookups by host_id
CREATE INDEX idx_properties_host_id ON properties (host_id);
-- Index for faster lookups by location
CREATE INDEX idx_properties_location ON properties (location);


-- Table: bookings
-- Records reservations made by users for properties.
CREATE TABLE bookings (
    booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Primary Key, UUID, automatically indexed
    property_id UUID NOT NULL, -- Foreign Key to properties table
    user_id UUID NOT NULL, -- Foreign Key to users table (guest)
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'confirmed', 'canceled')), -- ENUM type simulation
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraint for property_id
    CONSTRAINT fk_booking_property
        FOREIGN KEY (property_id)
        REFERENCES properties (property_id)
        ON DELETE CASCADE, -- If a property is deleted, associated bookings are also deleted

    -- Foreign Key Constraint for user_id
    CONSTRAINT fk_booking_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE -- If a user (guest) is deleted, their bookings are also deleted
);

-- Index for faster lookups by property_id and user_id in bookings
CREATE INDEX idx_bookings_property_id ON bookings (property_id);
CREATE INDEX idx_bookings_user_id ON bookings (user_id);


-- Table: payments
-- Records payment transactions for bookings.
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Primary Key, UUID, automatically indexed
    booking_id UUID NOT NULL, -- Foreign Key to bookings table
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('credit_card', 'paypal', 'stripe')), -- ENUM type simulation

    -- Foreign Key Constraint for booking_id
    CONSTRAINT fk_payment_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings (booking_id)
        ON DELETE CASCADE -- If a booking is deleted, associated payments are also deleted
);

-- Index for faster lookups by booking_id in payments
CREATE INDEX idx_payments_booking_id ON payments (booking_id);


-- Table: reviews
-- Stores user reviews for properties.
CREATE TABLE reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Primary Key, UUID, automatically indexed
    property_id UUID NOT NULL, -- Foreign Key to properties table
    user_id UUID NOT NULL, -- Foreign Key to users table (reviewer)
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5), -- Rating constraint
    comment TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraint for property_id
    CONSTRAINT fk_review_property
        FOREIGN KEY (property_id)
        REFERENCES properties (property_id)
        ON DELETE CASCADE, -- If a property is deleted, its reviews are also deleted

    -- Foreign Key Constraint for user_id
    CONSTRAINT fk_review_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE -- If a user is deleted, their reviews are also deleted
);

-- Index for faster lookups by property_id and user_id in reviews
CREATE INDEX idx_reviews_property_id ON reviews (property_id);
CREATE INDEX idx_reviews_user_id ON reviews (user_id);


-- Table: messages
-- Facilitates communication between users.
CREATE TABLE messages (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Primary Key, UUID, automatically indexed
    sender_id UUID NOT NULL, -- Foreign Key to users table (sender)
    recipient_id UUID NOT NULL, -- Foreign Key to users table (recipient)
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key Constraint for sender_id
    CONSTRAINT fk_message_sender
        FOREIGN KEY (sender_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE, -- If a user (sender) is deleted, their sent messages are also deleted

    -- Foreign Key Constraint for recipient_id
    CONSTRAINT fk_message_recipient
        FOREIGN KEY (recipient_id)
        REFERENCES users (user_id)
        ON DELETE CASCADE -- If a user (recipient) is deleted, messages where they are the recipient are also deleted
);

-- Indexes for faster lookups by sender_id and recipient_id in messages
CREATE INDEX idx_messages_sender_id ON messages (sender_id);
CREATE INDEX idx_messages_recipient_id ON messages (recipient_id);
