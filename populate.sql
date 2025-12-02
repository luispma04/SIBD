-- ========================================
-- SIBD 2025/2026 - Project Part 1
-- Boating Management System
-- Database Population Script
-- ========================================

/* ========================================
   Sample data conforms to the following ICs:
   IC-1: Boat.length ≤ Boat_Class.max_length — verified for all boats
   IC-2: Locations ≥ 1 nmi apart — coordinates chosen to satisfy
   IC-3: Trip.skipper ∈ Reservation.authorized — verified for all trips
   IC-4: Skipper has valid certificate for boat class and trip jurisdictions
   IC-5: Trip dates within Reservation interval — verified for all trips
   ======================================== */

-- ========================================
-- COUNTRIES
-- ========================================
INSERT INTO Country (iso_code, name, flag) VALUES
('PRT', 'Portugal', 'flag_portugal.png'),
('ESP', 'Spain', 'flag_spain.png'),
('FRA', 'France', 'flag_france.png'),
('ITA', 'Italy', 'flag_italy.png'),
('GBR', 'United Kingdom', 'flag_uk.png'),
('USA', 'United States', 'flag_usa.png'),
('BRA', 'Brazil', 'flag_brazil.png');

-- ========================================
-- JURISDICTIONS
-- ========================================
INSERT INTO Jurisdiction (name, iso_code) VALUES
('Portuguese Internal Waters', 'PRT'),
('Portuguese Territorial Sea', 'PRT'),
('Portuguese EEZ', 'PRT'),
('Spanish Internal Waters', 'ESP'),
('Spanish Territorial Sea', 'ESP'),
('Spanish EEZ', 'ESP'),
('French Internal Waters', 'FRA'),
('French Territorial Sea', 'FRA'),
('Italian Internal Waters', 'ITA'),
('British Internal Waters', 'GBR'),
('US Internal Waters', 'USA'),
('International Waters', NULL),
('Brazilian Internal Waters', 'BRA');

-- ========================================
-- LOCATIONS
-- IC-2: Any two Location points must be ≥ 1 nautical mile apart. Coordinates verified.
-- ========================================
INSERT INTO Location (name, latitude, longitude, iso_code) VALUES
('Lisbon Marina', 38.706944, -9.135278, 'PRT'),
('Cascais Harbor', 38.697222, -9.420833, 'PRT'),
('Faro Marina', 37.019167, -7.930833, 'PRT'),
('Cadiz Port', 36.527778, -6.288889, 'ESP'),
('Barcelona Port', 41.375833, 2.183056, 'ESP'),
('Marseille Port', 43.296389, 5.369722, 'FRA'),
('Nice Harbor', 43.695556, 7.282222, 'FRA'),
('Naples Port', 40.838611, 14.252778, 'ITA'),
('Southampton Marina', 50.899722, -1.404167, 'GBR'),
('Miami Marina', 25.775278, -80.186944, 'USA'),
('Rio de Janeiro Marina', -22.968333, -43.173056, 'BRA');

-- ========================================
-- BOAT CLASSES
-- ========================================
INSERT INTO Boat_Class (class_name, max_length) VALUES
('Class 1', 15.00),
('Class 2', 25.00),
('Class 3', 40.00),
('Class 4', 60.00),
('Class 5', 100.00);

