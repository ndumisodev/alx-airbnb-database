# Database Schema: Airbnb Clone

This directory contains the SQL definition of the Airbnb Clone database schema.

## ✅ Objective

Define all entities and relationships using SQL DDL (Data Definition Language) to match the previously specified and normalized schema.

## 📂 Files

- `schema.sql`: Contains `CREATE TABLE` statements with appropriate constraints, foreign keys, and indexes.
- `README.md`: Explains the structure and contents of the schema.

## 🧱 Schema Overview

Entities:
- `users`: Stores user details including role.
- `properties`: Listings created by hosts.
- `bookings`: Reservation records for guests and properties.
- `payments`: Payment tracking for bookings.
- `reviews`: Guest reviews for properties.
- `messages`: Direct communication between users.

## 🔐 Constraints & Indexes

- UUIDs are used as primary keys.
- `email` is unique and indexed for fast lookup.
- ENUM-like behavior is simulated using `CHECK` constraints (e.g., `role`, `status`, `payment_method`).
- Foreign keys with `ON DELETE CASCADE` ensure referential integrity and simplify cleanup.
- Indexes are created on high-usage columns (`user_id`, `property_id`, `email`, etc.) to optimize performance.

## ⚙️ Usage

You can run the script using any PostgreSQL-compatible interface:

```bash
psql -U your_user -d your_database -f schema.sql
