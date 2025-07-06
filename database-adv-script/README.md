## Task 0: Write Complex Queries with Joins

### Objective
Master SQL joins by writing and executing complex queries across the Airbnb clone schema.

### Queries Included

1. **INNER JOIN**  
   Retrieves all bookings along with the details of the users who made the bookings.

2. **LEFT JOIN**  
   Lists all properties and their reviews, including properties that have not been reviewed.

3. **FULL OUTER JOIN**  
   Returns all users and bookings, even if a user hasn't made any bookings or if a booking isn’t associated with a user.

### File
- All SQL queries are stored in `database-adv-script/joins_queries.sql`


## Task 1: Practice Subqueries

### Objective
Write both correlated and non-correlated subqueries to solve analytical tasks.

### ✅ Queries Included

1. **Non-Correlated Subquery**
   - Finds all properties with an average rating greater than 4.0.
   - Uses a subquery that groups and filters property ratings independently of the outer query.

2. **Correlated Subquery**
   - Finds all users who have made more than 3 bookings.
   - Uses a subquery that counts bookings for each user individually (correlated with each outer row).

### File
- SQL queries are stored in: `database-adv-script/subqueries.sql`




## Task 2: Apply Aggregations and Window Functions

### Objective
Analyze data using SQL aggregate functions and window functions.

### ✅ Queries Included

1. **Aggregate Function – COUNT with GROUP BY**
   - Calculates the total number of bookings made by each user.
   - Uses a LEFT JOIN to include users with zero bookings.

2. **Window Function – RANK**
   - Ranks all properties based on how many bookings each has received.
   - Uses a subquery to calculate booking totals before applying RANK.

### File
- SQL queries are stored in: `database-adv-script/aggregations_and_window_functions.sql`

