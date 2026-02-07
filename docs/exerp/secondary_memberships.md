# secondary_memberships
Operational table for secondary memberships records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `secondary_member_person_center` | Center component of the composite reference to the related secondary member person record. | `int4` | No | No | [persons](persons.md) via (`secondary_member_person_center`, `secondary_member_person_id` -> `center`, `id`) | - |
| `secondary_member_person_id` | Identifier component of the composite reference to the related secondary member person record. | `int4` | No | No | [persons](persons.md) via (`secondary_member_person_center`, `secondary_member_person_id` -> `center`, `id`) | - |
| `subscription_add_on_id` | Identifier of the related subscription addon record used by this row. | `int4` | No | No | [subscription_addon](subscription_addon.md) via (`subscription_add_on_id` -> `id`) | - |
| `start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `stop_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md), [subscription_addon](subscription_addon.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [add_on_product_definition](add_on_product_definition.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md).
