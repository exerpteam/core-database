# booking_change
Operational table for booking change records in the Exerp schema. It is typically used where it appears in approximately 3 query files; common companions include [bookings](bookings.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `booking_center` | Foreign key field linking this record to `bookings`. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - | `101` |
| `booking_id` | Foreign key field linking this record to `bookings`. | `int4` | No | No | [bookings](bookings.md) via (`booking_center`, `booking_id` -> `center`, `id`) | - | `1001` |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `1` |
| `TIME` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `value_before` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `value_after` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |

# Relations
- Commonly used with: [bookings](bookings.md) (3 query files), [persons](persons.md) (3 query files), [activity](activity.md) (2 query files), [staff_usage](staff_usage.md) (2 query files).
- FK-linked tables: outgoing FK to [bookings](bookings.md), [employees](employees.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [activity](activity.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [booking_program_standby](booking_program_standby.md), [booking_programs](booking_programs.md).
