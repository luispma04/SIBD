-- ========================================
-- SIBD 2025/2026 - Project Part 1
-- Test Script to Generate Output
-- ========================================

-- Load schema
\i schema.sql

-- Populate database
\i populate.sql

-- Execute queries and show results
\echo ''
\echo '========================================='
\echo 'QUERY A: Boats used in some trip'
\echo '========================================='
SELECT DISTINCT b.name
FROM Boat b
INNER JOIN Reservation r ON b.cni = r.cni
INNER JOIN Trip t ON r.reservation_id = t.reservation_id
ORDER BY b.name;

\echo ''
\echo '========================================='
\echo 'QUERY B: Boats not used in any trip'
\echo '========================================='
SELECT DISTINCT b.name
FROM Boat b
WHERE b.cni NOT IN (
    SELECT DISTINCT r.cni
    FROM Reservation r
    INNER JOIN Trip t ON r.reservation_id = t.reservation_id
)
ORDER BY b.name;

\echo ''
\echo '========================================='
\echo 'QUERY C: Portuguese boats with Santos responsible'
\echo '========================================='
SELECT DISTINCT b.name
FROM Boat b
INNER JOIN Reservation r ON b.cni = r.cni
INNER JOIN Sailor s ON r.responsible_sailor_id = s.sailor_id
WHERE b.iso_code = 'PRT'
  AND s.surname LIKE '%Santos'
ORDER BY b.name;

\echo ''
\echo '========================================='
\echo 'QUERY D: Skippers without valid certification'
\echo '========================================='
SELECT DISTINCT s.first_name || ' ' || s.surname AS full_name
FROM Sailor s
INNER JOIN Trip t ON s.sailor_id = t.skipper_id
INNER JOIN Reservation r ON t.reservation_id = r.reservation_id
INNER JOIN Boat b ON r.cni = b.cni
WHERE NOT EXISTS (
    SELECT 1
    FROM Certification c
    WHERE c.sailor_id = s.sailor_id
      AND c.class_name = b.class_name
      AND c.issue_date <= CURRENT_DATE
      AND c.expiry_date >= CURRENT_DATE
)
ORDER BY full_name;
