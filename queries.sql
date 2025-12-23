-- QUERY 1: Which country has more boats registered than any other?
SELECT country
FROM boat
GROUP BY country
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM boat
    GROUP BY country
);

-- QUERY 2: List all sailors that have at least two certificates
SELECT sailor
FROM sailing_certificate
GROUP BY sailor
HAVING COUNT(*) >= 2;

-- QUERY 3: Who are the sailors that have sailed to every location in 'Portugal'?
SELECT a.sailor
FROM authorised a, trip t, location l
WHERE a.boat_country = t.boat_country
    AND a.cni = t.cni
    AND a.start_date = t.reservation_start_date
    AND a.end_date = t.reservation_end_date
    AND l.country_name = 'Portugal'
    AND ((l.latitude = t.to_latitude AND l.longitude = t.to_longitude)
         OR (l.latitude = t.from_latitude AND l.longitude = t.from_longitude))
GROUP BY a.sailor
HAVING COUNT(DISTINCT l.name) = (
    SELECT COUNT(*) 
    FROM location 
    WHERE country_name = 'Portugal');

-- QUERY 4: Sailors with the most skipped trips (acted as skipper most times)
SELECT skipper
FROM trip
GROUP BY skipper
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM trip
    GROUP BY skipper
);

-- QUERY 5: Sailors with longest total trip duration for a single reservation
SELECT a.sailor, SUM(t.arrival - t.takeoff) AS total_duration
FROM authorised a, trip t
WHERE a.boat_country = t.boat_country
    AND a.cni = t.cni
    AND a.start_date = t.reservation_start_date
    AND a.end_date = t.reservation_end_date
GROUP BY a.sailor, t.reservation_start_date, t.reservation_end_date, t.boat_country, t.cni
HAVING SUM(t.arrival - t.takeoff) >= ALL (
    SELECT SUM(t2.arrival - t2.takeoff)
    FROM authorised a2, trip t2
    WHERE a2.boat_country = t2.boat_country
        AND a2.cni = t2.cni
        AND a2.start_date = t2.reservation_start_date
        AND a2.end_date = t2.reservation_end_date
    GROUP BY a2.sailor, t2.reservation_start_date, t2.reservation_end_date, t2.boat_country, t2.cni
);

