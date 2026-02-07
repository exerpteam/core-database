# task_log
Stores historical/log records for task events and changes. It is typically used where it appears in approximately 32 query files; common companions include [tasks](tasks.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `task_id` | Foreign key field linking this record to `tasks`. | `int4` | Yes | No | [tasks](tasks.md) via (`task_id` -> `id`) | - | `1001` |
| `employee_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `event_time` | Epoch timestamp for event. | `int8` | No | No | - | - | `1738281600000` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `task_action_id` | Foreign key field linking this record to `task_actions`. | `int4` | Yes | No | [task_actions](task_actions.md) via (`task_action_id` -> `id`) | - | `1001` |
| `task_step_id` | Foreign key field linking this record to `task_steps`. | `int4` | Yes | No | [task_steps](task_steps.md) via (`task_step_id` -> `id`) | - | `1001` |
| `task_status` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `previous_task_log_id` | Identifier of the related previous task log record. | `int4` | Yes | No | - | - | `1001` |

# Relations
- Commonly used with: [tasks](tasks.md) (32 query files), [persons](persons.md) (30 query files), [task_log_details](task_log_details.md) (23 query files), [centers](centers.md) (21 query files), [task_actions](task_actions.md) (17 query files), [task_steps](task_steps.md) (14 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [task_actions](task_actions.md), [task_steps](task_steps.md), [tasks](tasks.md); incoming FK from [task_log_details](task_log_details.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
