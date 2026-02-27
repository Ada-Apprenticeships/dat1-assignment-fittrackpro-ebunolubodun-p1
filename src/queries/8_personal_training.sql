.open fittrackpro.db
.mode column

-- 8.1 
SELECT pts.session_id, CONCAT(m.first_name, ' ', m.last_name) AS member_name, pts.session_date, pts.start_time, pts.end_time
FROM personal_training_sessions pts
JOIN members m
    ON pts.member_id = m.member_id
WHERE pts.staff_id = 2;

