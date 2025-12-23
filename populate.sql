-- ========================================
-- SIBD 2025/2026 - Part 2 population adapted to schema-part2.sql
-- Note: table/column names follow schema-part2.sql (lowercase).
-- Jurisdiction and navigates tables are not present in part2 schema; those concepts
-- are represented in 'valid_for' and trip/location rows below.
-- ========================================

-- COUNTRIES
INSERT INTO country (iso_code, flag, name) VALUES
('PRT', 'https://example.com/countries/portugal_flag.jpg', 'Portugal'),
('ESP', 'https://example.com/countries/spain_flag.jpg', 'Spain'),
('FRA', 'https://example.com/countries/france_flag.jpg', 'France'),
('ITA', 'https://example.com/countries/italy_flag.jpg', 'Italy'),
('GBR', 'https://example.com/countries/uk_flag.jpg', 'United Kingdom'),
('USA', 'https://example.com/countries/usa_flag.jpg', 'United States'),
('BRA', 'https://example.com/countries/brazil_flag.jpg', 'Brazil');

-- LOCATIONS (each row includes the country_name foreign key)
INSERT INTO location (latitude, longitude, name, country_name) VALUES
(38.706944, -9.135278, 'Lisbon Marina', 'Portugal'),
(38.697222, -9.420833, 'Cascais Harbor', 'Portugal'),
(37.019167, -7.930833, 'Faro Marina', 'Portugal'),
(36.527778, -6.288889, 'Cadiz Port', 'Spain'),
(41.375833,  2.183056, 'Barcelona Port', 'Spain'),
(43.296389,  5.369722, 'Marseille Port', 'France'),
(43.695556,  7.282222, 'Nice Harbor', 'France'),
(40.838611, 14.252778, 'Naples Port', 'Italy'),
(50.899722, -1.404167, 'Southampton Marina', 'United Kingdom'),
(25.775278, -80.186944,'Miami Marina', 'United States'),
(-22.968333,-43.173056,'Rio de Janeiro Marina', 'Brazil');

-- BOAT CLASSES
INSERT INTO boat_class (name, max_length) VALUES
('Class 1', 15.00),
('Class 2', 25.00),
('Class 3', 40.00),
('Class 4', 60.00),
('Class 5', 100.00);

-- BOATS (schema: country references country.name)
INSERT INTO boat (cni, country, boat_class, name, length, year) VALUES
('2020-001', 'Portugal', 'Class 1', 'Ocean Explorer',     14.50, 2020),
('2019-042', 'Portugal', 'Class 2', 'Sea Breeze',         23.00, 2019),
('2021-015', 'Portugal', 'Class 3', 'Atlantic Dream',     38.50, 2021),
('2018-123', 'Spain',    'Class 2', 'Mediterranean Star', 22.00, 2018),
('2022-056', 'Spain',    'Class 4', 'Costa Brava',        55.00, 2022),
('2020-089', 'France',   'Class 3', 'Cote d Azur',        35.00, 2020),
('2019-234', 'Italy',    'Class 2', 'Bella Vista',        24.00, 2019),
('2021-777', 'United Kingdom', 'Class 4', 'British Sailor',58.00, 2021),
('2023-999', 'United States',  'Class 5', 'Freedom Wave', 95.00, 2023),
('2020-444', 'Brazil',   'Class 3', 'Copacabana',         39.00, 2020);

-- SAILORS
INSERT INTO sailor (firstname, surname, email) VALUES
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

-- SENIOR / JUNIOR (schema stores emails)
INSERT INTO senior (email) VALUES
('joao.santos@email.com'),
('maria.silva@email.com'),
('pedro.santos@email.com'),
('carlos.ferreira@email.com'),
('ricardo.pereira@email.com'),
('miguel.alves@email.com'),
('fernando.gomes@email.com');

INSERT INTO junior (email) VALUES
('ana.costa@email.com'),
('isabel.oliveira@email.com'),
('sofia.rodrigues@email.com'),
('beatriz.santos@email.com'),
('lucia.martins@email.com');

-- DATE_INTERVAL rows: insert all used reservation intervals
INSERT INTO date_interval (start_date, end_date) VALUES
('2025-06-01','2025-06-07'),
('2025-06-15','2025-06-20'),
('2025-07-01','2025-07-10'),
('2025-07-15','2025-07-22'),
('2025-08-01','2025-08-15'),
('2025-08-20','2025-08-30'),
('2025-09-01','2025-09-10'),
('2025-09-15','2025-09-22'),
('2025-10-01','2025-10-05');

-- RESERVATIONS (use country names and cni)
INSERT INTO reservation (start_date, end_date, country, cni, responsible) VALUES
('2025-06-01','2025-06-07','Portugal','2020-001','joao.santos@email.com'),
('2025-06-15','2025-06-20','Portugal','2019-042','maria.silva@email.com'),
('2025-07-01','2025-07-10','Portugal','2021-015','pedro.santos@email.com'),
('2025-07-15','2025-07-22','Spain','2018-123','carlos.ferreira@email.com'),
('2025-08-01','2025-08-15','Spain','2022-056','ricardo.pereira@email.com'),
('2025-08-20','2025-08-30','France','2020-089','miguel.alves@email.com'),
('2025-09-01','2025-09-10','Italy','2019-234','fernando.gomes@email.com'),
('2025-09-15','2025-09-22','Portugal','2020-001','joao.santos@email.com'),
('2025-10-01','2025-10-05','Portugal','2019-042','pedro.santos@email.com');

