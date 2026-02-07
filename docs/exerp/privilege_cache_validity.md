# privilege_cache_validity
Intermediate/cache table used to accelerate privilege cache validity processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | Yes | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | Yes | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - | `1001` |
| `is_valid` | Boolean flag indicating whether valid applies. | `bool` | No | No | - | - | `true` |
| `TIME` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md); incoming FK from [privilege_cache](privilege_cache.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
