.open fittrackpro.db
.mode column

-- 5.1 
SELECT m.member_id, m.first_name, m.last_name, type AS membership_type, m.join_date
FROM members m
JOIN memberships ms
    ON m.member_id = ms.member_id
WHERE status = 'Active';

-- 5.2 
SELECT type AS membership_type, ROUND(AVG(total_time), 2) AS avg_visit_duration_minutes
FROM (
    SELECT m.type, (julianday(check_out_time) - julianday(check_in_time)) * 1440 AS total_time
    FROM attendance a
    JOIN memberships m
        ON a.member_id = m.member_id
)
GROUP BY type;

-- 5.3 
SELECT m.member_id, m.first_name, m.last_name, m.email, ms.end_date
FROM members m 
JOIN memberships ms
    ON m.member_id = ms.member_id
WHERE strftime('%Y', end_date) = '2025'
