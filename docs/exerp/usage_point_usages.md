# usage_point_usages
Operational table for usage point usages records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `action_center` | Foreign key field linking this record to `usage_point_resources`. | `int4` | No | Yes | [usage_point_resources](usage_point_resources.md) via (`action_center`, `action_id` -> `center`, `id`) | - |
| `action_id` | Foreign key field linking this record to `usage_point_resources`. | `int4` | No | Yes | [usage_point_resources](usage_point_resources.md) via (`action_center`, `action_id` -> `center`, `id`) | - |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | Yes | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | Yes | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `TIME` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md), [usage_point_resources](usage_point_resources.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