-- AUTHORISED (reservation sailors) - use emails for sailors
-- Reservation 1
INSERT INTO authorised (start_date, end_date, boat_country, cni, sailor) VALUES
('2025-06-01','2025-06-07','Portugal','2020-001','joao.santos@email.com'),
('2025-06-01','2025-06-07','Portugal','2020-001','ana.costa@email.com'),
('2025-06-01','2025-06-07','Portugal','2020-001','isabel.oliveira@email.com');

-- Reservation 2
INSERT INTO authorised (start_date, end_date, boat_country, cni, sailor) VALUES
('2025-06-15','2025-06-20','Portugal','2019-042','maria.silva@email.com'),
('2025-06-15','2025-06-20','Portugal','2019-042','sofia.rodrigues@email.com');

-- Reservation 3
INSERT INTO authorised (start_date, end_date, boat_country, cni, sailor) VALUES
('2025-07-01','2025-07-10','Portugal','2021-015','pedro.santos@email.com'),
('2025-07-01','2025-07-10','Portugal','2021-015','ana.costa@email.com'),
('2025-07-01','2025-07-10','Portugal','2021-015','beatriz.santos@email.com');

-- Reservation 4
INSERT INTO authorised (start_date, end_date, boat_country, cni, sailor) VALUES
('2025-07-15','2025-07-22','Spain','2018-123','carlos.ferreira@email.com'),
('2025-07-15','2025-07-22','Spain','2018-123','isabel.oliveira@email.com');

-- Reservation 5
INSERT INTO authorised (start_date, end_date, boat_country, cni, sailor) VALUES
('2025-08-01','2025-08-15','Spain','2022-056','ricardo.pereira@email.com'),
('2025-08-01','2025-08-15','Spain','2022-056','sofia.rodrigues@email.com'),
('2025-08-01','2025-08-15','Spain','2022-056','lucia.martins@email.com');

-- Reservation 6
INSERT INTO authorised (start_date, end_date, boat_country, cni, sailor) VALUES
('2025-08-20','2025-08-30','France','2020-089','miguel.alves@email.com'),
('2025-08-20','2025-08-30','France','2020-089','beatriz.santos@email.com');

-- Reservation 7
INSERT INTO authorised (start_date, end_date, boat_country, cni, sailor) VALUES
('2025-09-01','2025-09-10','Italy','2019-234','fernando.gomes@email.com'),
('2025-09-01','2025-09-10','Italy','2019-234','lucia.martins@email.com');

-- Reservation 8
INSERT INTO authorised (start_date, end_date, boat_country, cni, sailor) VALUES
('2025-09-15','2025-09-22','Portugal','2020-001','joao.santos@email.com'),
('2025-09-15','2025-09-22','Portugal','2020-001','isabel.oliveira@email.com');

-- Reservation 9
INSERT INTO authorised (start_date, end_date, boat_country, cni, sailor) VALUES
('2025-10-01','2025-10-05','Portugal','2019-042','pedro.santos@email.com'),
('2025-10-01','2025-10-05','Portugal','2019-042','beatriz.santos@email.com');

-- TRIPS (schema column names: takeoff, arrival, insurance, from_latitude, from_longitude,
-- to_latitude, to_longitude, skipper, reservation_start_date, reservation_end_date, boat_country, cni)
INSERT INTO trip (
	takeoff, arrival, insurance, from_latitude, from_longitude, to_latitude, to_longitude,
	skipper, reservation_start_date, reservation_end_date, boat_country, cni
) VALUES
('2025-06-02','2025-06-02','INS-2025-001', 38.706944,-9.135278, 38.697222,-9.420833, 'joao.santos@email.com','2025-06-01','2025-06-07','Portugal','2020-001'),
('2025-06-04','2025-06-05','INS-2025-002', 38.697222,-9.420833, 37.019167,-7.930833, 'joao.santos@email.com','2025-06-01','2025-06-07','Portugal','2020-001'),
('2025-06-16','2025-06-17','INS-2025-003', 38.706944,-9.135278, 37.019167,-7.930833, 'maria.silva@email.com','2025-06-15','2025-06-20','Portugal','2019-042'),
('2025-07-02','2025-07-04','INS-2025-004', 37.019167,-7.930833, 36.527778,-6.288889, 'pedro.santos@email.com','2025-07-01','2025-07-10','Portugal','2021-015'),
('2025-07-06','2025-07-08','INS-2025-005', 36.527778,-6.288889, 41.375833, 2.183056, 'pedro.santos@email.com','2025-07-01','2025-07-10','Portugal','2021-015'),
('2025-07-16','2025-07-18','INS-2025-006', 36.527778,-6.288889, 41.375833, 2.183056, 'carlos.ferreira@email.com','2025-07-15','2025-07-22','Spain','2018-123'),
('2025-08-03','2025-08-06','INS-2025-007', 41.375833,2.183056, 43.296389,5.369722, 'ricardo.pereira@email.com','2025-08-01','2025-08-15','Spain','2022-056'),
('2025-08-22','2025-08-24','INS-2025-008', 43.296389,5.369722, 43.695556,7.282222, 'miguel.alves@email.com','2025-08-20','2025-08-30','France','2020-089'),
('2025-09-16','2025-09-17','INS-2025-009', 38.706944,-9.135278, 38.697222,-9.420833, 'joao.santos@email.com','2025-09-15','2025-09-22','Portugal','2020-001');

