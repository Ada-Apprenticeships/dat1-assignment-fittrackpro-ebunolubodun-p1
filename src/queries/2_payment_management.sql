.open fittrackpro.db
.mode column

-- 2.1 
INSERT INTO payments (amount,payment_date,payment_method,payment_type, member_id) VALUES
(50.00,  DATETIME('now'),  'Credit Card'   ,'Monthly membership fee', 11);

-- 2.2 
SELECT STRFTIME('%Y-%m', payment_date) AS month, SUM(amount) AS total_revenue
FROM payments
WHERE payment_type = 'Monthly membership fee' AND payment_date BETWEEN '2024-11-01' AND '2025-01-31'
GROUP BY month;

-- 2.3 
SELECT payment_id, amount, payment_date, payment_method
FROM payments
WHERE payment_type = 'Day pass';
