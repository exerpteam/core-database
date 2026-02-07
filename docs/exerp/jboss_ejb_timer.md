# jboss_ejb_timer
Operational table for jboss ejb timer records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `VARCHAR(2147483647)` | No | Yes | - | - |
| `timed_object_id` | Identifier of the related timed object record. | `VARCHAR(2147483647)` | No | No | - | - |
| `initial_date` | Date for initial. | `TIMESTAMP` | Yes | No | - | - |
| `repeat_interval` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `next_date` | Date for next. | `TIMESTAMP` | Yes | No | - | - |
| `previous_run` | Table field used by operational and reporting workloads. | `TIMESTAMP` | Yes | No | - | - |
| `primary_key` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `info` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `timer_state` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_second` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_minute` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_hour` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_day_of_week` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_day_of_month` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_month` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_year` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_start_date` | Date for schedule expr start. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_end_date` | Date for schedule expr end. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_timezone` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `auto_timer` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `timeout_method_declaring_class` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `timeout_method_name` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `timeout_method_descriptor` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `calendar_timer` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `partition_name` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | No | No | - | - |
| `node_name` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - |

# Relations