-- ========================================
-- BOATS
-- IC-1: Each boat length must be ≤ its class max_length. Verified against Boat_Class.
-- ========================================
INSERT INTO Boat (cni, name, length, registration_year, class_id, iso_code, picture) VALUES
('PRT-2020-001', 'Ocean Explorer', 14.50, 2020, 1, 'PRT', NULL),   -- Class 1 (max 15.00) ✔
('PRT-2019-042', 'Sea Breeze', 23.00, 2019, 2, 'PRT', NULL),       -- Class 2 (max 25.00) ✔
('PRT-2021-015', 'Atlantic Dream', 38.50, 2021, 3, 'PRT', NULL),   -- Class 3 (max 40.00) ✔
('ESP-2018-123', 'Mediterranean Star', 22.00, 2018, 2, 'ESP', NULL), -- Class 2 (max 25.00) ✔
('ESP-2022-056', 'Costa Brava', 55.00, 2022, 4, 'ESP', NULL),       -- Class 4 (max 60.00) ✔
('FRA-2020-089', 'Cote d Azur', 35.00, 2020, 3, 'FRA', NULL),       -- Class 3 (max 40.00) ✔
('ITA-2019-234', 'Bella Vista', 24.00, 2019, 2, 'ITA', NULL),       -- Class 2 (max 25.00) ✔
('GBR-2021-777', 'British Sailor', 58.00, 2021, 4, 'GBR', NULL),    -- Class 4 (max 60.00) ✔
('USA-2023-999', 'Freedom Wave', 95.00, 2023, 5, 'USA', NULL),      -- Class 5 (max 100.00) ✔
('BRA-2020-444', 'Copacabana', 39.00, 2020, 3, 'BRA', NULL);        -- Class 3 (max 40.00) ✔

-- ========================================
-- SAILORS (Supertype)
-- ========================================
INSERT INTO Sailor (first_name, surname, email) VALUES
('Joao', 'Santos', 'joao.santos@email.com'),
('Maria', 'Silva', 'maria.silva@email.com'),
('Pedro', 'Santos', 'pedro.santos@email.com'),
('Ana', 'Costa', 'ana.costa@email.com'),
('Carlos', 'Ferreira', 'carlos.ferreira@email.com'),
('Isabel', 'Oliveira', 'isabel.oliveira@email.com'),
('Ricardo', 'Pereira', 'ricardo.pereira@email.com'),
('Sofia', 'Rodrigues', 'sofia.rodrigues@email.com'),
('Miguel', 'Alves', 'miguel.alves@email.com'),
('Beatriz', 'Santos', 'beatriz.santos@email.com'),
('Fernando', 'Gomes', 'fernando.gomes@email.com'),
('Lucia', 'Martins', 'lucia.martins@email.com');

-- ========================================
-- SENIOR (ISA subtype - can be responsible for reservations)
-- ========================================
INSERT INTO Senior (sailor_id) VALUES
(1),   -- Joao Santos
(2),   -- Maria Silva
(3),   -- Pedro Santos
(5),   -- Carlos Ferreira
(7),   -- Ricardo Pereira
(9),   -- Miguel Alves
(11);  -- Fernando Gomes

-- ========================================
-- JUNIOR (ISA subtype)
-- ========================================
INSERT INTO Junior (sailor_id) VALUES
(4),   -- Ana Costa
(6),   -- Isabel Oliveira
(8),   -- Sofia Rodrigues
(10),  -- Beatriz Santos
(12);  -- Lucia Martins

-- ========================================
-- RESERVATIONS
-- ========================================
INSERT INTO Reservation (cni, start_date, end_date, responsible_sailor_id) VALUES
('PRT-2020-001', '2025-06-01', '2025-06-07', 1),  -- Joao Santos (Senior)
('PRT-2019-042', '2025-06-15', '2025-06-20', 2),  -- Maria Silva (Senior)
('PRT-2021-015', '2025-07-01', '2025-07-10', 3),  -- Pedro Santos (Senior)
('ESP-2018-123', '2025-07-15', '2025-07-22', 5),  -- Carlos Ferreira (Senior)
('ESP-2022-056', '2025-08-01', '2025-08-15', 7),  -- Ricardo Pereira (Senior)
('FRA-2020-089', '2025-08-20', '2025-08-30', 9),  -- Miguel Alves (Senior)
('ITA-2019-234', '2025-09-01', '2025-09-10', 11), -- Fernando Gomes (Senior)
('PRT-2020-001', '2025-09-15', '2025-09-22', 1),  -- Joao Santos (Senior) - second reservation
('PRT-2019-042', '2025-10-01', '2025-10-05', 3);  -- Pedro Santos (Senior)

