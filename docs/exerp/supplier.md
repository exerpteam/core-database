# supplier
Operational table for supplier records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `active` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | No | No | - | - |
| `supply_scope_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `supply_scope_id` | Identifier for the related supply scope entity used by this record. | `int4` | No | No | - | - |
| `delivery_time` | Timestamp used for event ordering and operational tracking. | `text(2147483647)` | No | No | - | - |
| `finance_account_globalid` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md); incoming FK from [delivery](delivery.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
