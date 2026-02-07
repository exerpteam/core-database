# customer_credit_note
Operational table for customer credit note records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `reference_center` | Center component of the composite reference to the related reference record. | `int4` | No | No | - | - |
| `reference_id` | Identifier component of the composite reference to the related reference record. | `int4` | No | No | - | - |
| `issued_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int8` | No | No | - | - |
| `created_by_emp_center` | Center component of the composite reference to the related created by emp record. | `int4` | No | No | - | - |
| `created_by_emp_id` | Identifier component of the composite reference to the related created by emp record. | `int4` | No | No | - | - |
| `formatted_doc_mimetype` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(200)` | Yes | No | - | - |
| `formatted_doc_mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
