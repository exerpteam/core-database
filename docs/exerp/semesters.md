# semesters
Operational table for semesters records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `top_node_id` | Identifier of the top hierarchy node used to organize scoped records. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(50)` | Yes | No | - | - |
| `start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(10)` | No | No | - | - |
| `available_on_web` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |

# Relations
- FK-linked tables: incoming FK from [booking_programs](booking_programs.md).
- Second-level FK neighborhood includes: [activity](activity.md), [booking_program_types](booking_program_types.md), [bookings](bookings.md), [recurring_participations](recurring_participations.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; `start_date` and `end_date` are frequently used for period-window filtering.
