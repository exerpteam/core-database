# booking_restrictions
Operational table for booking restrictions records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 4 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `start_time` | Epoch timestamp for start. | `int8` | No | No | - | - |
| `stop_time` | Epoch timestamp for stop. | `int8` | Yes | No | - | - |
| `user_interface_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `in_advance_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `in_advance_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `reason` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `access_group` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `has_expiry_been_notified` | Boolean flag indicating presence of expiry been notified. | `bool` | Yes | No | - | - |
| `prevent_all_bookings` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md), [companyagreements](companyagreements.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
