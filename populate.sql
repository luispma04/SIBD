-- ========================================
-- SIBD 2025/2026 - Project Part 1
-- Boating Management System
-- Database Population Script
-- (aligned with composite keys in schema.sql)
-- ========================================

-- ========================================
-- COUNTRIES
-- ========================================
INSERT INTO Country (iso_code, name, flag) VALUES
('PRT', 'Portugal', 'https://example.com/countries/portugal_flag.jpg'),
('ESP', 'Spain', 'https://example.com/countries/spain_flag.jpg'),
('FRA', 'France', 'https://example.com/countries/france_flag.jpg'),
('ITA', 'Italy', 'https://example.com/countries/italy_flag.jpg'),
('GBR', 'United Kingdom', 'https://example.com/countries/uk_flag.jpg'),
('USA', 'United States', 'https://example.com/countries/usa_flag.jpg'),
('BRA', 'Brazil', 'https://example.com/countries/brazil_flag.jpg');

-- ========================================
-- JURISDICTIONS
-- ========================================
INSERT INTO Jurisdiction (name) VALUES
('Portuguese Internal Waters'),
('Portuguese Territorial Sea'),
('Portuguese EEZ'),
('Spanish Internal Waters'),
('Spanish Territorial Sea'),
('Spanish EEZ'),
('French Internal Waters'),
('French Territorial Sea'),
('Italian Internal Waters'),
('British Internal Waters'),
('US Internal Waters'),
('International Waters'),
('Brazilian Internal Waters');

-- ========================================
-- ADMINISTERS (Country 1 : M Jurisdiction)
-- ========================================
INSERT INTO administers (country_iso_code, jurisdiction_name) VALUES
('PRT', 'Portuguese Internal Waters'),
('PRT', 'Portuguese Territorial Sea'),
('PRT', 'Portuguese EEZ'),
('ESP', 'Spanish Internal Waters'),
('ESP', 'Spanish Territorial Sea'),
('ESP', 'Spanish EEZ'),
('FRA', 'French Internal Waters'),
('FRA', 'French Territorial Sea'),
('ITA', 'Italian Internal Waters'),
('GBR', 'British Internal Waters'),
('USA', 'US Internal Waters'),
('BRA', 'Brazilian Internal Waters'),
(NULL, 'International Waters');

-- ========================================
-- LOCATIONS
-- ========================================
INSERT INTO Location (latitude, longitude, name) VALUES
(38.706944, -9.135278, 'Lisbon Marina'),
(38.697222, -9.420833, 'Cascais Harbor'),
(37.019167, -7.930833, 'Faro Marina'),
(36.527778, -6.288889, 'Cadiz Port'),
(41.375833,  2.183056, 'Barcelona Port'),
(43.296389,  5.369722, 'Marseille Port'),
(43.695556,  7.282222, 'Nice Harbor'),
(40.838611, 14.252778, 'Naples Port'),
(50.899722, -1.404167, 'Southampton Marina'),
(25.775278, -80.186944,'Miami Marina'),
(-22.968333,-43.173056,'Rio de Janeiro Marina');

-- ========================================
-- HAS_LOCATION (assign each location to a country)
-- ========================================
INSERT INTO has_location (country_iso_code, location_latitude, location_longitude) VALUES
('PRT', 38.706944, -9.135278),
('PRT', 38.697222, -9.420833),
('PRT', 37.019167, -7.930833),
('ESP', 36.527778, -6.288889),
('ESP', 41.375833,  2.183056),
('FRA', 43.296389,  5.369722),
('FRA', 43.695556,  7.282222),
('ITA', 40.838611, 14.252778),
('GBR', 50.899722, -1.404167),
('USA', 25.775278, -80.186944),
('BRA', -22.968333,-43.173056);

-- ========================================
-- BOAT CLASSES
-- ========================================
INSERT INTO Boat_Class (name, max_length) VALUES
('Class 1', 15.00),
('Class 2', 25.00),
('Class 3', 40.00),
('Class 4', 60.00),
('Class 5', 100.00);

