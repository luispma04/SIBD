-- ========================================
-- SIBD 2025/2026 - Project Part 1
-- Boating Management System
-- Database Schema Definition
-- ========================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS navigates CASCADE;
DROP TABLE IF EXISTS Trip CASCADE;
DROP TABLE IF EXISTS valid_in CASCADE;
DROP TABLE IF EXISTS Certification CASCADE;
DROP TABLE IF EXISTS authorized CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS Senior CASCADE;
DROP TABLE IF EXISTS Junior CASCADE;
DROP TABLE IF EXISTS Sailor CASCADE;
DROP TABLE IF EXISTS Boat CASCADE;
DROP TABLE IF EXISTS Boat_Class CASCADE;
DROP TABLE IF EXISTS Location CASCADE;
DROP TABLE IF EXISTS Jurisdiction CASCADE;
DROP TABLE IF EXISTS Country CASCADE;

-- ========================================
-- COUNTRY
-- IC-1: Every country that registers a boat needs to have at least 1 location defined.
--  Constraint enforcement requires triggers or application logic - not implemented.
-- ========================================
CREATE TABLE Country (
    iso_code CHAR(3),
    name VARCHAR(70) UNIQUE NOT NULL,
    flag VARCHAR(2083) UNIQUE NOT NULL, --URL TYPE
    PRIMARY KEY(iso_code)
);

-- ========================================
-- JURISDICTION
-- ========================================
CREATE TABLE Jurisdiction (
    name VARCHAR(200),
    PRIMARY KEY(name)
);

-- ========================================
-- ADMINISTERS (Country 1 : M Jurisdiction)
-- Each jurisdiction is administered by at most one country.
-- M:1 association implemented using a separate table:
--   - jurisdiction_name is the PRIMARY KEY, so each jurisdiction
--     can appear only once (enforcing the 1-side of the M:1).
--   - iso_code may be NULL for International Waters.

-- IC-2: International Waters must have iso_code = NULL
--     All other jurisdictions must have a non-null iso_code
--  CHECK applied.

-- ========================================
CREATE TABLE administers (
    country_iso_code CHAR(3),
    jurisdiction_name VARCHAR(200),
    PRIMARY KEY(jurisdiction_name),
    FOREIGN KEY(jurisdiction_name) REFERENCES Jurisdiction(name),
    FOREIGN KEY(country_iso_code) REFERENCES Country(iso_code),
    CHECK (
        (jurisdiction_name = 'International Waters' AND country_iso_code IS NULL)
        OR (jurisdiction_name <> 'International Waters' AND country_iso_code IS NOT NULL)
    )
);

-- ========================================
-- LOCATION

-- IC-3: Any two Location points must be ≥ 1 nautical mile apart. 
--  Constraint enforcement requires triggers or application logic - not implemented.
-- ========================================
CREATE TABLE Location (
    latitude NUMERIC(8,6),
    longitude NUMERIC(9,6),
    name VARCHAR(200) NOT NULL,
    PRIMARY KEY(latitude, longitude)
);

-- ========================================
-- HAS_LOCATION (Country 1 : M Location)
-- Each location is administered by at most one country.
-- M:1 association implemented using a separate table:
--   - combination of latitude and longitude is the PRIMARY KEY, so each location
--     can appear only once (enforcing the 1-side of the M:1).
-- ========================================

CREATE TABLE has_location (
    country_iso_code CHAR(3),
    location_latitude NUMERIC(8,6),
    location_longitude NUMERIC(9,6),
    PRIMARY KEY(location_latitude, location_longitude),
    FOREIGN KEY(location_latitude, location_longitude) REFERENCES Location(latitude, longitude),
    FOREIGN KEY(country_iso_code) REFERENCES Country(iso_code)
);

-- ========================================
-- BOAT_CLASS

-- IC-4: max_length must be positive. 
--  CHECK applied.
-- ========================================
CREATE TABLE Boat_Class (
    name VARCHAR(200),
    max_length NUMERIC(6,2) NOT NULL CHECK (max_length > 0),
    PRIMARY KEY(name)
);

-- ========================================
-- BOAT

-- IC-5: Boat.length ≤ Boat_Class.max_length for it to be registered in that class. 
--  Constraint enforcement requires triggers or application logic - not implemented.
-- IC-6: length must be positive. 
--  CHECK applied.
-- ========================================
CREATE TABLE Boat (
    cni VARCHAR(50),
    country_iso_code CHAR(3),
    class_name VARCHAR(200) NOT NULL,
    name VARCHAR(200) NOT NULL,
    length NUMERIC(6,2) NOT NULL CHECK (length > 0),
    registration_year INTEGER NOT NULL,
    picture VARCHAR(2083) NOT NULL, --URL TYPE
    PRIMARY KEY(country_iso_code, cni),
    FOREIGN KEY (class_name) REFERENCES Boat_Class(name),
    FOREIGN KEY (country_iso_code) REFERENCES Country(iso_code)
);

