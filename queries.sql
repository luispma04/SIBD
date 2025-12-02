-- ========================================
-- SIBD 2025/2026 - Project Part 1
-- Boating Management System
-- SQL Queries
-- ========================================

-- ========================================
-- QUERY A
-- The name of all boats that are used in some trip
-- ========================================
SELECT DISTINCT b.name
FROM Boat b
INNER JOIN Reservation r ON b.cni = r.cni
INNER JOIN Trip t ON r.reservation_id = t.reservation_id
ORDER BY b.name;


-- ========================================
-- QUERY B
-- The name of all boats that are not used in any trip
-- ========================================
SELECT DISTINCT b.name
FROM Boat b
WHERE b.cni NOT IN (
    SELECT DISTINCT r.cni
    FROM Reservation r
    INNER JOIN Trip t ON r.reservation_id = t.reservation_id
)
ORDER BY b.name;


-- ========================================
-- QUERY C
-- The name of all boats registered in 'PRT' (ISO code) 
-- for which at least one responsible for a reservation 
-- has a surname that ends with 'Santos'
-- ========================================
SELECT DISTINCT b.name
FROM Boat b
INNER JOIN Reservation r ON b.cni = r.cni
INNER JOIN Sailor s ON r.responsible_sailor_id = s.sailor_id
WHERE b.iso_code = 'PRT'
  AND s.surname LIKE '%Santos'
ORDER BY b.name;


-- ========================================
-- QUERY D
-- The full name of all skippers without any certificate 
-- corresponding to the class of the trip's boat
-- ========================================
SELECT DISTINCT s.first_name || ' ' || s.surname AS full_name
FROM Sailor s
INNER JOIN Trip t ON s.sailor_id = t.skipper_id
INNER JOIN Reservation r ON t.reservation_id = r.reservation_id
INNER JOIN Boat b ON r.cni = b.cni
WHERE NOT EXISTS (
    SELECT 1
    FROM Certification c
    WHERE c.sailor_id = s.sailor_id
      AND c.class_id = b.class_id  -- match certification to boat class by id
      AND c.issue_date <= t.takeoff_date
      AND c.expiry_date >= t.takeoff_date
)
ORDER BY full_name;
