# person_login_tokens
Stores historical/log records for personin tokens events and changes. It is typically used where it appears in approximately 2 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `created_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `token` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `usage_type` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (2 query files), [persons](persons.md) (2 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
