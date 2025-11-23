# SIBD 2025/2026 - Project Assignment Part 1
## Boating Management System

### Project Overview
This project implements a comprehensive database system for managing boat reservations, trips, sailor certifications, and maritime jurisdictions.

---

## Files Delivered

### 1. `schema.sql`
- Complete SQL DDL schema definition
- Includes all tables with proper constraints (PK, FK, UNIQUE, NOT NULL, CHECK)
- Comments indicate integrity constraints that cannot be implemented in SQL
- Includes DROP statements for clean recreation
- Optimized indexes for query performance

### 2. `populate.sql`
- Comprehensive INSERT statements with realistic test data
- Covers all entities and relationships
- Designed to ensure all queries return non-empty results
- Includes:
  - 7 countries
  - 13 jurisdictions (including International Waters)
  - 11 locations
  - 5 boat classes
  - 10 boats
  - 12 sailors (6 Senior, 6 Junior)
  - 9 reservations
  - 9 trips
  - 20 certifications

### 3. `queries.sql`
- Four required SQL queries with clear comments:
  - **Query A**: Boats used in some trip
  - **Query B**: Boats NOT used in any trip
  - **Query C**: Portuguese boats with 'Santos' responsible
  - **Query D**: Skippers without valid certification for trip's boat class

### 4. `output.txt`
- Expected results for all four queries
- All queries return non-empty results as required

### 5. `cover.txt`
- Cover page information (needs to be converted to PDF)
- Complete Entity-Association model description
- List of entities and relationships
- Integrity constraints documentation
- Design decisions explained

---

## Key Database Features

### Entities
1. **Country** - Sovereign nations with ISO codes
2. **Jurisdiction** - Maritime zones (territorial, EEZ, international)
3. **Location** - Ports and marinas with GPS coordinates
4. **Boat_Class** - Vessel categories with max length limits
5. **Boat** - Registered vessels with unique CNI
6. **Sailor** - Users categorized as Senior or Junior
7. **Reservation** - Boat bookings with date ranges
8. **Trip** - Individual journeys under reservations
9. **Certification** - Sailor licenses for boat classes

### Key Relationships
- Sailors make joint reservations (many-to-many)
- Trips navigate multiple jurisdictions (many-to-many with order)
- Certifications valid in multiple countries (many-to-many)
- Reservations have one responsible Senior sailor
- Trips have one skipper from authorized sailors

### Important Constraints Implemented
✅ Primary keys on all tables
✅ Foreign keys with proper cascading
✅ NOT NULL on required fields
✅ CHECK constraints for data validation
✅ UNIQUE constraints (email, country name, boat class)
✅ Date range validation (end_date >= start_date)
✅ Sailor category enforcement (Senior/Junior)

### Constraints Documented (Not Fully Implementable in SQL)
⚠️ Responsible sailor must be Senior category
⚠️ Skipper must be authorized sailor for reservation
⚠️ Trip dates must fall within reservation dates
⚠️ Boat length must not exceed class max_length
⚠️ Locations must be 1+ nautical mile apart
⚠️ Minimum participation constraints (triggers needed)

---

## Query Explanations

### Query A - Boats Used in Trips
Returns boats that have at least one trip through the reservation-trip relationship.
**Strategy**: INNER JOIN from Boat → Reservation → Trip with DISTINCT

### Query B - Boats NOT Used in Trips
Returns boats with no trips using a NOT IN subquery.
**Strategy**: Exclude boats whose CNI appears in any reservation with trips

### Query C - Portuguese Boats with Santos Responsible
Filters boats registered in Portugal where the responsible sailor's surname ends with 'Santos'.
**Strategy**: JOIN Boat → Reservation → Sailor with country and name filters

### Query D - Skippers Without Valid Certification
Finds skippers operating trips without a valid (non-expired) certification for the boat's class.
**Strategy**: NOT EXISTS subquery checking for matching certification with date validation

---

## Testing the Database

### On PostgreSQL (db.tecnico.ulisboa.pt)

```bash
# Connect to PostgreSQL
psql -h db.tecnico.ulisboa.pt -U your_username -d your_database

# Run schema creation
\i schema.sql

# Populate database
\i populate.sql

# Execute queries
\i queries.sql
```

### Verify Data
```sql
-- Check record counts
SELECT 'Countries' as table_name, COUNT(*) FROM Country
UNION ALL SELECT 'Boats', COUNT(*) FROM Boat
UNION ALL SELECT 'Sailors', COUNT(*) FROM Sailor
UNION ALL SELECT 'Reservations', COUNT(*) FROM Reservation
UNION ALL SELECT 'Trips', COUNT(*) FROM Trip;
```

---

## Data Highlights for Testing

### For Query C (Portuguese boats with Santos responsible):
- **Joao Santos** (sailor_id=1) is responsible for:
  - PRT-2020-001 (Ocean Explorer) - Reservations 1, 8
- **Pedro Santos** (sailor_id=3) is responsible for:
  - PRT-2021-015 (Atlantic Dream) - Reservation 3
  - PRT-2019-042 (Sea Breeze) - Reservation 9

### For Query D (Skippers without certification):
- **Ana Costa** (sailor_id=4, Junior) skippers Trip 2 with boat PRT-2019-042 (Class 2) but has NO certifications
- **Beatriz Santos** (sailor_id=10, Junior) skippers Trip 5 with boat ESP-2022-056 (Class 4) but only certified for Class 1

---

## Entity-Association Model Design Notes

### Cognitive Efficiency Choices:
1. **Minimal redundancy** - No duplicate attributes across entities
2. **Clear naming** - Descriptive table and column names
3. **Appropriate granularity** - Separate entities for distinct concepts
4. **Proper normalization** - 3NF compliance throughout
5. **Explicit relationships** - Junction tables for many-to-many

### Conciseness:
- 12 tables total
- 3 junction tables for many-to-many relationships
- No unnecessary weak entities
- Attributes stored at appropriate levels

---

## Submission Checklist

- ✅ schema.sql - Complete and runnable
- ✅ populate.sql - Comprehensive test data
- ✅ queries.sql - All 4 queries implemented
- ✅ output.txt - Non-empty results for all queries
- ⚠️ cover.pdf - **YOU NEED TO CONVERT cover.txt TO PDF**

### To Complete:
1. **Create E-A Diagram** using a diagramming tool (draw.io, Lucidchart, etc.)
   - Use notation taught in class
   - Include all entities, relationships, cardinalities
   - Export as image or PDF

2. **Create cover.pdf** with:
   - Fill in your personal information in cover.txt
   - Convert to PDF (max 2 pages including E-A diagram)
   - Include the E-A diagram image

3. **Create submission ZIP**:
   ```
   submission-sidb-01-[GG].zip
   ├── cover.pdf
   ├── schema.sql
   ├── populate.sql
   ├── queries.sql
   └── output.txt
   ```

---

## Important Notes

⚠️ The E-A diagram MUST be drawn electronically
⚠️ Use the notation taught in your SIBD class
⚠️ Test all scripts on PostgreSQL before submission
⚠️ Ensure queries return non-empty results
⚠️ Follow the exact submission structure
⚠️ DO NOT submit in RAR format - only ZIP or GZ

---

## Contact & Support
If you need clarification on any design decisions or implementation details, review:
- The inline comments in schema.sql
- The integrity constraints documentation in cover.txt
- The data relationships in populate.sql

Good luck with your submission! 🚢⚓
