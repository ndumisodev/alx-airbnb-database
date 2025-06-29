# Entity Relationship Diagram (ERD) for Airbnb Clone

This ERD models the database structure for the Airbnb Clone project. It includes the following entities:

- User
- Property
- Booking
- Payment
- Review
- Message

Each entity includes relevant fields and constraints, such as UUID primary keys, foreign key relationships, and ENUM constraints.

## 🔗 View the Live Diagram

You can view the full interactive ER diagram here:
👉 [Click to view the ERD on dbdiagram.io][https://dbdiagram.io/d/your-diagram-id-here](https://dbdiagram.io/d/685d5d05f413ba35080b2f2c)

> 💡 Tip: Right-click the link or use Ctrl+Click (or Cmd+Click on Mac) to open it in a new tab.

> ℹ️ The interactive diagram includes tooltips showing field-level constraints like `unique`, `not null`, and `default`. These details may not appear in the exported image or PDF.


## 📎 Diagram Preview

![ER Diagram Preview](./first-erd-preview.png)


## 🧩 Entities and Relationships Overview

This ERD includes the following entities:

- **User**: Represents guests, hosts, or admins. Uniquely identified by `user_id`. Hosts own properties. Guests make bookings and leave reviews.
- **Property**: Listings created by hosts. Each property is tied to a host via `host_id`.
- **Booking**: Represents a reservation made by a guest for a specific property. Includes `start_date`, `end_date`, and `status`.
- **Payment**: Linked to a booking and records payment details such as `amount`, `method`, and `payment_date`.
- **Review**: Submitted by a user for a property, including a rating and comment. Each review is tied to a user and a property.
- **Message**: Represents messages exchanged between users (e.g., guest ↔ host). Includes sender and recipient IDs.

### 🔗 Relationships Summary

| Relationship                       | Type         | Description                                  |
|-----------------------------------|--------------|----------------------------------------------|
| `User` 1 ──< `Property`           | One-to-Many  | One host can list many properties            |
| `User` 1 ──< `Booking`           | One-to-Many  | One guest can make many bookings             |
| `Property` 1 ──< `Booking`       | One-to-Many  | A property can have many bookings            |
| `Booking` 1 ──1 `Payment`        | One-to-One   | Each booking has one payment                 |
| `User` 1 ──< `Review`            | One-to-Many  | One user can write multiple reviews          |
| `Property` 1 ──< `Review`        | One-to-Many  | One property can have multiple reviews       |
| `User` 1 ──< `Message` (Sender)  | One-to-Many  | One user can send many messages              |
| `User` 1 ──< `Message` (Receiver)| One-to-Many  | One user can receive many messages           |


---

# 📐 Database Normalization: Airbnb Clone (3NF)

This document explains the normalization process applied to the Airbnb clone database design, aiming to achieve the **Third Normal Form (3NF)**.  
Normalization is a systematic process of organizing the columns and tables of a relational database to minimize **data redundancy** and improve **data integrity**.

---

## 🔍 Normalization Principles Review

We will review the database schema against the **first three normal forms**:

---

### ✅ First Normal Form (1NF)

A table is in **1NF** if:
- Each column contains **atomic (indivisible)** values.
- There are **no repeating groups** of columns.
- Each row is **unique**, identified by a **primary key**.

**Review of Current Schema**:
All tables in the provided DBML schema (`users`, `properties`, `bookings`, `payments`, `reviews`, `messages`) **adhere to 1NF**:
- All attributes are **atomic**.
- There are no repeating columns or multi-value fields.
- Each table has a clearly defined **UUID primary key**.

**Conclusion**: The database design satisfies **1NF**.

---

### ✅ Second Normal Form (2NF)

A table is in **2NF** if:
- It is already in **1NF**.
- All **non-key attributes** are **fully functionally dependent** on the **entire primary key**.

**Review of Current Schema**:
- All tables use **single-attribute primary keys**.
- There are **no composite primary keys**, and thus no risk of partial dependencies.

**Conclusion**: The database design satisfies **2NF**.

---

### ✅ Third Normal Form (3NF)

A table is in 3NF if:

- It is in 2NF.  
- There are no transitive dependencies. A transitive dependency occurs when a non-key attribute is functionally dependent on another non-key attribute (which is, in turn, dependent on the primary key). In simple terms, no non-key attribute should determine the value of another non-key attribute.

**Review of Current Schema**:  
We examine each table for any transitive dependencies:

**users Table**:
- `user_id` (PK) determines `first_name`, `last_name`, `email`, `password_hash`, `phone_number`, `role`, `created_at`.  
- No non-key attribute determines another non-key attribute.  
**Status: 3NF Compliant.**

**properties Table**:
- `property_id` (PK) determines `host_id`, `name`, `description`, `location`, `pricepernight`, `created_at`, `updated_at`.  
- `host_id` is a foreign key but does not introduce a transitive dependency.  
**Status: 3NF Compliant.**

**bookings Table**:
- `booking_id` (PK) determines `property_id`, `user_id`, `start_date`, `end_date`, `total_price`, `status`, `created_at`.  
- All non-key attributes are directly dependent on `booking_id`.  
**Status: 3NF Compliant.**

**payments Table**:
- `payment_id` (PK) determines `booking_id`, `amount`, `payment_date`, `payment_method`.  
- All non-key attributes are directly dependent on `payment_id`.  
**Status: 3NF Compliant.**

**reviews Table**:
- `review_id` (PK) determines `property_id`, `user_id`, `rating`, `comment`, `created_at`.  
- All non-key attributes are directly dependent on `review_id`.  
**Status: 3NF Compliant.**

**messages Table**:
- `message_id` (PK) determines `sender_id`, `recipient_id`, `message_body`, `sent_at`.  
- All non-key attributes are directly dependent on `message_id`.  
**Status: 3NF Compliant.**

---

## 🛠️ Normalization Steps Taken

Upon reviewing the provided DBML schema, it is evident that the database design already adheres to the **Third Normal Form (3NF)**.  
Therefore, no decomposition steps were required. The design is well-structured, minimizing redundancy and promoting data integrity.

This implies that the initial design was carefully crafted, considering the principles of normalization from the outset.

---

## ✅ Final Verdict

The Airbnb Clone database design meets all requirements for **Third Normal Form (3NF)**.  
It is optimized for consistency, clarity, and efficient querying — ready for implementation in a relational database system.

---

## 🧹 Final Assessment

| Table       | 1NF | 2NF | 3NF |
|-------------|-----|-----|-----|
| `users`     | ✅  | ✅  | ✅  |
| `properties`| ✅  | ✅  | ✅  |
| `bookings`  | ✅  | ✅  | ✅  |
| `payments`  | ✅  | ✅  | ✅  |
| `reviews`   | ✅  | ✅  | ✅  |
| `messages`  | ✅  | ✅  | ✅  |

---

## 📝 Conclusion

The current database schema satisfies the requirements of **Third Normal Form (3NF)**. It is free of:
- Repeating groups (1NF)
- Partial dependencies (2NF)
- Transitive dependencies (3NF)

This design supports scalability, efficiency, and data integrity across the platform.


## 📄 DBML Code

If you’d like to review the raw DBML schema:

<details>
<summary>Click to expand</summary>

// Airbnb Clone Database Design in DBML

Table users {
  user_id UUID [primary key]
  first_name VARCHAR [not null]
  last_name VARCHAR [not null]
  email VARCHAR [unique, not null, note: 'Must be unique']
  password_hash VARCHAR [not null]
  phone_number VARCHAR
  role VARCHAR [not null, note: 'ENUM (guest, host, admin)']
  created_at TIMESTAMP [default: `CURRENT_TIMESTAMP`]
}

Table properties {
  property_id UUID [primary key]
  host_id UUID [not null]
  name VARCHAR [not null]
  description TEXT [not null]
  location VARCHAR [not null]
  pricepernight DECIMAL [not null]
  created_at TIMESTAMP [default: `CURRENT_TIMESTAMP`]
  updated_at TIMESTAMP [note: 'ON UPDATE CURRENT_TIMESTAMP']
}

Table bookings {
  booking_id UUID [primary key]
  property_id UUID [not null]
  user_id UUID [not null]
  start_date DATE [not null]
  end_date DATE [not null]
  total_price DECIMAL [not null]
  status VARCHAR [not null, note: 'ENUM (pending, confirmed, canceled)']
  created_at TIMESTAMP [default: `CURRENT_TIMESTAMP`]
}

Table payments {
  payment_id UUID [primary key]
  booking_id UUID [not null]
  amount DECIMAL [not null]
  payment_date TIMESTAMP [default: `CURRENT_TIMESTAMP`]
  payment_method VARCHAR [not null, note: 'ENUM (credit_card, paypal, stripe)']
}

Table reviews {
  review_id UUID [primary key]
  property_id UUID [not null]
  user_id UUID [not null]
  rating INTEGER [not null, note: 'CHECK rating BETWEEN 1 AND 5']
  comment TEXT [not null]
  created_at TIMESTAMP [default: `CURRENT_TIMESTAMP`]
}

Table messages {
  message_id UUID [primary key]
  sender_id UUID [not null]
  recipient_id UUID [not null]
  message_body TEXT [not null]
  sent_at TIMESTAMP [default: `CURRENT_TIMESTAMP`]
}

// Foreign Key Relationships
Ref: properties.host_id > users.user_id
Ref: bookings.user_id > users.user_id
Ref: bookings.property_id > properties.property_id
Ref: payments.booking_id > bookings.booking_id
Ref: reviews.user_id > users.user_id
Ref: reviews.property_id > properties.property_id
Ref: messages.sender_id > users.user_id
Ref: messages.recipient_id > users.user_id

