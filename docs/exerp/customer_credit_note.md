# customer_credit_note
Operational table for customer credit note records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `reference_center` | Center part of the reference to related reference data. | `int4` | No | No | - | - | `101` |
| `reference_id` | Identifier of the related reference record. | `int4` | No | No | - | - | `1001` |
| `issued_date` | Date for issued. | `int8` | No | No | - | - | `42` |
| `created_by_emp_center` | Center part of the reference to related created by emp data. | `int4` | No | No | - | - | `101` |
| `created_by_emp_id` | Identifier of the related created by emp record. | `int4` | No | No | - | - | `1001` |
| `formatted_doc_mimetype` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - | `Sample value` |
| `formatted_doc_mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