-- ========================================
-- BOATS (composite PK: country_iso_code, cni)
-- ========================================
INSERT INTO Boat (cni, country_iso_code, class_name, name, length, registration_year, picture) VALUES
('2020-001', 'PRT', 'Class 1', 'Ocean Explorer',     14.50, 2020, 'https://example.com/boats/ocean-explorer.jpg'),
('2019-042', 'PRT', 'Class 2', 'Sea Breeze',         23.00, 2019, 'https://example.com/boats/sea-breeze.jpg'),
('2021-015', 'PRT', 'Class 3', 'Atlantic Dream',     38.50, 2021, 'https://example.com/boats/atlantic-dream.jpg'),
('2018-123', 'ESP', 'Class 2', 'Mediterranean Star', 22.00, 2018, 'https://example.com/boats/mediterranean-star.jpg'),
('2022-056', 'ESP', 'Class 4', 'Costa Brava',        55.00, 2022, 'https://example.com/boats/costa-brava.jpg'),
('2020-089', 'FRA', 'Class 3', 'Cote d Azur',        35.00, 2020, 'https://example.com/boats/cote-d-azur.jpg'),
('2019-234', 'ITA', 'Class 2', 'Bella Vista',        24.00, 2019, 'https://example.com/boats/bella-vista.jpg'),
('2021-777', 'GBR', 'Class 4', 'British Sailor',     58.00, 2021, 'https://example.com/boats/british-sailor.jpg'),
('2023-999', 'USA', 'Class 5', 'Freedom Wave',       95.00, 2023, 'https://example.com/boats/freedom-wave.jpg'),
('2020-444', 'BRA', 'Class 3', 'Copacabana',         39.00, 2020, 'https://example.com/boats/copacabana.jpg');

-- ========================================
-- SAILORS
-- ========================================
INSERT INTO Sailor (first_name, surname, email) VALUES
('Joao',     'Santos',    'joao.santos@email.com'),
('Maria',    'Silva',     'maria.silva@email.com'),
('Pedro',    'Santos',    'pedro.santos@email.com'),
('Ana',      'Costa',     'ana.costa@email.com'),
('Carlos',   'Ferreira',  'carlos.ferreira@email.com'),
('Isabel',   'Oliveira',  'isabel.oliveira@email.com'),
('Ricardo',  'Pereira',   'ricardo.pereira@email.com'),
('Sofia',    'Rodrigues', 'sofia.rodrigues@email.com'),
('Miguel',   'Alves',     'miguel.alves@email.com'),
('Beatriz',  'Santos',    'beatriz.santos@email.com'),
('Fernando', 'Gomes',     'fernando.gomes@email.com'),
('Lucia',    'Martins',   'lucia.martins@email.com');

-- ========================================
-- SENIOR / JUNIOR
-- ========================================
INSERT INTO Senior (senior_id) VALUES
(1),(2),(3),(5),(7),(9),(11);

INSERT INTO Junior (junior_id) VALUES
(4),(6),(8),(10),(12);

-- ========================================
-- RESERVATIONS (composite PK)
-- ========================================
INSERT INTO Reservation (country_iso_code, boat_cni, start_date, end_date, responsible_for_sailor_id) VALUES
('PRT', '2020-001', '2025-06-01', '2025-06-07', 1),  -- Joao
('PRT', '2019-042', '2025-06-15', '2025-06-20', 2),  -- Maria
('PRT', '2021-015', '2025-07-01', '2025-07-10', 3),  -- Pedro
('ESP', '2018-123', '2025-07-15', '2025-07-22', 5),  -- Carlos
('ESP', '2022-056', '2025-08-01', '2025-08-15', 7),  -- Ricardo
('FRA', '2020-089', '2025-08-20', '2025-08-30', 9),  -- Miguel
('ITA', '2019-234', '2025-09-01', '2025-09-10', 11), -- Fernando
('PRT', '2020-001', '2025-09-15', '2025-09-22', 1),  -- Joao (second reservation)
('PRT', '2019-042', '2025-10-01', '2025-10-05', 3);  -- Pedro

