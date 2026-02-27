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
    location_id   INTEGER PRIMARY KEY NOT NULL,
    name          VARCHAR,
    address       VARCHAR,
    phone_number  VARCHAR CHECK (length(phone_number) BETWEEN 12 AND 13),
    email         VARCHAR,  
    opening_hours VARCHAR
);

CREATE TABLE members (
    member_id               INTEGER PRIMARY KEY NOT NULL,
    first_name              VARCHAR,
    last_name               VARCHAR,
    email                   VARCHAR,
    phone_number            VARCHAR CHECK (length(phone_number) = 12),
    date_of_birth           DATE CHECK (date_of_birth GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    join_date               DATE CHECK (date_of_birth GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    emergency_contact_name  VARCHAR,
    emergency_contact_phone VARCHAR
);

CREATE TABLE staff (
    staff_id     INTEGER PRIMARY KEY NOT NULL,
    first_name   VARCHAR,
    last_name    VARCHAR,
    email        VARCHAR,
    phone_number VARCHAR CHECK(length(phone_number) = 12),  
    position     VARCHAR,
    hire_date    DATE CHECK (hire_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    location_id  INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE equipment (
    equipment_id          INTEGER PRIMARY KEY NOT NULL,
    name                  VARCHAR,
    type                  VARCHAR,
    purchase_date         DATE CHECK (purchase_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    last_maintenance_date DATE CHECK (last_maintenance_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    next_maintenance_date DATE CHECK (next_maintenance_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    location_id           INTEGER,  
    FOREIGN KEY (location_id) REFERENCES locations(location_id)    
);

CREATE TABLE classes (
    class_id    INTEGER PRIMARY KEY NOT NULL,
    name        VARCHAR,
    description VARCHAR,
    capacity    INTEGER,
    duration    INTEGER,
    location_id INTEGER,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE class_schedule (
    schedule_id INTEGER PRIMARY KEY NOT NULL,
    start_time  DATETIME CHECK (start_time GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]'),
    end_time    DATETIME CHECK (end_time GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]'),
    class_id    INTEGER,
    staff_id    INTEGER,
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE memberships (
    membership_id INTEGER PRIMARY KEY NOT NULL,
    type          VARCHAR,
    start_date    DATE CHECK (start_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    end_date      DATE CHECK (end_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    status        VARCHAR,
    member_id     INTEGER,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE attendance (
    attendance_id  INTEGER PRIMARY KEY NOT NULL,
    check_in_time  DATETIME CHECK (check_in_time GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]'),
    check_out_time DATETIME CHECK (check_out_time GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]'),
    member_id      INTEGER,
    location_id    INTEGER,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

CREATE TABLE class_attendance (
    class_attendance_id INTEGER PRIMARY KEY NOT NULL,
    attendance_status   VARCHAR,
    schedule_id         INTEGER,
    member_id           INTEGER,
    FOREIGN KEY (schedule_id) REFERENCES class_schedule(schedule_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE payments (
    payment_id     INTEGER PRIMARY KEY NOT NULL,
    amount         REAL,
    payment_date   DATETIME CHECK (payment_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]'),
    payment_method VARCHAR,
    payment_type   VARCHAR,
    member_id      INTEGER,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE personal_training_sessions (
    session_id   INTEGER PRIMARY KEY NOT NULL,
    session_date DATE CHECK (session_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    start_time   TIME CHECK (start_time GLOB '[0-2][0-9]:[0-5][0-9]:[0-5][0-9]'),
    end_time     TIME CHECK (end_time GLOB '[0-2][0-9]:[0-5][0-9]:[0-5][0-9]'),
    notes        VARCHAR,
    member_id    INTEGER,
    staff_id     INTEGER,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)

);

CREATE TABLE member_health_metrics (
    metric_id           INTEGER PRIMARY KEY NOT NULL,
    measurement_date    DATE CHECK (measurement_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    weight              REAL,
    body_fat_percentage REAL,
    muscle_mass         REAL,
    bmi                 REAL,
    member_id           INTEGER,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE equipment_maintenance_log (
    log_id           INTEGER PRIMARY KEY NOT NULL,
    maintenance_date DATE CHECK (maintenance_date GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]'),
    description      VARCHAR,
    staff_id         INTEGER,
    equipment_id     INTEGER,
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);