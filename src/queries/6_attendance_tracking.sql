.open fittrackpro.db
.mode column

-- 6.1 
INSERT INTO attendance (check_in_time, member_id, location_id) VALUES
('2025-02-14 16:30:00', 7, 1);

--6.2 
-- Extracting the date component to separate visit day from the exact timestamp
SELECT DATE(check_in_time) AS visit_date, check_in_time, check_out_time
FROM attendance
WHERE member_id = '5';

-- 6.3 
SELECT day_of_week, visit_count 
FROM ( 
    -- Converting numeric weekday values into readable day names for clearer reporting output
    SELECT CASE strftime('%w', check_in_time)
        WHEN '0' THEN 'Sunday'
        WHEN '1' THEN 'Monday'
        WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday'
        WHEN '4' THEN 'Thursday'
        WHEN '5' THEN 'Friday'
        WHEN '6' THEN 'Saturday'
    END AS day_of_week,
    COUNT(*) AS visit_count
    FROM attendance
    GROUP BY day_of_week
) 
ORDER BY visit_count DESC
LIMIT 1;

-- 6.4 
SELECT l.name AS location_name, 
    ROUND(
        -- Forcing floating-point division to prevent integer truncation in average calculation
        COUNT(a.attendance_id) * 1.0 / (
            julianday(MAX(a.check_in_time)) - julianday(MIN(a.check_in_time)) + 1),2
    ) AS avg_daily_attendance
FROM locations l
-- Using LEFT JOIN to ensure locations with no attendance records are still included in the results
LEFT JOIN attendance a
    ON l.location_id = a.location_id
GROUP BY l.location_id;