-- SAILING CERTIFICATES (sailing_certificate table)
INSERT INTO sailing_certificate (sailor, issue_date, expiry_date, boat_class) VALUES
('joao.santos@email.com','2020-01-15','2026-01-15','Class 1'),
('joao.santos@email.com','2021-03-20','2027-03-20','Class 2'),
('maria.silva@email.com','2019-05-10','2025-05-10','Class 1'),
('maria.silva@email.com','2020-06-15','2026-06-15','Class 2'),
('maria.silva@email.com','2021-08-01','2027-08-01','Class 3'),
('pedro.santos@email.com','2018-02-20','2026-02-20','Class 1'),
('pedro.santos@email.com','2019-04-10','2027-04-10','Class 2'),
('pedro.santos@email.com','2020-07-15','2028-07-15','Class 3'),
('carlos.ferreira@email.com','2020-09-05','2026-09-05','Class 2'),
('carlos.ferreira@email.com','2021-11-12','2027-11-12','Class 3'),
('isabel.oliveira@email.com','2023-01-20','2027-01-20','Class 1'),
('ricardo.pereira@email.com','2019-03-15','2025-03-15','Class 2'),
('ricardo.pereira@email.com','2020-05-20','2026-05-20','Class 3'),
('ricardo.pereira@email.com','2021-07-25','2027-07-25','Class 4'),
('miguel.alves@email.com','2020-10-10','2026-10-10','Class 2'),
('miguel.alves@email.com','2021-12-15','2027-12-15','Class 3'),
('beatriz.santos@email.com','2024-01-10','2028-01-10','Class 1'),
('fernando.gomes@email.com','2019-06-20','2025-06-20','Class 1'),
('fernando.gomes@email.com','2020-08-25','2026-08-25','Class 2'),
('fernando.gomes@email.com','2021-11-02','2027-11-02','Class 3'),
('lucia.martins@email.com','2023-11-15','2027-11-15','Class 1');

-- VALID_FOR (associates certificates to countries / max length where relevant)
-- Note: valid_for PK is (country_name, sailor, issue_date)
INSERT INTO valid_for (country_name, max_length, sailor, issue_date) VALUES
('Portugal', 15.00, 'joao.santos@email.com','2020-01-15'),
('Spain',   15.00, 'joao.santos@email.com','2020-01-15'),
('Portugal',15.00, 'joao.santos@email.com','2021-03-20'),
('Spain',   25.00, 'joao.santos@email.com','2021-03-20'),
('France',  25.00, 'joao.santos@email.com','2021-03-20'),

('Portugal',15.00, 'maria.silva@email.com','2019-05-10'),
('Portugal',25.00, 'maria.silva@email.com','2020-06-15'),
('Spain',   25.00, 'maria.silva@email.com','2020-06-15'),
('Portugal',40.00, 'maria.silva@email.com','2021-08-01'),
('Spain',   40.00, 'maria.silva@email.com','2021-08-01'),
('France',  40.00, 'maria.silva@email.com','2021-08-01'),

('Portugal',15.00,'pedro.santos@email.com','2018-02-20'),
('Spain',   15.00,'pedro.santos@email.com','2018-02-20'),
('Portugal',25.00,'pedro.santos@email.com','2019-04-10'),
('Spain',   25.00,'pedro.santos@email.com','2019-04-10'),
('Portugal',40.00,'pedro.santos@email.com','2020-07-15'),
('Spain',   40.00,'pedro.santos@email.com','2020-07-15'),
('France',  40.00,'pedro.santos@email.com','2020-07-15'),

('Spain',   25.00,'carlos.ferreira@email.com','2020-09-05'),
('France',  40.00,'carlos.ferreira@email.com','2021-11-12'),

('Portugal',15.00,'isabel.oliveira@email.com','2023-01-20'),

('Spain',   25.00,'ricardo.pereira@email.com','2019-03-15'),
('France',  40.00,'ricardo.pereira@email.com','2020-05-20'),
('Spain',   40.00,'ricardo.pereira@email.com','2021-07-25'),

('France',  25.00,'miguel.alves@email.com','2020-10-10'),

('Portugal',15.00,'beatriz.santos@email.com','2024-01-10'),

('Italy',   15.00,'fernando.gomes@email.com','2019-06-20'),

('Brazil',  15.00,'lucia.martins@email.com','2023-11-15');

