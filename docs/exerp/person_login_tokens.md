# person_login_tokens
Stores historical/log records for personin tokens events and changes. It is typically used where it appears in approximately 2 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `created_at` | Business attribute `created_at` used by person login tokens workflows and reporting. | `int8` | No | No | - | - |
| `token` | Business attribute `token` used by person login tokens workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `usage_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(30)` | No | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (2 query files), [persons](persons.md) (2 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
