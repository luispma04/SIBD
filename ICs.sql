-- =============================================================================
-- IC-1: Every Sailor is either Senior or Junior
-- =============================================================================
-- Enforces that every sailor must be classified as either senior or junior (mandatory)
-- and cannot be both (disjoint). Checked at transaction commit time.
CREATE OR REPLACE FUNCTION check_sailor_classification()
RETURNS TRIGGER AS
$$
DECLARE
    is_senior BOOLEAN;
    is_junior BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM senior WHERE email = NEW.email) INTO is_senior;
    SELECT EXISTS(SELECT 1 FROM junior WHERE email = NEW.email) INTO is_junior;
    
    IF NOT (is_senior OR is_junior) THEN
        RAISE EXCEPTION 'Sailor with email % must be classified as either Senior or Junior', NEW.email
        USING HINT = 'Insert the sailor into senior or junior table within the same transaction';
    END IF;
    
    IF is_senior AND is_junior THEN
        RAISE EXCEPTION 'Sailor with email % cannot be both Senior and Junior', NEW.email
        USING HINT = 'A sailor must be in only one classification table';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_check_sailor_insert
AFTER INSERT ON sailor
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE check_sailor_classification();

CREATE CONSTRAINT TRIGGER trg_check_sailor_update
AFTER UPDATE ON sailor
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE check_sailor_classification();

-- Prevents a sailor from being in both senior and junior tables (disjoint constraint)
-- Fails immediately when attempting to insert into the second classification table.
CREATE OR REPLACE FUNCTION check_disjoint_classification()
RETURNS TRIGGER AS
$$
DECLARE
    other_table TEXT;
    is_in_other BOOLEAN;
BEGIN
    -- name of the table that fired the trigger
    IF TG_TABLE_NAME = 'senior' THEN
        other_table := 'junior';
        SELECT EXISTS(SELECT 1 FROM junior WHERE email = NEW.email) INTO is_in_other;
    ELSE
        other_table := 'senior';
        SELECT EXISTS(SELECT 1 FROM senior WHERE email = NEW.email) INTO is_in_other;
    END IF;
    
    IF is_in_other THEN
        RAISE EXCEPTION 'Sailor % is already in % table, cannot be in % (disjoint specialization)', 
            NEW.email, other_table, TG_TABLE_NAME
        USING HINT = 'A sailor must be either Senior OR Junior, not both';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_disjoint_senior_insert
BEFORE INSERT ON senior
FOR EACH ROW
EXECUTE PROCEDURE check_disjoint_classification();

CREATE TRIGGER trg_check_disjoint_junior_insert
BEFORE INSERT ON junior
FOR EACH ROW
EXECUTE PROCEDURE check_disjoint_classification();

-- =============================================================================
-- IC-2: Trip dates must not overlap for the same boat
-- =============================================================================

-- Ensures that trips using the same boat do not have overlapping date ranges
-- A boat can only be in one place at a time, so trips for the same boat cannot overlap
CREATE OR REPLACE FUNCTION check_trip_overlap()
RETURNS TRIGGER AS
$
BEGIN
    IF NEW.takeoff >= NEW.arrival THEN
        RAISE EXCEPTION 'Trip takeoff date (%) must be before arrival date (%)', 
            NEW.takeoff, NEW.arrival
        USING HINT = 'Check the dates for this trip';
    END IF;
    
    IF EXISTS (
        SELECT 1
        FROM trip
        WHERE boat_country = NEW.boat_country
          AND cni = NEW.cni
          AND takeoff != NEW.takeoff
          AND NEW.takeoff < arrival
          AND takeoff < NEW.arrival
    ) THEN
        RAISE EXCEPTION 'Boat (%, %) already has a trip from % to % that overlaps with this trip (% to %)', 
            NEW.boat_country, NEW.cni,
            (SELECT takeoff FROM trip 
             WHERE boat_country = NEW.boat_country AND cni = NEW.cni 
             AND NEW.takeoff < arrival AND takeoff < NEW.arrival LIMIT 1),
            (SELECT arrival FROM trip 
             WHERE boat_country = NEW.boat_country AND cni = NEW.cni 
             AND NEW.takeoff < arrival AND takeoff < NEW.arrival LIMIT 1),
            NEW.takeoff, NEW.arrival
        USING HINT = 'A boat can only be used for one trip at a time';
    END IF;
    
    RETURN NEW;
END;
$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_check_trip_overlap_insert
AFTER INSERT ON trip
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE check_trip_overlap();

CREATE CONSTRAINT TRIGGER trg_check_trip_overlap_update
AFTER UPDATE ON trip
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW
EXECUTE PROCEDURE check_trip_overlap();