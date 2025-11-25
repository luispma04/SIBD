# Integrity Constraints - Diagram Legend

This file contains the concise one-line Integrity Constraint (IC) labels intended for the Chen diagram. The diagram should show only these short labels (e.g. `IC-1`) near related entities/relationships. The full natural‑language statements and suggested SQL enforcement live in `schema.sql` and the project documentation.

Place these short labels on the diagram (or in a small legend box). Keep the detailed descriptions and trigger/DDL examples in `schema.sql` / `README.md`.

Compact IC legend (one-line forms for diagram)

- IC-1: Boat.length ≤ Boat_Class.max_length
- IC-2: Locations ≥ 1 nmi apart (see docs)
- IC-3: Sailor.category ∈ {Senior, Junior}
- IC-4: Reservation.end_date ≥ Reservation.start_date
- IC-5: Trip.arrival_date ≥ Trip.takeoff_date
- IC-6: Trip.start_location ≠ Trip.end_location
- IC-7: Trip dates ⊆ Reservation interval
- IC-8: Responsible sailor must be Senior
- IC-9: Responsible sailor ∈ reservation.authorized
- IC-10: Reservation must have ≥1 authorized sailor
- IC-11: Skipper ∈ authorized; valid cert for boat_class & jurisdictions (see docs)
- IC-12: Certification.expiry_date > Certification.issue_date
- IC-13: Certification valid in ≥1 country/jurisdiction
- IC-14: NAVIGATES: sequence_order > 0; unique per trip
- IC-15: Country.iso_code/name/flag are UNIQUE
- IC-16: Country that registers boats must have ≥1 Location (conditional)
- IC-17: Structural keys & FKs (PKs, FKs, UNIQUEs) implemented in DDL

Notes:
- Use the short IC labels on the diagram and a small legend box to keep it readable.
- For complex checks (distance, skipper certification coverage, conditional country rule) reference the full text and enforcement scripts in `schema.sql`.
- If you want, the diagram can include a single pointer: “Full IC text & SQL in `IC_DETAILS.md` / `schema.sql`” and keep the diagram legend minimal.

---
Generated and committed by project assistant.
