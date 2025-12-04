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
    --verificar se faz sentido ser VARCHAR e ter este tamanho
    flag VARCHAR(255) UNIQUE NOT NULL,
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
    FOREIGN KEY(name) REFERENCES Jurisdiction(name)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(iso_code) REFERENCES Country(iso_code)
        ON DELETE SET NULL ON UPDATE CASCADE
);
-- CHECK (iso_code IS NOT NULL OR name = 'International Waters')
-- IC: International Waters must have iso_code = NULL
-- IC: All other jurisdictions must have a non-null iso_code

-- ========================================
-- LOCATION
-- IC-2: Any two Location points must be ≥ 1 nautical mile apart — geospatial rule (use PostGIS or trigger). Sample coordinates adjusted.
-- ========================================
CREATE TABLE Location (
    iso_code CHAR(3),
    latitude NUMERIC(8,6),
    longitude NUMERIC(9,6),
    name VARCHAR(200) NOT NULL,
    PRIMARY KEY(iso_code,latitude,longitude),
    FOREIGN KEY (iso_code) REFERENCES Country(iso_code)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ========================================
-- BOAT_CLASS
-- IC-1: Boat.length ≤ Boat_Class.max_length — cross-table rule (enforcement deferred to trigger or application).
-- ========================================
CREATE TABLE Boat_Class (
    max_length NUMERIC(6,2) CHECK (max_length > 0),
    class_name VARCHAR(200) UNIQUE NOT NULL,
    PRIMARY KEY(max_length)
);

-- ========================================
-- BOAT
-- IC-1: Boat.length ≤ Boat_Class.max_length — cross-table rule (enforcement deferred to trigger or application). Ensure sample data respects this.
-- ========================================
CREATE TABLE Boat (
    cni VARCHAR(50),
    name VARCHAR(200) NOT NULL,
    length NUMERIC(6,2) NOT NULL CHECK (length > 0),
    registration_year INTEGER NOT NULL,
    picture BYTEA,
    belongs_to_max_length NUMERIC(6,2) NOT NULL,
    registers_iso_code CHAR(3) NOT NULL,
    PRIMARY KEY(cni),
    FOREIGN KEY (belongs_to_max_length) REFERENCES Boat_Class(max_length)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (registers_iso_code) REFERENCES Country(iso_code)
        ON DELETE RESTRICT ON UPDATE CASCADE
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
);

-- ========================================
-- SENIOR (ISA subtype of Sailor)
-- Seniors can be responsible for reservations
-- ========================================
CREATE TABLE Senior (
    sailor_id INTEGER,
    PRIMARY KEY(sailor_id),
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ========================================
-- JUNIOR (ISA subtype of Sailor)
-- ========================================
CREATE TABLE Junior (
    sailor_id INTEGER,
    PRIMARY KEY(sailor_id),
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ========================================
-- RESERVATION
-- IC-5: Trip.takeoff/arrival must lie within Reservation[start_date, end_date]. CHECK (end_date >= start_date) applied here; full containment enforcement is deferred.
-- responsible_sailor_id references Senior (only Seniors can be responsible) — structurally enforced via FK
-- ========================================
CREATE TABLE Reservation (
    cni VARCHAR(50),
    start_date DATE,
    end_date DATE,
    responsible_for_sailor_id INTEGER NOT NULL,
    PRIMARY KEY(cni,start_date, end_date),
    FOREIGN KEY (cni) REFERENCES Boat(cni)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (responsible_for_sailor_id) REFERENCES Senior(sailor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (end_date >= start_date)  -- IC-5 (partial): reservation dates ordering
    -- Every Reservation must exist in the table 'authorized'
);

-- ========================================
-- AUTHORIZED (Reservation ↔ Sailor M:N)
-- IC-3: Trip.skipper must be among Reservation's authorized sailors. Enforcement deferred.
-- ========================================
CREATE TABLE authorized (
    cni VARCHAR(50),
    start_date DATE,
    end_date DATE,
    sailor_id INTEGER,
    PRIMARY KEY (cni,start_date, end_date, sailor_id),
    FOREIGN KEY (cni,start_date, end_date) REFERENCES Reservation(cni,start_date,end_date)
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
    cni VARCHAR(50),
    start_date DATE,
    end_date DATE,
    takeoff_date DATE,
    arrival_date DATE,
    insurance_reference VARCHAR(100) NOT NULL,
    starts_at_iso CHAR(3) NOT NULL,
    starts_at_latitude NUMERIC(8,6) NOT NULL,
    starts_at_longitude NUMERIC(9,6) NOT NULL,
    ends_at_iso CHAR(3) NOT NULL,
    ends_at_latitude NUMERIC(8,6) NOT NULL,
    ends_at_longitude NUMERIC(9,6) NOT NULL,
    skippers_sailor_id INTEGER NOT NULL,
    PRIMARY KEY(cni, start_date, end_date, takeoff_date,arrival_date),
    FOREIGN KEY (cni,start_date,end_date) REFERENCES Reservation(cni,start_date,end_date)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (skippers_sailor_id) REFERENCES Sailor(sailor_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (starts_at_iso,starts_at_latitude, starts_at_longitude) REFERENCES Location(iso_code,latitude,longitude)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ends_at_iso,ends_at_latitude, ends_at_longitude) REFERENCES Location(iso_code,latitude,longitude)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (arrival_date >= takeoff_date),  -- IC-5 (partial): trip dates ordering
    CHECK (NOT (starts_at_latitude = ends_at_latitude AND starts_at_longitude = ends_at_longitude))
    -- Every Trip must exist in the table 'navigates'
);

-- ========================================
-- NAVIGATES (Trip ↔ Jurisdiction M:N)
-- Stores the ordered list of jurisdictions a trip passes through
-- ========================================
CREATE TABLE navigates (
    cni VARCHAR(50),
    start_date DATE,
    end_date DATE,
    takeoff_date DATE,
    arrival_date DATE,
    name VARCHAR(200),
    --nao sei se devia ser integer a record list
    record_list INTEGER NOT NULL,
    PRIMARY KEY (cni, start_date, end_date, takeoff_date,arrival_date,name),
    FOREIGN KEY (cni, start_date, end_date, takeoff_date, arrival_date) REFERENCES Trip(cni, start_date, end_date,takeoff_date, arrival_date)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (name) REFERENCES Jurisdiction(name)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (record_list > 0)
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
    FOREIGN KEY (sailor_id) REFERENCES Sailor(sailor_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
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
    FOREIGN KEY (sailor_id, issue_date) REFERENCES Certification(sailor_id, issue_date)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (name) REFERENCES Jurisdiction(name)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ========================================
-- CERTIFIES_FOR (Certification ↔ Boat Class M:N)
-- ========================================
CREATE TABLE certifies_for (
    sailor_id INTEGER,
    issue_date DATE,
    max_length NUMERIC(6,2),
    PRIMARY KEY(sailor_id, issue_date, max_length),
    FOREIGN KEY (sailor_id, issue_date) REFERENCES Certification(sailor_id, issue_date)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(max_length) REFERENCES Boat_Class(max_length)
        ON DELETE CASCADE ON UPDATE CASCADE
);


