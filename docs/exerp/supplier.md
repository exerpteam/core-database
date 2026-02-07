# supplier
Operational table for supplier records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `active` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | No | No | - | - |
| `supply_scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `supply_scope_id` | Identifier of the related supply scope record. | `int4` | No | No | - | - |
| `delivery_time` | Epoch timestamp for delivery. | `text(2147483647)` | No | No | - | - |
| `finance_account_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md); incoming FK from [delivery](delivery.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