-- ========================================
-- SAILOR

-- IC-7: No sailor can exist at the same time in the table 'junior' or in the table 'senior'
--  Constraint enforcement requires triggers or application logic - not implemented.
-- ========================================
CREATE TABLE Sailor (
    id SERIAL,
    first_name VARCHAR(40) NOT NULL,
    surname VARCHAR(40) NOT NULL,
    email VARCHAR(254) UNIQUE NOT NULL,
    PRIMARY KEY(id)
);

-- ========================================
-- SENIOR SAILOR (can be responsible for reservations)
-- ========================================
CREATE TABLE Senior (
    senior_id INTEGER,
    PRIMARY KEY(senior_id),
    FOREIGN KEY (senior_id) REFERENCES Sailor(id)
);

-- ========================================
-- JUNIOR SAILOR (no special capabilities)
-- ========================================
CREATE TABLE Junior (
    junior_id INTEGER,
    PRIMARY KEY(junior_id),
    FOREIGN KEY (junior_id) REFERENCES Sailor(id)
);

-- ========================================
-- RESERVATION

-- IC-8: end_date must be ≥ start_date. 
--  CHECK applied.
-- IC-9: For the same boat, reservations cannot overlap in time. 
--  Constraint enforcement requires triggers or application logic - not implemented.
-- IC-10: Every Reservation must exist in the table 'authorized'
--  Constraint enforcement requires triggers or application logic - not implemented.
-- ========================================
CREATE TABLE Reservation (
    country_iso_code CHAR(3),
    boat_cni VARCHAR(50),
    start_date DATE,
    end_date DATE,
    responsible_for_sailor_id INTEGER NOT NULL,
    PRIMARY KEY(country_iso_code, boat_cni, start_date, end_date),
    FOREIGN KEY (country_iso_code, boat_cni) REFERENCES Boat(country_iso_code, cni),
    FOREIGN KEY (responsible_for_sailor_id) REFERENCES Senior(senior_id),
    CHECK (end_date >= start_date) 
    -- Every Reservation must exist in the table 'authorized'
);

-- ========================================
-- AUTHORIZED (Reservation ↔ Sailor M:N)

-- Each reservation may authorize many sailors and each sailor may be authorized for many reservations.
-- M:N association implemented using a separate table:
--  - primary key is the combination of the Reservation PK (country_iso_code, boat_cni, start_date, end_date)
--    plus sailor_id, so each (reservation, sailor) pair appears at most once (enforcing uniqueness).
-- ========================================
CREATE TABLE authorized (
    country_iso_code CHAR(3),
    boat_cni VARCHAR(50),
    reservation_start_date DATE,
    reservation_end_date DATE,
    sailor_id INTEGER,
    PRIMARY KEY (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, sailor_id),
    FOREIGN KEY (country_iso_code, boat_cni, reservation_start_date, reservation_end_date) REFERENCES Reservation(country_iso_code, boat_cni, start_date, end_date),
    FOREIGN KEY (sailor_id) REFERENCES Sailor(id)
);

-- ========================================
-- TRIP

-- IC-11: Skipper must be among Reservation's authorized sailors.
--  Constraint enforcement requires triggers or application logic - not implemented.
-- IC-12: Skipper requires valid certificate for the boat class and trip jurisdictions valid at the time of the trip.
--  Constraint enforcement requires triggers or application logic - not implemented.
-- IC-13: arrival_date must be ≥ takeoff_date. 
--  CHECK applied.
-- IC-14: takeoff_date and arrival_date must lie within Reservation[start_date, end_date].
--  CHECK applied.
-- IC-15: For the same reservation, trips cannot overlap in time. 
--  Constraint enforcement requires triggers or application logic - not implemented.
-- IC-16: Every Trip must exist in the table 'navigates'
--  Constraint enforcement requires triggers or application logic - not implemented.
-- ========================================
CREATE TABLE Trip (
    country_iso_code CHAR(3),
    boat_cni VARCHAR(50),
    reservation_start_date DATE,
    reservation_end_date DATE,
    takeoff_date DATE,
    arrival_date DATE,
    insurance_reference VARCHAR(200) NOT NULL,
    starts_at_latitude NUMERIC(8,6) NOT NULL,
    starts_at_longitude NUMERIC(9,6) NOT NULL,
    ends_at_latitude NUMERIC(8,6) NOT NULL,
    ends_at_longitude NUMERIC(9,6) NOT NULL,
    skippers_id INTEGER NOT NULL,
    PRIMARY KEY(country_iso_code, boat_cni, reservation_start_date, reservation_end_date, takeoff_date, arrival_date),
    FOREIGN KEY (country_iso_code, boat_cni, reservation_start_date, reservation_end_date) REFERENCES Reservation(country_iso_code, boat_cni, start_date, end_date),
    FOREIGN KEY (skippers_id) REFERENCES Sailor(id),
    FOREIGN KEY (starts_at_latitude, starts_at_longitude) REFERENCES Location(latitude, longitude),
    FOREIGN KEY (ends_at_latitude, ends_at_longitude) REFERENCES Location(latitude, longitude),
    CHECK (arrival_date >= takeoff_date),
    CHECK (takeoff_date >= reservation_start_date AND arrival_date <= reservation_end_date)
    -- Every Trip must exist in the table 'navigates'
);

