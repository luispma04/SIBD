-- ========================================
-- SIBD 2025/2026 - Project Part 1
-- Boating Management System
-- Database Schema Definition
-- ========================================

/* ========================================
   INTEGRITY CONSTRAINTS (ICs) - Summary
   ========================================
   IC-1: Boat.length ≤ Boat_Class.max_length — cross-table rule (enforcement deferred to trigger or application). Ensure sample data respects this.
   IC-2: Any two Location points must be ≥ 1 nautical mile apart — geospatial rule (use PostGIS or trigger). Sample coordinates adjusted.
   IC-3: Trip.skipper must be among Reservation's authorized sailors (Reservation → authorized Sailors). Enforcement deferred.
   IC-4: Skipper requires valid certificate for the boat class and trip jurisdictions (issue_date ≤ takeoff_date ≤ expiry_date and certificate valid for jurisdiction). Enforcement deferred.
   IC-5: Trip.takeoff/arrival must lie within Reservation[start_date, end_date]. Simple per-table checks: reservation.end_date >= reservation.start_date and trip.arrival_date >= trip.takeoff_date; full containment enforcement is deferred.
   ======================================== */

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
--   - jurisdiction_id is the PRIMARY KEY, so each jurisdiction
--     can appear only once (enforcing the 1-side of the M:1).
--   - iso_code may be NULL for International Waters.
-- ========================================
CREATE TABLE administers (
    iso_code CHAR(3),
    name VARCHAR(200),
    PRIMARY KEY(name),
    FOREIGN KEY(name) REFERENCES Jurisdiction(name),
    FOREIGN KEY(iso_code) REFERENCES Country(iso_code)
);
-- CHECK (iso_code IS NOT NULL OR name = 'International Waters')
-- IC: International Waters must have iso_code = NULL
-- IC: All other jurisdictions must have a non-null iso_code

-- ========================================
-- LOCATION
-- IC-2: Any two Location points must be ≥ 1 nautical mile apart — geospatial rule (use PostGIS or trigger). Sample coordinates adjusted.
-- ========================================
CREATE TABLE Location (
    latitude NUMERIC(8,6),
    longitude NUMERIC(9,6),
    name VARCHAR(200) NOT NULL,
    iso_code CHAR(3),
    PRIMARY KEY(latitude, longitude),
    FOREIGN KEY (iso_code) REFERENCES Country(iso_code)
);

-- ========================================
-- BOAT_CLASS
-- IC-1: Boat.length ≤ Boat_Class.max_length — cross-table rule (enforcement deferred to trigger or application).
-- ========================================
CREATE TABLE Boat_Class (
    class_name VARCHAR(200),
    max_length NUMERIC(6,2) NOT NULL CHECK (max_length > 0),
    PRIMARY KEY(class_name)
);

-- ========================================
-- BOAT
-- IC-1: Boat.length ≤ Boat_Class.max_length — cross-table rule (enforcement deferred to trigger or application). Ensure sample data respects this.
-- ========================================
CREATE TABLE Boat (
    iso_code CHAR(3),
    cni VARCHAR(50),
    name VARCHAR(200) NOT NULL,
    length NUMERIC(6,2) NOT NULL CHECK (length > 0),
    registration_year INTEGER NOT NULL,
    picture VARCHAR(2083) NOT NULL, --URL TYPE
    belongs_to_max_length NUMERIC(6,2) NOT NULL,
    PRIMARY KEY(iso_code, cni),
    FOREIGN KEY (belongs_to_max_length) REFERENCES Boat_Class(max_length),
    FOREIGN KEY (iso_code) REFERENCES Country(iso_code)
);

-- ========================================
-- SAILOR (Supertype)
-- ========================================
CREATE TABLE Sailor (
    sailor_id SERIAL,
    first_name VARCHAR(40) NOT NULL,
    surname VARCHAR(40) NOT NULL,
    email VARCHAR(254) UNIQUE NOT NULL,
    PRIMARY KEY(sailor_id)
    
    -- No sailor can exist at the same time in
    -- the both the table 'junior' or in the
    -- table 'senior'
);

-- ========================================
-- SENIOR (ISA subtype of Sailor)
-- Seniors can be responsible for reservations
-- ========================================
CREATE TABLE Senior (
    sailor_id INTEGER,
    PRIMARY KEY(sailor_id),
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id)
);

-- ========================================
-- JUNIOR (ISA subtype of Sailor)
-- ========================================
CREATE TABLE Junior (
    sailor_id INTEGER,
    PRIMARY KEY(sailor_id),
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id)
);

-- ========================================
-- RESERVATION
-- IC-5: Trip.takeoff/arrival must lie within Reservation[start_date, end_date]. CHECK (end_date >= start_date) applied here; full containment enforcement is deferred.
-- responsible_sailor_id references Senior (only Seniors can be responsible) — structurally enforced via FK
-- ========================================
CREATE TABLE Reservation (
    iso_code CHAR(3),
    cni VARCHAR(50),
    start_date DATE,
    end_date DATE,
    responsible_for_sailor_id INTEGER NOT NULL,
    PRIMARY KEY(iso_code, cni, start_date, end_date),
    FOREIGN KEY (iso_code, cni) REFERENCES Boat(iso_code, cni),
    FOREIGN KEY (responsible_for_sailor_id) REFERENCES Senior(sailor_id),
    CHECK (end_date >= start_date)  -- IC-5 (partial): reservation dates ordering
    -- Every Reservation must exist in the table 'authorized'
);