-- ========================================
-- AUTHORIZED (Reservation  Sailor)
-- ========================================
INSERT INTO authorized (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, sailor_id) VALUES
-- Reservation 1
('PRT','2020-001','2025-06-01','2025-06-07',1),
('PRT','2020-001','2025-06-01','2025-06-07',4),
('PRT','2020-001','2025-06-01','2025-06-07',6),
-- Reservation 2
('PRT','2019-042','2025-06-15','2025-06-20',2),
('PRT','2019-042','2025-06-15','2025-06-20',8),
-- Reservation 3
('PRT','2021-015','2025-07-01','2025-07-10',3),
('PRT','2021-015','2025-07-01','2025-07-10',4),
('PRT','2021-015','2025-07-01','2025-07-10',10),
-- Reservation 4
('ESP','2018-123','2025-07-15','2025-07-22',5),
('ESP','2018-123','2025-07-15','2025-07-22',6),
-- Reservation 5
('ESP','2022-056','2025-08-01','2025-08-15',7),
('ESP','2022-056','2025-08-01','2025-08-15',8),
('ESP','2022-056','2025-08-01','2025-08-15',12),
-- Reservation 6
('FRA','2020-089','2025-08-20','2025-08-30',9),
('FRA','2020-089','2025-08-20','2025-08-30',10),
-- Reservation 7
('ITA','2019-234','2025-09-01','2025-09-10',11),
('ITA','2019-234','2025-09-01','2025-09-10',12),
-- Reservation 8
('PRT','2020-001','2025-09-15','2025-09-22',1),
('PRT','2020-001','2025-09-15','2025-09-22',6),
-- Reservation 9
('PRT','2019-042','2025-10-01','2025-10-05',3),
('PRT','2019-042','2025-10-01','2025-10-05',10);

-- ========================================
-- TRIPS (composite PK)
-- dates inside reservation intervals; skippers are authorized
-- ========================================
INSERT INTO Trip (
    country_iso_code, boat_cni, reservation_start_date, reservation_end_date,
    takeoff_date, arrival_date, insurance_reference,
    starts_at_latitude, starts_at_longitude,
    ends_at_latitude,   ends_at_longitude,
    skippers_id
) VALUES
-- Reservation 1 trips (boat PRT/2020-001, Class 1)
('PRT','2020-001','2025-06-01','2025-06-07','2025-06-02','2025-06-02','INS-2025-001',
 38.706944,-9.135278, 38.697222,-9.420833, 1),
('PRT','2020-001','2025-06-01','2025-06-07','2025-06-04','2025-06-05','INS-2025-002',
 38.697222,-9.420833, 37.019167,-7.930833, 1),
-- Reservation 2 trip (boat PRT/2019-042, Class 2)
('PRT','2019-042','2025-06-15','2025-06-20','2025-06-16','2025-06-17','INS-2025-003',
 38.706944,-9.135278, 37.019167,-7.930833, 2),
-- Reservation 3 trips (boat PRT/2021-015, Class 3)
('PRT','2021-015','2025-07-01','2025-07-10','2025-07-02','2025-07-04','INS-2025-004',
 37.019167,-7.930833, 36.527778,-6.288889, 3),
('PRT','2021-015','2025-07-01','2025-07-10','2025-07-06','2025-07-08','INS-2025-005',
 36.527778,-6.288889, 41.375833, 2.183056, 3),
-- Reservation 4 trip (boat ESP/2018-123, Class 2)
('ESP','2018-123','2025-07-15','2025-07-22','2025-07-16','2025-07-18','INS-2025-006',
 36.527778,-6.288889, 41.375833, 2.183056, 5),
-- Reservation 5 trip (boat ESP/2022-056, Class 4)
('ESP','2022-056','2025-08-01','2025-08-15','2025-08-03','2025-08-06','INS-2025-007',
 41.375833, 2.183056, 43.296389, 5.369722, 7),
-- Reservation 6 trip (boat FRA/2020-089, Class 3)
('FRA','2020-089','2025-08-20','2025-08-30','2025-08-22','2025-08-24','INS-2025-008',
 43.296389, 5.369722, 43.695556, 7.282222, 9),
-- Reservation 8 trip (boat PRT/2020-001, Class 1)
('PRT','2020-001','2025-09-15','2025-09-22','2025-09-16','2025-09-17','INS-2025-009',
 38.706944,-9.135278, 38.697222,-9.420833, 1);