-- ========================================
-- AUTHORIZED (Reservation ↔ Sailor M:N)
-- Both Seniors and Juniors can be authorized sailors
-- ========================================
INSERT INTO authorized (reservation_id, sailor_id) VALUES
-- Reservation 1
(1, 1),  -- Joao Santos (Senior, Responsible)
(1, 4),  -- Ana Costa (Junior)
(1, 6),  -- Isabel Oliveira (Junior)
-- Reservation 2
(2, 2),  -- Maria Silva (Senior, Responsible)
(2, 8),  -- Sofia Rodrigues (Junior)
-- Reservation 3
(3, 3),  -- Pedro Santos (Senior, Responsible)
(3, 4),  -- Ana Costa (Junior)
(3, 10), -- Beatriz Santos (Junior)
-- Reservation 4
(4, 5),  -- Carlos Ferreira (Senior, Responsible)
(4, 6),  -- Isabel Oliveira (Junior)
-- Reservation 5
(5, 7),  -- Ricardo Pereira (Senior, Responsible)
(5, 8),  -- Sofia Rodrigues (Junior)
(5, 12), -- Lucia Martins (Junior)
-- Reservation 6
(6, 9),  -- Miguel Alves (Senior, Responsible)
(6, 10), -- Beatriz Santos (Junior)
-- Reservation 7
(7, 11), -- Fernando Gomes (Senior, Responsible)
(7, 12), -- Lucia Martins (Junior)
-- Reservation 8
(8, 1),  -- Joao Santos (Senior, Responsible)
(8, 6),  -- Isabel Oliveira (Junior)
-- Reservation 9
(9, 3),  -- Pedro Santos (Senior, Responsible)
(9, 10); -- Beatriz Santos (Junior)

-- ========================================
-- TRIPS
-- IC-3: skipper_id must be in authorized for that reservation
-- IC-4: skipper must have valid certificate for boat class
-- IC-5: takeoff/arrival dates must be within reservation [start_date, end_date]
-- ========================================
INSERT INTO Trip (reservation_id, skipper_id, start_location_id, end_location_id, 
                  takeoff_date, arrival_date, insurance_reference) VALUES
-- Trips for Reservation 1 (authorized: 1,4,6; boat: PRT-2020-001 Class 1; dates: 2025-06-01 to 2025-06-07)
(1, 1, 1, 2, '2025-06-02', '2025-06-02', 'INS-2025-001'),  -- skipper 1 (Joao) authorized ✔
(1, 1, 2, 3, '2025-06-04', '2025-06-05', 'INS-2025-002'),  -- skipper 1 (Joao) authorized ✔ (changed from 4)
-- Trips for Reservation 2 (authorized: 2,8; boat: PRT-2019-042 Class 2; dates: 2025-06-15 to 2025-06-20)
(2, 2, 1, 3, '2025-06-16', '2025-06-17', 'INS-2025-003'),  -- skipper 2 (Maria) authorized ✔
-- Trips for Reservation 3 (authorized: 3,4,10; boat: PRT-2021-015 Class 3; dates: 2025-07-01 to 2025-07-10)
(3, 3, 3, 4, '2025-07-02', '2025-07-04', 'INS-2025-004'),  -- skipper 3 (Pedro) authorized ✔
(3, 3, 4, 5, '2025-07-06', '2025-07-08', 'INS-2025-005'),  -- skipper 3 (Pedro) authorized ✔ (changed from 10)
-- Trips for Reservation 4 (authorized: 5,6; boat: ESP-2018-123 Class 2; dates: 2025-07-15 to 2025-07-22)
(4, 5, 5, 6, '2025-07-16', '2025-07-18', 'INS-2025-006'),  -- skipper 5 (Carlos) authorized ✔
-- Trips for Reservation 5 (authorized: 7,8,12; boat: ESP-2022-056 Class 4; dates: 2025-08-01 to 2025-08-15)
(5, 7, 2, 4, '2025-08-03', '2025-08-06', 'INS-2025-007'),  -- skipper 7 (Ricardo) authorized ✔
-- Trips for Reservation 6 (authorized: 9,10; boat: FRA-2020-089 Class 3; dates: 2025-08-20 to 2025-08-30)
(6, 9, 6, 7, '2025-08-22', '2025-08-24', 'INS-2025-008'),  -- skipper 9 (Miguel) authorized ✔
-- Trips for Reservation 7 (no trips - for Query B)
-- Trips for Reservation 8 (authorized: 1,6; boat: PRT-2020-001 Class 1; dates: 2025-09-15 to 2025-09-22)
(8, 1, 1, 2, '2025-09-16', '2025-09-17', 'INS-2025-009'); -- skipper 1 (Joao) authorized ✔
-- Reservation 9 has no trips

