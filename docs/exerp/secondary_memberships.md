# secondary_memberships
Operational table for secondary memberships records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `secondary_member_person_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`secondary_member_person_center`, `secondary_member_person_id` -> `center`, `id`) | - | `101` |
| `secondary_member_person_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`secondary_member_person_center`, `secondary_member_person_id` -> `center`, `id`) | - | `1001` |
| `subscription_add_on_id` | Foreign key field linking this record to `subscription_addon`. | `int4` | No | No | [subscription_addon](subscription_addon.md) via (`subscription_add_on_id` -> `id`) | - | `1001` |
| `start_time` | Epoch timestamp for start. | `int8` | No | No | - | - | `1738281600000` |
| `stop_time` | Epoch timestamp for stop. | `int8` | Yes | No | - | - | `1738281600000` |

# Relations
- FK-linked tables: outgoing FK to [persons](persons.md), [subscription_addon](subscription_addon.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [add_on_product_definition](add_on_product_definition.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md).
