# privilege_cache
Intermediate/cache table used to accelerate privilege cache processing. It is typically used where it appears in approximately 6 query files; common companions include [persons](persons.md), [privilege_grants](privilege_grants.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`)<br>[privilege_cache_validity](privilege_cache_validity.md) via (`person_center`, `person_id` -> `person_center`, `person_id`) | - | `101` |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`)<br>[privilege_cache_validity](privilege_cache_validity.md) via (`person_center`, `person_id` -> `person_center`, `person_id`) | - | `1001` |
| `privilege_id` | Identifier of the related privilege record. | `int4` | No | No | - | - | `1001` |
| `privilege_type` | Text field containing descriptive or reference information. | `VARCHAR(20)` | No | No | - | - | `Sample value` |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `valid_to` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `grant_id` | Foreign key field linking this record to `privilege_grants`. | `int4` | No | No | [privilege_grants](privilege_grants.md) via (`grant_id` -> `id`) | - | `1001` |
| `source_globalid` | Text field containing descriptive or reference information. | `VARCHAR(30)` | Yes | No | - | - | `Sample value` |
| `source_center` | Center part of the reference to related source data. | `int4` | Yes | No | - | - | `101` |
| `source_id` | Identifier of the related source record. | `int4` | Yes | No | - | - | `1001` |
| `source_subid` | Sub-identifier for related source detail rows. | `int4` | Yes | No | - | - | `1` |
| `extension` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [persons](persons.md) (6 query files), [privilege_grants](privilege_grants.md) (6 query files), [booking_privileges](booking_privileges.md) (4 query files), [centers](centers.md) (4 query files), [privilege_sets](privilege_sets.md) (4 query files), [products](products.md) (4 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [privilege_cache_validity](privilege_cache_validity.md), [privilege_grants](privilege_grants.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