-- ========================================
-- AUTHORIZED (Reservation ↔ Sailor M:N)
-- IC-3: Trip.skipper must be among Reservation's authorized sailors. Enforcement deferred.
-- ========================================
CREATE TABLE authorized (
    iso_code CHAR(3),
    cni VARCHAR(50),
    start_date DATE,
    end_date DATE,
    sailor_id INTEGER,
    PRIMARY KEY (iso_code, cni, start_date, end_date, sailor_id),
    FOREIGN KEY (iso_code, cni, start_date, end_date) REFERENCES Reservation(iso_code, cni, start_date, end_date),
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id)
);

-- ========================================
-- TRIP
-- IC-3: Trip.skipper must be among Reservation's authorized sailors. Enforcement deferred.
-- IC-4: Skipper requires valid certificate for the boat class and trip jurisdictions. Enforcement deferred.
-- IC-5: Trip.takeoff/arrival must lie within Reservation[start_date, end_date]. CHECK (arrival_date >= takeoff_date) applied here; full containment enforcement is deferred.
-- ========================================
CREATE TABLE Trip (
    iso_code CHAR(3),
    cni VARCHAR(50),
    start_date DATE,
    end_date DATE,
    takeoff_date DATE,
    arrival_date DATE,
    insurance_reference VARCHAR(200) NOT NULL,
    starts_at_latitude NUMERIC(8,6) NOT NULL,
    starts_at_longitude NUMERIC(9,6) NOT NULL,
    ends_at_latitude NUMERIC(8,6) NOT NULL,
    ends_at_longitude NUMERIC(9,6) NOT NULL,
    skippers_sailor_id INTEGER NOT NULL,
    PRIMARY KEY(iso_code, cni, start_date, end_date, takeoff_date, arrival_date),
    FOREIGN KEY (iso_code, cni, start_date, end_date) REFERENCES Reservation(iso_code, cni, start_date, end_date),
    FOREIGN KEY (skippers_sailor_id) REFERENCES Sailor(sailor_id),
    FOREIGN KEY (starts_at_latitude, starts_at_longitude) REFERENCES Location(latitude, longitude),
    FOREIGN KEY (ends_at_latitude, ends_at_longitude) REFERENCES Location(latitude, longitude),
    CHECK (arrival_date >= takeoff_date),  -- IC-5 (partial): trip dates ordering
    CHECK (NOT (starts_at_latitude = ends_at_latitude AND starts_at_longitude = ends_at_longitude))
    -- Every Trip must exist in the table 'navigates'
);

-- ========================================
-- NAVIGATES (Trip ↔ Jurisdiction M:N)
-- Stores the ordered list of jurisdictions a trip passes through
-- ========================================
CREATE TABLE navigates (
    iso_code CHAR(3),
    cni VARCHAR(50),
    start_date DATE,
    end_date DATE,
    takeoff_date DATE,
    arrival_date DATE,
    name VARCHAR(200),
    sequence_order INTEGER NOT NULL,
    PRIMARY KEY (iso_code, cni, start_date, end_date, takeoff_date, arrival_date, sequence_order),
    FOREIGN KEY (iso_code, cni, start_date, end_date, takeoff_date, arrival_date) REFERENCES Trip(iso_code, cni, start_date, end_date, takeoff_date, arrival_date),
    FOREIGN KEY (name) REFERENCES Jurisdiction(name),
    CHECK (sequence_order > 0)
);

-- ========================================
-- CERTIFICATION
-- IC-4: Skipper requires valid certificate for the boat class and trip jurisdictions (issue_date ≤ takeoff_date ≤ expiry_date and certificate valid for jurisdiction). Enforcement deferred.
-- ========================================
CREATE TABLE Certification (
    sailor_id INTEGER,
    issue_date DATE,
    expiry_date DATE NOT NULL,
    PRIMARY KEY(sailor_id,issue_date),
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id),
    CHECK (expiry_date > issue_date)  -- IC-4 related: certificate validity period
    -- Every Certification must exist in the table 'valid_in' and table 'certifies_for'
);

-- ========================================
-- VALID_IN (Certification ↔ Country M:N)
-- IC-4: Skipper requires certificate valid for trip jurisdictions. This table stores which countries a certification is valid in. Enforcement deferred.
-- ========================================
CREATE TABLE valid_in (
    sailor_id INTEGER,
    issue_date DATE,
    name VARCHAR(200),
    PRIMARY KEY (sailor_id,issue_date, name),
    FOREIGN KEY (sailor_id, issue_date) REFERENCES Certification(sailor_id, issue_date),
    FOREIGN KEY (name) REFERENCES Jurisdiction(name)
);

-- ========================================
-- CERTIFIES_FOR (Certification ↔ Boat Class M:N)
-- ========================================
CREATE TABLE certifies_for (
    sailor_id INTEGER,
    issue_date DATE,
    max_length NUMERIC(6,2),
    PRIMARY KEY(sailor_id, issue_date, max_length),
    FOREIGN KEY (sailor_id, issue_date) REFERENCES Certification(sailor_id, issue_date),
    FOREIGN KEY(max_length) REFERENCES Boat_Class(max_length)
);


