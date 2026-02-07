# recurring_participations
Operational table for recurring participations records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 5 query files; common companions include [persons](persons.md), [activity](activity.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `booking_program_id` | Foreign key field linking this record to `booking_programs`. | `int4` | No | No | [booking_programs](booking_programs.md) via (`booking_program_id` -> `id`) | - |
| `participant_center` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`participant_center`, `participant_id` -> `center`, `id`) | - |
| `participant_id` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`participant_center`, `participant_id` -> `center`, `id`) | - |
| `STATE` | State code representing the current processing state. | `VARCHAR(50)` | No | No | - | - |
| `subscription_id` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `subscription_center` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `start_time` | Epoch timestamp for start. | `int8` | No | No | - | - |
| `end_time` | Epoch timestamp for end. | `int8` | Yes | No | - | - |
| `installment_plan_id` | Foreign key field linking this record to `installment_plans`. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - |
| `owner_center` | Center part of the reference to related owner data. | `int4` | Yes | No | - | - |
| `owner_id` | Identifier of the related owner record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (4 query files), [activity](activity.md) (3 query files), [bookings](bookings.md) (3 query files), [participations](participations.md) (3 query files), [products](products.md) (3 query files), [centers](centers.md) (2 query files).
- FK-linked tables: outgoing FK to [booking_programs](booking_programs.md), [installment_plans](installment_plans.md), [persons](persons.md), [subscriptions](subscriptions.md); incoming FK from [participations](participations.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [activity](activity.md), [ar_trans](ar_trans.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_program_types](booking_program_types.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [campaign_codes](campaign_codes.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
