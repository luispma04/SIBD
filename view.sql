CREATE OR REPLACE VIEW trip_info AS
SELECT
    c_orig.iso_code AS country_iso_origin,
    c_orig.name AS country_name_origin,

    c_dest.iso_code AS country_iso_dest,
    c_dest.name AS country_name_dest,

    l_orig.name AS loc_name_origin,
    l_dest.name AS loc_name_dest,

    t.cni AS cni_boat,

    c_boat.iso_code AS country_iso_boat,
    c_boat.name AS country_name_boat,

    t.takeoff  AS trip_start_date

FROM trip t

-- Local de origem
JOIN location l_orig
  ON t.from_latitude  = l_orig.latitude
 AND t.from_longitude = l_orig.longitude

-- Local de destino
JOIN location l_dest
  ON t.to_latitude  = l_dest.latitude
 AND t.to_longitude = l_dest.longitude

-- País da origem
JOIN country c_orig
  ON l_orig.country_name = c_orig.name

-- País do destino
JOIN country c_dest
  ON l_dest.country_name = c_dest.name

-- Barco
JOIN boat b
  ON t.boat_country = b.country
 AND t.cni          = b.cni

-- País do barco
JOIN country c_boat
  ON b.country = c_boat.name;