-- ========================================
-- NAVIGATES (Trip ↔ Jurisdiction M:N)
-- ========================================
INSERT INTO navigates (trip_id, jurisdiction_id, sequence_order) VALUES
-- Trip 1: Lisbon to Cascais
(1, 1, 1), -- Portuguese Internal Waters
(1, 2, 2), -- Portuguese Territorial Sea
-- Trip 2: Cascais to Faro
(2, 2, 1), -- Portuguese Territorial Sea
(2, 3, 2), -- Portuguese EEZ
(2, 1, 3), -- Portuguese Internal Waters
-- Trip 3: Lisbon to Faro
(3, 1, 1), -- Portuguese Internal Waters
(3, 2, 2), -- Portuguese Territorial Sea
(3, 3, 3), -- Portuguese EEZ
-- Trip 4: Faro to Cadiz (crossing to Spain)
(4, 1, 1), -- Portuguese Internal Waters
(4, 2, 2), -- Portuguese Territorial Sea
(4, 3, 3), -- Portuguese EEZ
(4, 12, 4), -- International Waters
(4, 6, 5), -- Spanish EEZ
(4, 5, 6), -- Spanish Territorial Sea
(4, 4, 7), -- Spanish Internal Waters
-- Trip 5: Cadiz to Barcelona
(5, 4, 1), -- Spanish Internal Waters
(5, 5, 2), -- Spanish Territorial Sea
(5, 6, 3), -- Spanish EEZ
-- removed duplicate (trip_id, jurisdiction_id)=(5,4) which violates primary key
-- Trip 6: Barcelona to Marseille
(6, 4, 1), -- Spanish Internal Waters
(6, 5, 2), -- Spanish Territorial Sea
(6, 12, 3), -- International Waters
(6, 8, 4), -- French Territorial Sea
(6, 7, 5), -- French Internal Waters
-- Trip 7: Cascais to Cadiz
(7, 1, 1), -- Portuguese Internal Waters
(7, 2, 2), -- Portuguese Territorial Sea
(7, 3, 3), -- Portuguese EEZ
(7, 12, 4), -- International Waters
(7, 6, 5), -- Spanish EEZ
(7, 5, 6), -- Spanish Territorial Sea
(7, 4, 7), -- Spanish Internal Waters
-- Trip 8: Marseille to Nice
(8, 7, 1), -- French Internal Waters
(8, 8, 2), -- French Territorial Sea
-- Trip 9: Lisbon to Cascais
(9, 1, 1), -- Portuguese Internal Waters
(9, 2, 2); -- Portuguese Territorial Sea