-- ========================================
-- NAVIGATES (Trip ↔ Jurisdiction M:N, ordered)

-- Stores the ordered list of jurisdictions a Trip passes through.
-- M:N association implemented using a separate table:
-- - primary key is the Trip PK (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, trip_takeoff_date, trip_arrival_date)
--   plus jurisdiction_sequence_order, which enforces a strict ordering and allows the same jurisdiction to appear multiple times
--   at different sequence positions.

-- IC-17: jurisdiction_sequence_order must be positive. 
--  CHECK applied.
-- ========================================
CREATE TABLE navigates (
    country_iso_code CHAR(3),
    boat_cni VARCHAR(50),
    reservation_start_date DATE,
    reservation_end_date DATE,
    trip_takeoff_date DATE,
    trip_arrival_date DATE,
    jurisdiction_name VARCHAR(200),
    jurisdiction_sequence_order INTEGER NOT NULL,
    PRIMARY KEY (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, trip_takeoff_date, trip_arrival_date, jurisdiction_sequence_order),
    FOREIGN KEY (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, trip_takeoff_date, trip_arrival_date) REFERENCES Trip(country_iso_code, boat_cni, reservation_start_date, reservation_end_date, takeoff_date, arrival_date),
    FOREIGN KEY (jurisdiction_name) REFERENCES Jurisdiction(name),
    CHECK (jurisdiction_sequence_order > 0)
);

-- ========================================
-- CERTIFICATION

-- IC-18: Every Certification must exist in the table 'valid_in' and table 'certifies_for'.
--  Constraint enforcement requires triggers or application logic - not implemented.
-- IC-19: expiry_date must be after issue_date.
--  CHECK applied.
-- ========================================
CREATE TABLE Certification (
    sailor_id INTEGER,
    issue_date DATE,
    expiry_date DATE NOT NULL,
    PRIMARY KEY(sailor_id,issue_date),
    FOREIGN KEY (sailor_id) REFERENCES Sailor(id),
    CHECK (expiry_date > issue_date) 
    -- Every Certification must exist in the table 'valid_in' and table 'certifies_for'
);

-- ========================================
-- VALID_IN (Certification ↔ Jurisdiction M:N)

-- Records which jurisdictions (countries) a Certification is valid in.
-- M:N association implemented using a separate table:
-- - primary key combines the Certification PK (sailor_id, issue_date) and name (jurisdiction),
--   so each (certification, jurisdiction) pair appears at most once.
-- ========================================
CREATE TABLE valid_in (
    sailor_id INTEGER,
    certification_issue_date DATE,
    jurisdiction_name VARCHAR(200),
    PRIMARY KEY (sailor_id, certification_issue_date, jurisdiction_name),
    FOREIGN KEY (sailor_id, certification_issue_date) REFERENCES Certification(sailor_id, issue_date),
    FOREIGN KEY (jurisdiction_name) REFERENCES Jurisdiction(name)
);

-- ========================================
-- CERTIFIES_FOR (Certification ↔ Boat_Class M:N)

-- Records which boat classes a Certification covers.
-- M:N association implemented using a separate table:
-- - primary key combines the Certification PK (sailor_id, issue_date) and Boat_Class (class_name),
--   so each (certification, boat class) pair appears at most once.
-- ========================================
CREATE TABLE certifies_for (
    sailor_id INTEGER,
    certification_issue_date DATE,
    class_name VARCHAR(200),
    PRIMARY KEY(sailor_id, certification_issue_date, class_name),
    FOREIGN KEY (sailor_id, certification_issue_date) REFERENCES Certification(sailor_id, issue_date),
    FOREIGN KEY(class_name) REFERENCES Boat_Class(name)
);