-- Reservation 7 and 9: no trips (left empty on purpose)

-- ========================================
-- NAVIGATES (Trip  Jurisdiction)
-- ========================================
INSERT INTO navigates (
    country_iso_code, boat_cni, reservation_start_date, reservation_end_date,
    trip_takeoff_date, trip_arrival_date,
    jurisdiction_name, jurisdiction_sequence_order
) VALUES
-- Trip 1: Lisbon -> Cascais
('PRT','2020-001','2025-06-01','2025-06-07','2025-06-02','2025-06-02','Portuguese Internal Waters',1),
('PRT','2020-001','2025-06-01','2025-06-07','2025-06-02','2025-06-02','Portuguese Territorial Sea',2),
-- Trip 2: Cascais -> Faro
('PRT','2020-001','2025-06-01','2025-06-07','2025-06-04','2025-06-05','Portuguese Territorial Sea',1),
('PRT','2020-001','2025-06-01','2025-06-07','2025-06-04','2025-06-05','Portuguese EEZ',2),
-- Trip 3: Lisbon -> Faro
('PRT','2019-042','2025-06-15','2025-06-20','2025-06-16','2025-06-17','Portuguese Internal Waters',1),
('PRT','2019-042','2025-06-15','2025-06-20','2025-06-16','2025-06-17','Portuguese Territorial Sea',2),
-- Trip 4: Faro -> Cadiz
('PRT','2021-015','2025-07-01','2025-07-10','2025-07-02','2025-07-04','Portuguese Territorial Sea',1),
('PRT','2021-015','2025-07-01','2025-07-10','2025-07-02','2025-07-04','Portuguese EEZ',2),
('PRT','2021-015','2025-07-01','2025-07-10','2025-07-02','2025-07-04','Spanish EEZ',3),
('PRT','2021-015','2025-07-01','2025-07-10','2025-07-02','2025-07-04','Spanish Territorial Sea',4),
-- Trip 5: Cadiz -> Barcelona
('PRT','2021-015','2025-07-01','2025-07-10','2025-07-06','2025-07-08','Spanish Internal Waters',1),
('PRT','2021-015','2025-07-01','2025-07-10','2025-07-06','2025-07-08','Spanish Territorial Sea',2),
('PRT','2021-015','2025-07-01','2025-07-10','2025-07-06','2025-07-08','Spanish EEZ',3),
-- Trip 6: Cadiz -> Barcelona (ESP/2018-123)
('ESP','2018-123','2025-07-15','2025-07-22','2025-07-16','2025-07-18','Spanish Internal Waters',1),
('ESP','2018-123','2025-07-15','2025-07-22','2025-07-16','2025-07-18','Spanish Territorial Sea',2),
-- Trip 7: Barcelona -> Marseille (ESP/2022-056)
('ESP','2022-056','2025-08-01','2025-08-15','2025-08-03','2025-08-06','Spanish Internal Waters',1),
('ESP','2022-056','2025-08-01','2025-08-15','2025-08-03','2025-08-06','Spanish Territorial Sea',2),
('ESP','2022-056','2025-08-01','2025-08-15','2025-08-03','2025-08-06','International Waters',3),
('ESP','2022-056','2025-08-01','2025-08-15','2025-08-03','2025-08-06','French Territorial Sea',4),
('ESP','2022-056','2025-08-01','2025-08-15','2025-08-03','2025-08-06','French Internal Waters',5),
-- Trip 8: Marseille -> Nice (FRA/2020-089)
('FRA','2020-089','2025-08-20','2025-08-30','2025-08-22','2025-08-24','French Internal Waters',1),
('FRA','2020-089','2025-08-20','2025-08-30','2025-08-22','2025-08-24','French Territorial Sea',2),
-- Trip 9: Lisbon -> Cascais (PRT/2020-001 second reservation)
('PRT','2020-001','2025-09-15','2025-09-22','2025-09-16','2025-09-17','Portuguese Internal Waters',1),
('PRT','2020-001','2025-09-15','2025-09-22','2025-09-16','2025-09-17','Portuguese Territorial Sea',2);

