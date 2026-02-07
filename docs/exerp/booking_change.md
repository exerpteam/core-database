# booking_change
Operational table for booking change records in the Exerp schema. It is typically used where it appears in approximately 3 query files; common companions include [bookings](bookings.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `booking_center` | Center component of the composite reference to the related booking record. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `booking_id` | Identifier component of the composite reference to the related booking record. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `TIME` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `value_before` | Business attribute `value_before` used by booking change workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `value_after` | Business attribute `value_after` used by booking change workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [bookings](bookings.md) (3 query files), [persons](persons.md) (3 query files), [activity](activity.md) (2 query files), [staff_usage](staff_usage.md) (2 query files).
- FK-linked tables: outgoing FK to [bookings](bookings.md), [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [activity](activity.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [booking_program_standby](booking_program_standby.md), [booking_programs](booking_programs.md).
