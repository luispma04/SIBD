-- ========================================
-- SIBD 2025/2026 - Project Part 1
-- Boating Management System
-- Database Population Script
-- ========================================

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
-- ========================================
INSERT INTO Boat (cni, name, length, registration_year, class_name, iso_code, picture) VALUES
('PRT-2020-001', 'Ocean Explorer', 14.50, 2020, 'Class 1', 'PRT', NULL),
('PRT-2019-042', 'Sea Breeze', 23.00, 2019, 'Class 2', 'PRT', NULL),
('PRT-2021-015', 'Atlantic Dream', 38.50, 2021, 'Class 3', 'PRT', NULL),
('ESP-2018-123', 'Mediterranean Star', 22.00, 2018, 'Class 2', 'ESP', NULL),
('ESP-2022-056', 'Costa Brava', 55.00, 2022, 'Class 4', 'ESP', NULL),
('FRA-2020-089', 'Cote d Azur', 35.00, 2020, 'Class 3', 'FRA', NULL),
('ITA-2019-234', 'Bella Vista', 24.00, 2019, 'Class 2', 'ITA', NULL),
('GBR-2021-777', 'British Sailor', 58.00, 2021, 'Class 4', 'GBR', NULL),
('USA-2023-999', 'Freedom Wave', 95.00, 2023, 'Class 5', 'USA', NULL),
('BRA-2020-444', 'Copacabana', 39.00, 2020, 'Class 3', 'BRA', NULL);

-- ========================================
-- SAILORS
-- ========================================
INSERT INTO Sailor (first_name, surname, email, category) VALUES
('Joao', 'Santos', 'joao.santos@email.com', 'Senior'),
('Maria', 'Silva', 'maria.silva@email.com', 'Senior'),
('Pedro', 'Santos', 'pedro.santos@email.com', 'Senior'),
('Ana', 'Costa', 'ana.costa@email.com', 'Junior'),
('Carlos', 'Ferreira', 'carlos.ferreira@email.com', 'Senior'),
('Isabel', 'Oliveira', 'isabel.oliveira@email.com', 'Junior'),
('Ricardo', 'Pereira', 'ricardo.pereira@email.com', 'Senior'),
('Sofia', 'Rodrigues', 'sofia.rodrigues@email.com', 'Junior'),
('Miguel', 'Alves', 'miguel.alves@email.com', 'Senior'),
('Beatriz', 'Santos', 'beatriz.santos@email.com', 'Junior'),
('Fernando', 'Gomes', 'fernando.gomes@email.com', 'Senior'),
('Lucia', 'Martins', 'lucia.martins@email.com', 'Junior');

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
-- RESERVATION_SAILOR (Authorized Sailors)
-- ========================================
INSERT INTO Reservation_Sailor (reservation_id, sailor_id) VALUES
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
-- ========================================
INSERT INTO Trip (reservation_id, skipper_id, start_location_id, end_location_id, 
                  takeoff_date, arrival_date, insurance_reference) VALUES
-- Trips for Reservation 1
(1, 1, 1, 2, '2025-06-02', '2025-06-02', 'INS-2025-001'),
(1, 4, 2, 3, '2025-06-04', '2025-06-05', 'INS-2025-002'),
-- Trips for Reservation 2
(2, 2, 1, 3, '2025-06-16', '2025-06-17', 'INS-2025-003'),
-- Trips for Reservation 3
(3, 3, 3, 4, '2025-07-02', '2025-07-04', 'INS-2025-004'),
(3, 10, 4, 5, '2025-07-06', '2025-07-08', 'INS-2025-005'),
-- Trips for Reservation 4
(4, 5, 5, 6, '2025-07-16', '2025-07-18', 'INS-2025-006'),
-- Trips for Reservation 5
(5, 7, 2, 4, '2025-08-03', '2025-08-06', 'INS-2025-007'),
-- Trips for Reservation 6
(6, 9, 6, 7, '2025-08-22', '2025-08-24', 'INS-2025-008'),
-- Trips for Reservation 7 (no trips - for Query B)
-- Trips for Reservation 8
(8, 1, 1, 2, '2025-09-16', '2025-09-17', 'INS-2025-009');
-- Reservation 9 has no trips

-- ========================================
-- TRIP_JURISDICTION
-- ========================================
INSERT INTO Trip_Jurisdiction (trip_id, jurisdiction_id, sequence_order) VALUES
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
(5, 4, 4), -- Spanish Internal Waters
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
(8, 7, 3), -- French Internal Waters
-- Trip 9: Lisbon to Cascais
(9, 1, 1), -- Portuguese Internal Waters
(9, 2, 2); -- Portuguese Territorial Sea

-- ========================================
-- CERTIFICATIONS
-- ========================================
INSERT INTO Certification (sailor_id, class_name, issue_date, expiry_date) VALUES
-- Joao Santos certifications
(1, 'Class 1', '2020-01-15', '2026-01-15'),
(1, 'Class 2', '2021-03-20', '2027-03-20'),
-- Maria Silva certifications
(2, 'Class 1', '2019-05-10', '2025-05-10'),
(2, 'Class 2', '2020-06-15', '2026-06-15'),
(2, 'Class 3', '2021-08-01', '2027-08-01'),
-- Pedro Santos certifications
(3, 'Class 1', '2018-02-20', '2026-02-20'),
(3, 'Class 2', '2019-04-10', '2027-04-10'),
(3, 'Class 3', '2020-07-15', '2028-07-15'),
-- Ana Costa (Junior) - no certifications for testing Query D
-- Carlos Ferreira certifications
(5, 'Class 2', '2020-09-05', '2026-09-05'),
(5, 'Class 3', '2021-11-12', '2027-11-12'),
-- Isabel Oliveira (Junior) certifications
(6, 'Class 1', '2023-01-20', '2027-01-20'),
-- Ricardo Pereira certifications
(7, 'Class 2', '2019-03-15', '2025-03-15'),
(7, 'Class 3', '2020-05-20', '2026-05-20'),
(7, 'Class 4', '2021-07-25', '2027-07-25'),
-- Sofia Rodrigues (Junior) - no certifications
-- Miguel Alves certifications
(9, 'Class 2', '2020-10-10', '2026-10-10'),
(9, 'Class 3', '2021-12-15', '2027-12-15'),
-- Beatriz Santos (Junior) - has certification but not for Class 3 (for Query D)
(10, 'Class 1', '2024-01-10', '2028-01-10'),
-- Fernando Gomes certifications
(11, 'Class 1', '2019-06-20', '2025-06-20'),
(11, 'Class 2', '2020-08-25', '2026-08-25'),
-- Lucia Martins (Junior) - no certifications
(12, 'Class 1', '2023-11-15', '2027-11-15');

-- ========================================
-- CERTIFICATION_JURISDICTION
-- ========================================
INSERT INTO Certification_Jurisdiction (certification_id, iso_code) VALUES
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
