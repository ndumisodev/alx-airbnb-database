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

