-- ========================================
-- SIBD 2025/2026 - Project Part 1
-- Boating Management System
-- Database Schema Definition
-- ========================================

-- Drop existing tables if they exist
DROP TABLE IF EXISTS Trip_Jurisdiction CASCADE;
DROP TABLE IF EXISTS Trip CASCADE;
DROP TABLE IF EXISTS Certification_Jurisdiction CASCADE;
DROP TABLE IF EXISTS Certification CASCADE;
DROP TABLE IF EXISTS Reservation_Sailor CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
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

-- IC: Any two locations must be at least one nautical mile apart
--     (approximately 1.852 km or 0.016667 degrees)
-- This constraint requires a CHECK with a subquery which is complex to implement
-- and would need triggers or application-level validation

-- ========================================
-- BOAT_CLASS
-- ========================================
CREATE TABLE Boat_Class (
    class_id SERIAL PRIMARY KEY,
    class_name VARCHAR(50) UNIQUE NOT NULL,
    max_length DECIMAL(6,2) NOT NULL CHECK (max_length > 0)
);

-- ========================================
-- BOAT
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

-- IC: Boat length must not exceed the maximum length of its class
-- This can be partially enforced with a trigger

-- ========================================
-- SAILOR
-- ========================================
CREATE TABLE Sailor (
    sailor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    category VARCHAR(10) NOT NULL CHECK (category IN ('Senior', 'Junior'))
);

-- ========================================
-- RESERVATION
-- ========================================
CREATE TABLE Reservation (
    reservation_id SERIAL PRIMARY KEY,
    cni VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    responsible_sailor_id INTEGER NOT NULL,
    FOREIGN KEY (cni) REFERENCES Boat(cni)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (responsible_sailor_id) REFERENCES Sailor(sailor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (end_date >= start_date)
);

-- IC: responsible_sailor_id must be a Senior sailor
-- IC: responsible_sailor_id must be one of the authorized sailors in Reservation_Sailor
-- IC: Every reservation must have at least one authorized sailor (in Reservation_Sailor)
-- These constraints require triggers or application-level validation

-- ========================================
-- RESERVATION_SAILOR (Authorized Sailors)
-- ========================================
CREATE TABLE Reservation_Sailor (
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
    CHECK (arrival_date >= takeoff_date),
    CHECK (start_location_id <> end_location_id)
);

-- IC: skipper_id must be one of the authorized sailors for the reservation (in Reservation_Sailor)
-- IC: takeoff_date must be within [start_date, end_date] of the reservation
-- IC: arrival_date must be within [start_date, end_date] of the reservation
-- IC: Each trip must have at least one jurisdiction recorded in Trip_Jurisdiction
-- These constraints require triggers or application-level validation

-- ========================================
-- TRIP_JURISDICTION
-- ========================================
CREATE TABLE Trip_Jurisdiction (
    trip_id INTEGER,
    jurisdiction_id INTEGER,
    sequence_order INTEGER NOT NULL,
    PRIMARY KEY (trip_id, jurisdiction_id),
    FOREIGN KEY (trip_id) REFERENCES Trip(trip_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (jurisdiction_id) REFERENCES Jurisdiction(jurisdiction_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (sequence_order > 0)
);

-- ========================================
-- CERTIFICATION
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
    CHECK (expiry_date > issue_date)
);

-- ========================================
-- CERTIFICATION_JURISDICTION
-- ========================================
CREATE TABLE Certification_Jurisdiction (
    certification_id INTEGER,
    iso_code CHAR(3),
    PRIMARY KEY (certification_id, iso_code),
    FOREIGN KEY (certification_id) REFERENCES Certification(certification_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (iso_code) REFERENCES Country(iso_code)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- IC: A certification must authorize at least one country jurisdiction (in Certification_Jurisdiction)
-- This constraint requires triggers or application-level validation

-- ========================================
-- INDEXES for Performance
-- ========================================
CREATE INDEX idx_boat_iso_code ON Boat(iso_code);
CREATE INDEX idx_reservation_cni ON Reservation(cni);
CREATE INDEX idx_reservation_dates ON Reservation(start_date, end_date);
CREATE INDEX idx_trip_reservation ON Trip(reservation_id);
CREATE INDEX idx_trip_skipper ON Trip(skipper_id);
CREATE INDEX idx_sailor_category ON Sailor(category);
CREATE INDEX idx_sailor_surname ON Sailor(surname);