-- ========================================
-- CERTIFICATIONS (PK: sailor_id, issue_date)
-- ========================================
INSERT INTO Certification (sailor_id, issue_date, expiry_date) VALUES
(1, '2020-01-15', '2026-01-15'),
(1, '2021-03-20', '2027-03-20'),
(2, '2019-05-10', '2025-05-10'),
(2, '2020-06-15', '2026-06-15'),
(2, '2021-08-01', '2027-08-01'),
(3, '2018-02-20', '2026-02-20'),
(3, '2019-04-10', '2027-04-10'),
(3, '2020-07-15', '2028-07-15'),
(5, '2020-09-05', '2026-09-05'),
(5, '2021-11-12', '2027-11-12'),
(6, '2023-01-20', '2027-01-20'),
(7, '2019-03-15', '2025-03-15'),
(7, '2020-05-20', '2026-05-20'),
(7, '2021-07-25', '2027-07-25'),
(9, '2020-10-10', '2026-10-10'),
(9, '2021-12-15', '2027-12-15'),
(10,'2024-01-10', '2028-01-10'),
(11,'2019-06-20', '2025-06-20'),
(11,'2020-08-25', '2026-08-25'),
(11, '2021-11-02', '2027-11-02'),
(12,'2023-11-15', '2027-11-15');

-- ========================================
-- CERTIFIES_FOR (Certification  Boat_Class)
-- ========================================
INSERT INTO certifies_for (sailor_id, certification_issue_date, class_name) VALUES
-- Joao (sailor 1)
(1,'2020-01-15','Class 1'),
(1,'2021-03-20','Class 2'),
-- Maria (sailor 2)
(2,'2019-05-10','Class 1'),
(2,'2020-06-15','Class 2'),
(2,'2021-08-01','Class 3'),
-- Pedro (sailor 3)
(3,'2018-02-20','Class 1'),
(3,'2019-04-10','Class 2'),
(3,'2020-07-15','Class 3'),
-- Carlos (sailor 5)
(5,'2020-09-05','Class 2'),
(5,'2021-11-12','Class 3'),
-- Isabel (sailor 6)
(6,'2023-01-20','Class 1'),
-- Ricardo (sailor 7)
(7,'2019-03-15','Class 2'),
(7,'2020-05-20','Class 3'),
(7,'2021-07-25','Class 4'),
-- Miguel (sailor 9)
(9,'2020-10-10','Class 2'),
(9,'2021-12-15','Class 3'),
-- Beatriz (sailor 10)
(10,'2024-01-10','Class 1'),
-- Fernando (sailor 11)
(11,'2019-06-20','Class 1'),
(11,'2020-08-25','Class 2'),
(11,'2021-11-02','Class 3'),
-- Lucia (sailor 12)
(12,'2023-11-15','Class 1');

-- ========================================
-- VALID_IN (Certification  Jurisdiction)
-- ========================================
INSERT INTO valid_in (sailor_id, certification_issue_date, jurisdiction_name) VALUES
-- Joao
(1,'2020-01-15','Portuguese Internal Waters'),
(1,'2020-01-15','Spanish Internal Waters'),
(1,'2021-03-20','Portuguese Internal Waters'),
(1,'2021-03-20','Spanish Internal Waters'),
(1,'2021-03-20','French Internal Waters'),
-- Maria
(2,'2019-05-10','Portuguese Internal Waters'),
(2,'2020-06-15','Portuguese Internal Waters'),
(2,'2020-06-15','Spanish Internal Waters'),
(2,'2021-08-01','Portuguese Internal Waters'),
(2,'2021-08-01','Spanish Internal Waters'),
(2,'2021-08-01','French Internal Waters'),
-- Pedro
(3,'2018-02-20','Portuguese Internal Waters'),
(3,'2018-02-20','Spanish Internal Waters'),
(3,'2019-04-10','Portuguese Internal Waters'),
(3,'2019-04-10','Spanish Internal Waters'),
(3,'2020-07-15','Portuguese Internal Waters'),
(3,'2020-07-15','Spanish Internal Waters'),
(3,'2020-07-15','French Internal Waters'),
-- Carlos
(5,'2020-09-05','Spanish Internal Waters'),
(5,'2021-11-12','Spanish Internal Waters'),
(5,'2021-11-12','French Internal Waters'),
-- Isabel
(6,'2023-01-20','Portuguese Internal Waters'),
-- Ricardo
(7,'2019-03-15','Spanish Internal Waters'),
(7,'2020-05-20','Spanish Internal Waters'),
(7,'2020-05-20','French Internal Waters'),
(7,'2021-07-25','Spanish Internal Waters'),
(7,'2021-07-25','French Internal Waters'),
-- Miguel
(9,'2020-10-10','French Internal Waters'),
(9,'2021-12-15','French Internal Waters'),
-- Beatriz
(10,'2024-01-10','Portuguese Internal Waters'),
-- Fernando
(11,'2019-06-20','Italian Internal Waters'),
(11,'2020-08-25','Italian Internal Waters'),
-- Lucia
(12,'2023-11-15','Brazilian Internal Waters');

