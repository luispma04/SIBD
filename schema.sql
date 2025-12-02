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
    iso_code CHAR(3) PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    flag VARCHAR(255) UNIQUE NOT NULL
);

-- ========================================
-- JURISDICTION
-- ========================================
CREATE TABLE Jurisdiction (
    jurisdiction_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    iso_code CHAR(3),
    FOREIGN KEY (iso_code) REFERENCES Country(iso_code)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CHECK (iso_code IS NOT NULL OR name = 'International Waters')
);

-- IC: International Waters must have iso_code = NULL
-- IC: All other jurisdictions must have a non-null iso_code

-- ========================================
-- LOCATION
-- IC-2: Any two Location points must be ≥ 1 nautical mile apart — geospatial rule (use PostGIS or trigger). Sample coordinates adjusted.
-- ========================================
CREATE TABLE Location (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(10,6) NOT NULL,
    iso_code CHAR(3) NOT NULL,
    FOREIGN KEY (iso_code) REFERENCES Country(iso_code)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE (latitude, longitude)
);

-- ========================================
-- BOAT_CLASS
-- IC-1: Boat.length ≤ Boat_Class.max_length — cross-table rule (enforcement deferred to trigger or application).
-- ========================================
CREATE TABLE Boat_Class (
    class_id SERIAL PRIMARY KEY,
    class_name VARCHAR(50) UNIQUE NOT NULL,
    max_length DECIMAL(6,2) NOT NULL CHECK (max_length > 0)
);

-- ========================================
-- BOAT
-- IC-1: Boat.length ≤ Boat_Class.max_length — cross-table rule (enforcement deferred to trigger or application). Ensure sample data respects this.
-- ========================================
CREATE TABLE Boat (
    cni VARCHAR(50) PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    length DECIMAL(6,2) NOT NULL CHECK (length > 0),
    registration_year INTEGER NOT NULL CHECK (registration_year >= 1900 AND registration_year <= 2100),
    class_id INTEGER NOT NULL,
    iso_code CHAR(3) NOT NULL,
    picture BYTEA,
    FOREIGN KEY (class_id) REFERENCES Boat_Class(class_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (iso_code) REFERENCES Country(iso_code)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ========================================
-- SAILOR (Supertype)
-- ========================================
CREATE TABLE Sailor (
    sailor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

-- ========================================
-- SENIOR (ISA subtype of Sailor)
-- Seniors can be responsible for reservations
-- ========================================
CREATE TABLE Senior (
    sailor_id INTEGER PRIMARY KEY,
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ========================================
-- JUNIOR (ISA subtype of Sailor)
-- ========================================
CREATE TABLE Junior (
    sailor_id INTEGER PRIMARY KEY,
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ========================================
-- RESERVATION
-- IC-5: Trip.takeoff/arrival must lie within Reservation[start_date, end_date]. CHECK (end_date >= start_date) applied here; full containment enforcement is deferred.
-- responsible_sailor_id references Senior (only Seniors can be responsible) — structurally enforced via FK
-- ========================================
CREATE TABLE Reservation (
    reservation_id SERIAL PRIMARY KEY,
    cni VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    responsible_sailor_id INTEGER NOT NULL,
    FOREIGN KEY (cni) REFERENCES Boat(cni)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (responsible_sailor_id) REFERENCES Senior(sailor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (end_date >= start_date)  -- IC-5 (partial): reservation dates ordering
);

-- ========================================
-- AUTHORIZED (Reservation ↔ Sailor M:N)
-- IC-3: Trip.skipper must be among Reservation's authorized sailors. Enforcement deferred.
-- ========================================
CREATE TABLE authorized (
    reservation_id INTEGER,
    sailor_id INTEGER,
    PRIMARY KEY (reservation_id, sailor_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ========================================
-- TRIP
-- IC-3: Trip.skipper must be among Reservation's authorized sailors. Enforcement deferred.
-- IC-4: Skipper requires valid certificate for the boat class and trip jurisdictions. Enforcement deferred.
-- IC-5: Trip.takeoff/arrival must lie within Reservation[start_date, end_date]. CHECK (arrival_date >= takeoff_date) applied here; full containment enforcement is deferred.
-- ========================================
CREATE TABLE Trip (
    trip_id SERIAL PRIMARY KEY,
    reservation_id INTEGER NOT NULL,
    skipper_id INTEGER NOT NULL,
    start_location_id INTEGER NOT NULL,
    end_location_id INTEGER NOT NULL,
    takeoff_date DATE NOT NULL,
    arrival_date DATE NOT NULL,
    insurance_reference VARCHAR(100) NOT NULL,
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (skipper_id) REFERENCES Sailor(sailor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (start_location_id) REFERENCES Location(location_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (end_location_id) REFERENCES Location(location_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (arrival_date >= takeoff_date),  -- IC-5 (partial): trip dates ordering
    CHECK (start_location_id <> end_location_id)
);

-- ========================================
-- NAVIGATES (Trip ↔ Jurisdiction M:N)
-- Stores the ordered list of jurisdictions a trip passes through
-- ========================================
CREATE TABLE navigates (
    trip_id INTEGER,
    jurisdiction_id INTEGER,
    sequence_order INTEGER NOT NULL,
    PRIMARY KEY (trip_id, sequence_order),
    FOREIGN KEY (trip_id) REFERENCES Trip(trip_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (jurisdiction_id) REFERENCES Jurisdiction(jurisdiction_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (sequence_order > 0)
);

-- ========================================
-- CERTIFICATION
-- IC-4: Skipper requires valid certificate for the boat class and trip jurisdictions (issue_date ≤ takeoff_date ≤ expiry_date and certificate valid for jurisdiction). Enforcement deferred.
-- ========================================
CREATE TABLE Certification (
    certification_id SERIAL PRIMARY KEY,
    sailor_id INTEGER NOT NULL,
    class_id INTEGER NOT NULL,
    issue_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (class_id) REFERENCES Boat_Class(class_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (expiry_date > issue_date)  -- IC-4 related: certificate validity period
);

-- ========================================
-- VALID_IN (Certification ↔ Country M:N)
-- IC-4: Skipper requires certificate valid for trip jurisdictions. This table stores which countries a certification is valid in. Enforcement deferred.
-- ========================================
CREATE TABLE valid_in (
    certification_id INTEGER,
    iso_code CHAR(3),
    PRIMARY KEY (certification_id, iso_code),
    FOREIGN KEY (certification_id) REFERENCES Certification(certification_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (iso_code) REFERENCES Country(iso_code)
        ON DELETE RESTRICT ON UPDATE CASCADE
);


