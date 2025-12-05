-- ========================================
-- SIBD 2025/2026 - Project Part 1
-- Boating Management System
-- SQL Queries
-- ========================================

-- ========================================
-- QUERY A
-- The name of all boats that are used in some trip
-- ========================================
SELECT DISTINCT boat1.name
FROM Boat boat1
INNER JOIN Reservation reservation1 ON boat1.country_iso_code = reservation1.country_iso_code AND boat1.cni = reservation1.boat_cni
INNER JOIN Trip trip1 ON reservation1.country_iso_code = trip1.country_iso_code 
                      AND reservation1.boat_cni = trip1.boat_cni 
                      AND reservation1.start_date = trip1.reservation_start_date 
                      AND reservation1.end_date = trip1.reservation_end_date
ORDER BY boat1.name;


-- ========================================
-- QUERY B
-- The name of all boats that are not used in any trip
-- ========================================
SELECT DISTINCT boat1.name
FROM Boat boat1
WHERE NOT EXISTS (
    SELECT 1
    FROM Reservation reservation1
    INNER JOIN Trip trip1 ON reservation1.country_iso_code = trip1.country_iso_code 
                          AND reservation1.boat_cni = trip1.boat_cni 
                          AND reservation1.start_date = trip1.reservation_start_date 
                          AND reservation1.end_date = trip1.reservation_end_date
    WHERE boat1.country_iso_code = reservation1.country_iso_code AND boat1.cni = reservation1.boat_cni
)
ORDER BY boat1.name;


-- ========================================
-- QUERY C
-- The name of all boats registered in 'PRT' (ISO code) 
-- for which at least one responsible for a reservation 
-- has a surname that ends with 'Santos'
-- ========================================
SELECT DISTINCT boat1.name
FROM Boat boat1
INNER JOIN Reservation reservation1 ON boat1.country_iso_code = reservation1.country_iso_code AND boat1.cni = reservation1.boat_cni
INNER JOIN Senior senior1 ON reservation1.responsible_for_sailor_id = senior1.senior_id
INNER JOIN Sailor sailor1 ON senior1.senior_id = sailor1.id
WHERE boat1.country_iso_code = 'PRT'
  AND sailor1.surname LIKE '%Santos'
ORDER BY boat1.name;


-- ========================================
-- QUERY D
-- The full name of all skippers without any certificate 
-- corresponding to the class of the trip's boat
-- ========================================
SELECT DISTINCT sailor1.first_name || ' ' || sailor1.surname AS full_name
FROM Sailor sailor1
INNER JOIN Trip trip1 ON sailor1.id = trip1.skippers_id
INNER JOIN Reservation reservation1 ON trip1.country_iso_code = reservation1.country_iso_code 
                                    AND trip1.boat_cni = reservation1.boat_cni 
                                    AND trip1.reservation_start_date = reservation1.start_date 
                                    AND trip1.reservation_end_date = reservation1.end_date
INNER JOIN Boat boat1 ON reservation1.country_iso_code = boat1.country_iso_code AND reservation1.boat_cni = boat1.cni
WHERE NOT EXISTS (
    SELECT 1
    FROM Certification certification1
    INNER JOIN certifies_for cert_class1 ON certification1.sailor_id = cert_class1.sailor_id 
                                         AND certification1.issue_date = cert_class1.certification_issue_date
    WHERE certification1.sailor_id = sailor1.id
      AND cert_class1.class_name = boat1.class_name
      AND certification1.issue_date <= trip1.takeoff_date
      AND certification1.expiry_date >= trip1.arrival_date
)
ORDER BY full_name;
