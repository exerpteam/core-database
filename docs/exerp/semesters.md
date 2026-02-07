# semesters
Operational table for semesters records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the related top node record. | `int4` | Yes | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |
| `start_date` | Date when the record becomes effective. | `DATE` | Yes | No | - | - |
| `end_date` | Date when the record ends or expires. | `DATE` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `VARCHAR(10)` | No | No | - | - |
| `available_on_web` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |

# Relations
- FK-linked tables: incoming FK from [booking_programs](booking_programs.md).
- Second-level FK neighborhood includes: [activity](activity.md), [booking_program_types](booking_program_types.md), [bookings](bookings.md), [recurring_participations](recurring_participations.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; `start_date` and `end_date` are frequently used for period-window filtering.