-- ========================================
-- IC VIOLATION EXAMPLES (INTENTIONALLY BREAKING COMMENTED IC'S)
-- These rows rely only on currently unenforced ICs. Existing CHECK/FK constraints still hold.
-- ========================================

-- IC-1: Country registers boats but has no location defined.
INSERT INTO Country (iso_code, name, flag) VALUES
('NOR', 'Norway', 'https://example.com/countries/norway_flag.jpg');
INSERT INTO Boat (cni, country_iso_code, class_name, name, length, registration_year, picture) VALUES
('2024-321', 'NOR', 'Class 1', 'No Harbor', 12.00, 2024, 'https://example.com/boats/no-harbor.jpg');
-- Example that would satisfy IC-1 (provide at least one location for NOR):
-- INSERT INTO Location (latitude, longitude, name) VALUES (59.909444, 10.734000, 'Oslo Harbor');
-- INSERT INTO has_location (country_iso_code, location_latitude, location_longitude) VALUES ('NOR', 59.909444, 10.734000);

-- IC-3: Two locations closer than 1 nautical mile (not enforced here).
INSERT INTO Location (latitude, longitude, name) VALUES
(38.706900, -9.135200, 'Near Lisbon Marina');
INSERT INTO has_location (country_iso_code, location_latitude, location_longitude) VALUES
('PRT', 38.706900, -9.135200);

-- IC-5: Boat longer than its class allows (Class 1 max 15.00).
INSERT INTO Boat (cni, country_iso_code, class_name, name, length, registration_year, picture) VALUES
('2017-999', 'PRT', 'Class 1', 'Too Long', 20.00, 2017, 'https://example.com/boats/too-long.jpg');

-- IC-7: Same sailor appears in both Senior and Junior.
INSERT INTO Sailor (first_name, surname, email) VALUES
('Dual', 'Role', 'dual.role@email.com');
INSERT INTO Senior (senior_id)
SELECT id FROM Sailor WHERE email = 'dual.role@email.com';
INSERT INTO Junior (junior_id)
SELECT id FROM Sailor WHERE email = 'dual.role@email.com';

-- IC-9: Overlapping reservations for the same boat.
INSERT INTO Reservation (country_iso_code, boat_cni, start_date, end_date, responsible_for_sailor_id) VALUES
('PRT', '2020-001', '2025-06-03', '2025-06-06', 1); -- overlaps existing 2025-06-01..07
INSERT INTO authorized (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, sailor_id) VALUES
('PRT','2020-001','2025-06-03','2025-06-06',1);

-- IC-10: Reservation without any authorized sailors.
INSERT INTO Reservation (country_iso_code, boat_cni, start_date, end_date, responsible_for_sailor_id) VALUES
('ESP', '2018-123', '2025-07-18', '2025-07-19', 5); -- no authorized entry on purpose
-- Example that would satisfy IC-10 if uncommented:
-- INSERT INTO authorized (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, sailor_id) VALUES
-- ('ESP','2018-123','2025-07-18','2025-07-19',5);

-- IC-11: Trip skipper not in authorized list.
INSERT INTO Reservation (country_iso_code, boat_cni, start_date, end_date, responsible_for_sailor_id) VALUES
('PRT', '2019-042', '2025-11-01', '2025-11-05', 2);
INSERT INTO authorized (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, sailor_id) VALUES
('PRT','2019-042','2025-11-01','2025-11-05',4),
('PRT','2019-042','2025-11-01','2025-11-05',5);
INSERT INTO Trip (
    country_iso_code, boat_cni, reservation_start_date, reservation_end_date,
    takeoff_date, arrival_date, insurance_reference,
    starts_at_latitude, starts_at_longitude,
    ends_at_latitude,   ends_at_longitude,
    skippers_id
) VALUES
('PRT','2019-042','2025-11-01','2025-11-05','2025-11-02','2025-11-03','INS-VIOL-011',
 38.706944,-9.135278, 37.019167,-7.930833, 1); -- skipper 1 not authorized for this reservation
INSERT INTO navigates (
    country_iso_code, boat_cni, reservation_start_date, reservation_end_date,
    trip_takeoff_date, trip_arrival_date,
    jurisdiction_name, jurisdiction_sequence_order
) VALUES
('PRT','2019-042','2025-11-01','2025-11-05','2025-11-02','2025-11-03','Portuguese Internal Waters',1),
('PRT','2019-042','2025-11-01','2025-11-05','2025-11-02','2025-11-03','Portuguese Territorial Sea',2);
-- Example that would satisfy IC-11 (authorize skipper 1):
-- INSERT INTO authorized (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, sailor_id) VALUES
-- ('PRT','2019-042','2025-11-01','2025-11-05',1);

-- IC-12: Skipper lacks required certificate for boat class/jurisdiction.
INSERT INTO Reservation (country_iso_code, boat_cni, start_date, end_date, responsible_for_sailor_id) VALUES
('ESP', '2022-056', '2025-11-10', '2025-11-14', 7);
INSERT INTO authorized (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, sailor_id) VALUES
('ESP','2022-056','2025-11-10','2025-11-14',6);
INSERT INTO Trip (
    country_iso_code, boat_cni, reservation_start_date, reservation_end_date,
    takeoff_date, arrival_date, insurance_reference,
    starts_at_latitude, starts_at_longitude,
    ends_at_latitude,   ends_at_longitude,
    skippers_id
) VALUES
('ESP','2022-056','2025-11-10','2025-11-14','2025-11-11','2025-11-12','INS-VIOL-012',
 41.375833, 2.183056, 43.296389, 5.369722, 6); -- sailor 6 only certified for Class 1
INSERT INTO navigates (
    country_iso_code, boat_cni, reservation_start_date, reservation_end_date,
    trip_takeoff_date, trip_arrival_date,
    jurisdiction_name, jurisdiction_sequence_order
) VALUES
('ESP','2022-056','2025-11-10','2025-11-14','2025-11-11','2025-11-12','Spanish Internal Waters',1),
('ESP','2022-056','2025-11-10','2025-11-14','2025-11-11','2025-11-12','Spanish Territorial Sea',2);
-- Example that would satisfy IC-12 (give skipper 6 a valid Class 4 cert during the trip):
-- INSERT INTO Certification (sailor_id, issue_date, expiry_date) VALUES
-- (6, '2025-01-01', '2026-01-01');
-- INSERT INTO certifies_for (sailor_id, certification_issue_date, class_name) VALUES
-- (6, '2025-01-01', 'Class 4');
-- INSERT INTO valid_in (sailor_id, certification_issue_date, jurisdiction_name) VALUES
-- (6, '2025-01-01', 'Spanish Internal Waters'),
-- (6, '2025-01-01', 'French Internal Waters');

-- IC-15: Overlapping trips within the same reservation.
-- IC-16: Trip without navigates entry.
INSERT INTO Reservation (country_iso_code, boat_cni, start_date, end_date, responsible_for_sailor_id) VALUES
('FRA', '2020-089', '2025-09-01', '2025-09-10', 9);
INSERT INTO authorized (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, sailor_id) VALUES
('FRA','2020-089','2025-09-01','2025-09-10',9);
INSERT INTO Trip (
    country_iso_code, boat_cni, reservation_start_date, reservation_end_date,
    takeoff_date, arrival_date, insurance_reference,
    starts_at_latitude, starts_at_longitude,
    ends_at_latitude,   ends_at_longitude,
    skippers_id
) VALUES
('FRA','2020-089','2025-09-01','2025-09-10','2025-09-02','2025-09-05','INS-VIOL-015A',
 43.296389, 5.369722, 43.695556, 7.282222, 9),
('FRA','2020-089','2025-09-01','2025-09-10','2025-09-04','2025-09-07','INS-VIOL-015B',
 43.695556, 7.282222, 43.296389, 5.369722, 9); -- overlaps with previous trip
 -- no navigates row on purpose

-- Example that would satisfy IC-16 if uncommented:
-- INSERT INTO navigates (
--     country_iso_code, boat_cni, reservation_start_date, reservation_end_date,
--     trip_takeoff_date, trip_arrival_date,
--     jurisdiction_name, jurisdiction_sequence_order
-- ) VALUES
-- ('FRA','2020-089','2025-09-01','2025-09-02','2025-09-02','2025-09-05','French Internal Waters',1);

-- IC-18: Certification missing valid_in and certifies_for associations.
INSERT INTO Certification (sailor_id, issue_date, expiry_date) VALUES
(8, '2025-01-01', '2026-01-01');
-- Examples that would satisfy IC-18 if uncommented:
-- INSERT INTO valid_in (sailor_id, certification_issue_date, jurisdiction_name) VALUES
-- (8,'2025-01-01','Portuguese Internal Waters');
-- INSERT INTO certifies_for (sailor_id, certification_issue_date, class_name) VALUES
-- (8,'2025-01-01','Class 1');

-- ========================================
-- Enforced ICs (would error if uncommented) — shown for reference only
-- IC-2: International Waters must have iso_code NULL (CHECK enforced)
-- INSERT INTO administers (country_iso_code, jurisdiction_name) VALUES ('PRT', 'International Waters');
-- IC-4: Boat_Class.max_length must be positive (CHECK enforced)
-- INSERT INTO Boat_Class (name, max_length) VALUES ('Bad Class', -1);
-- IC-6: Boat.length must be positive (CHECK enforced)
-- INSERT INTO Boat (cni, country_iso_code, class_name, name, length, registration_year, picture) VALUES ('BAD-LEN', 'PRT', 'Class 1', 'Bad Length', -5, 2024, 'x');
-- IC-8: Reservation end_date >= start_date (CHECK enforced)
-- INSERT INTO Reservation (country_iso_code, boat_cni, start_date, end_date, responsible_for_sailor_id) VALUES ('PRT','2020-001','2025-05-10','2025-05-01',1);
-- IC-13: Trip arrival_date >= takeoff_date (CHECK enforced)
-- INSERT INTO Trip (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, takeoff_date, arrival_date, insurance_reference, starts_at_latitude, starts_at_longitude, ends_at_latitude, ends_at_longitude, skippers_id) VALUES ('PRT','2020-001','2025-06-01','2025-06-07','2025-06-05','2025-06-04','INS-BAD-13',38.706944,-9.135278,38.697222,-9.420833,1);
-- IC-14: Trip dates within reservation window (CHECK enforced)
-- INSERT INTO Trip (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, takeoff_date, arrival_date, insurance_reference, starts_at_latitude, starts_at_longitude, ends_at_latitude, ends_at_longitude, skippers_id) VALUES ('PRT','2020-001','2025-06-01','2025-06-07','2025-05-31','2025-06-02','INS-BAD-14',38.706944,-9.135278,38.697222,-9.420833,1);
-- IC-17: navigates.jurisdiction_sequence_order > 0 (CHECK enforced)
-- INSERT INTO navigates (country_iso_code, boat_cni, reservation_start_date, reservation_end_date, trip_takeoff_date, trip_arrival_date, jurisdiction_name, jurisdiction_sequence_order) VALUES ('PRT','2020-001','2025-06-01','2025-06-07','2025-06-02','2025-06-02','Portuguese Internal Waters',0);
-- IC-19: Certification expiry_date > issue_date (CHECK enforced)
-- INSERT INTO Certification (sailor_id, issue_date, expiry_date) VALUES (1,'2025-01-10','2025-01-05');
