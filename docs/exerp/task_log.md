# task_log
Stores historical/log records for task events and changes. It is typically used where it appears in approximately 32 query files; common companions include [tasks](tasks.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `task_id` | Identifier of the related tasks record used by this row. | `int4` | Yes | No | [tasks](tasks.md) via (`task_id` -> `id`) | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [persons](persons.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [persons](persons.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `event_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `task_action_id` | Identifier of the related task actions record used by this row. | `int4` | Yes | No | [task_actions](task_actions.md) via (`task_action_id` -> `id`) | - |
| `task_step_id` | Identifier of the related task steps record used by this row. | `int4` | Yes | No | [task_steps](task_steps.md) via (`task_step_id` -> `id`) | - |
| `task_status` | State indicator used to control lifecycle transitions and filtering. | `text(2147483647)` | Yes | No | - | - |
| `previous_task_log_id` | Identifier for the related previous task log entity used by this record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [tasks](tasks.md) (32 query files), [persons](persons.md) (30 query files), [task_log_details](task_log_details.md) (23 query files), [centers](centers.md) (21 query files), [task_actions](task_actions.md) (17 query files), [task_steps](task_steps.md) (14 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [task_actions](task_actions.md), [task_steps](task_steps.md), [tasks](tasks.md); incoming FK from [task_log_details](task_log_details.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
