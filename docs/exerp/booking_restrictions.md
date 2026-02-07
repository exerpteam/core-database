# booking_restrictions
Operational table for booking restrictions records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 4 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `stop_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `user_interface_type` | Classification code describing the user interface type category (for example: API, App, CLIENT, KIOSK). | `int4` | Yes | No | - | - |
| `in_advance_unit` | Business attribute `in_advance_unit` used by booking restrictions workflows and reporting. | `int4` | No | No | - | - |
| `in_advance_value` | Business attribute `in_advance_value` used by booking restrictions workflows and reporting. | `int4` | No | No | - | - |
| `reason` | Operational field `reason` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `access_group` | Business attribute `access_group` used by booking restrictions workflows and reporting. | `int4` | Yes | No | - | - |
| `has_expiry_been_notified` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `prevent_all_bookings` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md), [companyagreements](companyagreements.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
