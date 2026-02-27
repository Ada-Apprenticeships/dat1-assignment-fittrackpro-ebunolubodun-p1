.open fittrackpro.db
.mode column

-- 7.1 
SELECT staff_id, first_name, last_name, position AS role
FROM staff

-- 7.2 
SELECT s.staff_id AS trainer_id, CONCAT(s.first_name, ' ', s.last_name) AS trainer_name, COUNT(*) AS session_count
FROM staff s
JOIN personal_training_sessions pts
    ON s.staff_id = pts.staff_id
WHERE pts.session_date >= '2025-01-20' AND pts.session_date <= DATE('2025-01-20', '+30 days')
GROUP BY s.staff_id

