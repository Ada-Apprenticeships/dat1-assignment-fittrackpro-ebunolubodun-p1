.open fittrackpro.db
.mode column

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS class_attendance;
DROP TABLE IF EXISTS equipment_maintenance_log;
DROP TABLE IF EXISTS personal_training_sessions;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS member_health_metrics;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS memberships;
DROP TABLE IF EXISTS class_schedule;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS locations;


CREATE TABLE locations (
    location_id   INTEGER PRIMARY KEY,
    name          VARCHAR NOT NULL,
    address       VARCHAR NOT NULL,
    -- Not UNIQUE: locations may share contact details
    phone_number  VARCHAR NOT NULL CHECK (length(phone_number) BETWEEN 12 AND 13),
    email         VARCHAR NOT NULL,  
    opening_hours VARCHAR NOT NULL
);

CREATE TABLE members (
    member_id               INTEGER PRIMARY KEY,
    first_name              VARCHAR NOT NULL,
    last_name               VARCHAR NOT NULL,
    email                   VARCHAR NOT NULL,
    phone_number            VARCHAR NOT NULL CHECK (length(phone_number) = 12),
    date_of_birth           DATE NOT NULL CHECK (DATE(date_of_birth) IS NOT NULL),
    -- Ensures date format validation in SQLite (which does not enforce DATE type strictly)
    join_date               DATE NOT NULL
                            CHECK (
                                DATE(join_date) IS NOT NULL 
                                AND DATE(join_date) > DATE(date_of_birth)
                            ),
    -- Emergency contact defaults to 'Unknown' to avoid NULL handling in reporting
    emergency_contact_name  VARCHAR NOT NULL DEFAULT 'Unknown',
    emergency_contact_phone VARCHAR NOT NULL DEFAULT 'Unknown'
);

CREATE TABLE staff (
    staff_id     INTEGER PRIMARY KEY,
    first_name   VARCHAR NOT NULL,
    last_name    VARCHAR NOT NULL,
    email        VARCHAR NOT NULL,
    phone_number VARCHAR NOT NULL CHECK(length(phone_number) = 12),  
    position     VARCHAR NOT NULL CHECK (position IN ('Trainer', 'Manager', 'Receptionist', 'Maintenance')),
    hire_date    DATE NOT NULL CHECK (DATE(hire_date) IS NOT NULL),
    -- Staff may exist before being assigned to a specific location
    location_id  INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE equipment (
    equipment_id          INTEGER PRIMARY KEY,
    name                  VARCHAR NOT NULL,
    type                  VARCHAR NOT NULL CHECK (type IN ('Cardio', 'Strength')),
    purchase_date         DATE NOT NULL CHECK (DATE(purchase_date) IS NOT NULL),
    last_maintenance_date DATE NOT NULL CHECK (DATE(last_maintenance_date) IS NOT NULL),
    next_maintenance_date DATE NOT NULL CHECK (
                            DATE(next_maintenance_date) IS NOT NULL
                            -- Ensures maintenance schedule is forward-moving
                            AND DATE (last_maintenance_date) <= DATE(next_maintenance_date)
                            ),
    location_id           INTEGER NOT NULL,  
    FOREIGN KEY (location_id) REFERENCES locations(location_id)    
);

CREATE TABLE classes (
    class_id    INTEGER PRIMARY KEY,
    name        VARCHAR NOT NULL,
    description VARCHAR NOT NULL,
    capacity    INTEGER NOT NULL,
    duration    INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE class_schedule (
    schedule_id INTEGER PRIMARY KEY,
    start_time  DATETIME NOT NULL CHECK (DATETIME(start_time) IS NOT NULL),
    end_time    DATETIME NOT NULL CHECK (DATETIME(end_time) IS NOT NULL AND (DATETIME(end_time) > DATETIME(start_time))),
    class_id    INTEGER NOT NULL,
    staff_id    INTEGER NOT NULL,
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE memberships (
    membership_id INTEGER PRIMARY KEY,
    type          VARCHAR NOT NULL,
    start_date    DATE NOT NULL CHECK (DATE(start_date) IS NOT NULL),
    end_date      DATE NOT NULL CHECK (DATE(end_date) IS NOT NULL),
    status        VARCHAR NOT NULL CHECK (status IN ('Active', 'Inactive')),
    member_id     INTEGER NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE attendance (
    attendance_id  INTEGER PRIMARY KEY,
    check_in_time  DATETIME NOT NULL CHECK (DATETIME(check_in_time) IS NOT NULL),
    check_out_time DATETIME
                   CHECK (
                        check_out_time IS NULL 
                        OR DATETIME(check_out_time) IS NOT NULL
                    ),
    member_id      INTEGER NOT NULL,
    location_id    INTEGER NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE class_attendance (
    class_attendance_id INTEGER PRIMARY KEY,
    attendance_status   VARCHAR NOT NULL CHECK (attendance_status IN ('Registered', 'Attended', 'Unattended')),
    schedule_id         INTEGER NOT NULL,
    member_id           INTEGER NOT NULL,
    FOREIGN KEY (schedule_id) REFERENCES class_schedule(schedule_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE payments (
    payment_id     INTEGER PRIMARY KEY,
    amount         REAL NOT NULL CHECK (amount > 0),
    payment_date   DATETIME NOT NULL CHECK (DATETIME(payment_date) IS NOT NULL),
    payment_method VARCHAR NOT NULL CHECK (payment_method IN ('Credit Card', 'Bank Transfer', 'PayPal', 'Cash')),
    payment_type   VARCHAR NOT NULL CHECK (payment_type IN ('Monthly membership fee', 'Day pass')),
    member_id      INTEGER NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE personal_training_sessions (
    session_id   INTEGER PRIMARY KEY,
    session_date DATE NOT NULL CHECK (DATE(session_date) IS NOT NULL),
    start_time   TIME NOT NULL CHECK (TIME(start_time) IS NOT NULL),
    end_time     TIME NOT NULL CHECK (TIME(end_time) IS NOT NULL),
    notes        VARCHAR NOT NULL DEFAULT 'No Notes',
    member_id    INTEGER NOT NULL,
    staff_id     INTEGER NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE member_health_metrics (
    metric_id           INTEGER PRIMARY KEY,
    measurement_date    DATE NOT NULL CHECK (DATE(measurement_date) IS NOT NULL),
    weight              REAL NOT NULL,
    body_fat_percentage REAL NOT NULL,
    muscle_mass         REAL NOT NULL,
    bmi                 REAL NOT NULL,
    member_id           INTEGER NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE equipment_maintenance_log (
    log_id           INTEGER PRIMARY KEY,
    maintenance_date DATE NOT NULL CHECK (DATE(maintenance_date) IS NOT NULL),
    description      VARCHAR NOT NULL,
    staff_id         INTEGER NOT NULL,
    equipment_id     INTEGER NOT NULL,
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);