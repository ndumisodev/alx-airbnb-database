# Sample Data: Airbnb Clone

This directory contains SQL scripts used to seed the Airbnb Clone database with sample data for development and testing purposes.

## ✅ Objective

Populate all major entities (Users, Properties, Bookings, Payments, Reviews, Messages) with realistic, interrelated data.

## 📂 Files

- `seed.sql`: SQL script that inserts sample data into the database tables in the correct dependency order.
- `README.md`: Explains the purpose and usage of the seed data script.

## 🧪 Sample Data Overview

### Users
Includes multiple users with roles such as:
- `guest`: Can book properties and leave reviews.
- `host`: Can list properties and receive bookings.
- `admin`: Reserved for management tasks (not used directly in sample data).

### Properties
Each property is owned by a host. Properties include:
- Title, description, location, and nightly price.

### Bookings
Bookings simulate actual reservations by guests, each referencing:
- A guest (user)
- A property
- Start and end dates
- Booking status (`pending`, `confirmed`, or `canceled`)

### Payments
Each payment is tied to a confirmed booking and includes:
- Payment method (`credit_card`, `paypal`, `stripe`)
- Amount and timestamp

### Reviews
Guest reviews for properties include:
- Rating (1 to 5 stars)
- A comment
- Review date

### Messages
Messages simulate user-to-user communication:
- Sender and recipient IDs
- Text content
- Timestamp

## ⚙️ Usage

You can populate the database by running the seed script in your PostgreSQL database:

```bash
psql -U your_user -d your_database -f seed.sql
