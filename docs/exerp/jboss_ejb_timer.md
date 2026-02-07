# jboss_ejb_timer
Operational table for jboss ejb timer records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `VARCHAR(2147483647)` | No | Yes | - | - | `1001` |
| `timed_object_id` | Identifier of the related timed object record. | `VARCHAR(2147483647)` | No | No | - | - | `1001` |
| `initial_date` | Date for initial. | `TIMESTAMP` | Yes | No | - | - | `N/A` |
| `repeat_interval` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `next_date` | Date for next. | `TIMESTAMP` | Yes | No | - | - | `N/A` |
| `previous_run` | Table field used by operational and reporting workloads. | `TIMESTAMP` | Yes | No | - | - | `N/A` |
| `primary_key` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `info` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `timer_state` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_expr_second` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_expr_minute` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_expr_hour` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_expr_day_of_week` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_expr_day_of_month` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_expr_month` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_expr_year` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_expr_start_date` | Date for schedule expr start. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_expr_end_date` | Date for schedule expr end. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_expr_timezone` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `auto_timer` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `timeout_method_declaring_class` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `timeout_method_name` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Example Name` |
| `timeout_method_descriptor` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Sample value` |
| `calendar_timer` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `partition_name` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | No | No | - | - | `Example Name` |
| `node_name` | Text field containing descriptive or reference information. | `VARCHAR(2147483647)` | Yes | No | - | - | `Example Name` |

# Relations