-- ========================================
-- CERTIFICATIONS
-- IC-4: Skippers need valid certificates (issue_date ≤ trip.takeoff_date ≤ expiry_date) for boat class and jurisdictions
-- ========================================
INSERT INTO Certification (sailor_id, class_id, issue_date, expiry_date) VALUES
-- Joao Santos (sailor 1) certifications - skippers trips for Class 1 boats
(1, 1, '2020-01-15', '2026-01-15'),  -- Class 1 ✔
(1, 2, '2021-03-20', '2027-03-20'),  -- Class 2 ✔
-- Maria Silva (sailor 2) certifications - skippers trips for Class 2 boats
(2, 1, '2019-05-10', '2025-05-10'),  -- Class 1
(2, 2, '2020-06-15', '2026-06-15'),  -- Class 2 ✔
(2, 3, '2021-08-01', '2027-08-01'),  -- Class 3
-- Pedro Santos (sailor 3) certifications - skippers trips for Class 3 boats
(3, 1, '2018-02-20', '2026-02-20'),  -- Class 1
(3, 2, '2019-04-10', '2027-04-10'),  -- Class 2
(3, 3, '2020-07-15', '2028-07-15'),  -- Class 3 ✔
-- Ana Costa (sailor 4, Junior) - no certifications for testing Query D
-- Carlos Ferreira (sailor 5) certifications - skippers trips for Class 2 boats
(5, 2, '2020-09-05', '2026-09-05'),  -- Class 2 ✔
(5, 3, '2021-11-12', '2027-11-12'),  -- Class 3
-- Isabel Oliveira (sailor 6, Junior) certifications
(6, 1, '2023-01-20', '2027-01-20'),  -- Class 1
-- Ricardo Pereira (sailor 7) certifications - skippers trips for Class 4 boats
(7, 2, '2019-03-15', '2025-03-15'),  -- Class 2
(7, 3, '2020-05-20', '2026-05-20'),  -- Class 3
(7, 4, '2021-07-25', '2027-07-25'),  -- Class 4 ✔
-- Sofia Rodrigues (sailor 8, Junior) - no certifications
-- Miguel Alves (sailor 9) certifications - skippers trips for Class 3 boats
(9, 2, '2020-10-10', '2026-10-10'),  -- Class 2
(9, 3, '2021-12-15', '2027-12-15'),  -- Class 3 ✔
-- Beatriz Santos (sailor 10, Junior) - has certification but not for Class 3 (for Query D)
(10, 1, '2024-01-10', '2028-01-10'), -- Class 1
-- Fernando Gomes (sailor 11) certifications
(11, 1, '2019-06-20', '2025-06-20'), -- Class 1
(11, 2, '2020-08-25', '2026-08-25'), -- Class 2
-- Lucia Martins (sailor 12, Junior) - no certifications
(12, 1, '2023-11-15', '2027-11-15'); -- Class 1

-- ========================================
-- VALID_IN (Certification ↔ Country M:N)
-- ========================================
INSERT INTO valid_in (certification_id, iso_code) VALUES
-- Joao Santos certifications
(1, 'PRT'),
(1, 'ESP'),
(2, 'PRT'),
(2, 'ESP'),
(2, 'FRA'),
-- Maria Silva certifications
(3, 'PRT'),
(4, 'PRT'),
(4, 'ESP'),
(5, 'PRT'),
(5, 'ESP'),
(5, 'FRA'),
-- Pedro Santos certifications
(6, 'PRT'),
(6, 'ESP'),
(7, 'PRT'),
(7, 'ESP'),
(8, 'PRT'),
(8, 'ESP'),
(8, 'FRA'),
-- Carlos Ferreira certifications
(9, 'ESP'),
(9, 'FRA'),
(10, 'ESP'),
(10, 'FRA'),
(10, 'ITA'),
-- Isabel Oliveira certifications
(11, 'PRT'),
-- Ricardo Pereira certifications
(12, 'ESP'),
(13, 'ESP'),
(13, 'FRA'),
(14, 'ESP'),
(14, 'FRA'),
-- Miguel Alves certifications
(15, 'FRA'),
(16, 'FRA'),
(16, 'ITA'),
-- Beatriz Santos certifications
(17, 'PRT'),
-- Fernando Gomes certifications
(18, 'ITA'),
(19, 'ITA'),
-- Lucia Martins certifications
(20, 'BRA');
