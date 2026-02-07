# jboss_ejb_timer
Operational table for jboss ejb timer records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `VARCHAR(2147483647)` | No | Yes | - | - |
| `timed_object_id` | Identifier for the related timed object entity used by this record. | `VARCHAR(2147483647)` | No | No | - | - |
| `initial_date` | Business date used for scheduling, validity, or reporting cutoffs. | `TIMESTAMP` | Yes | No | - | - |
| `repeat_interval` | Business attribute `repeat_interval` used by jboss ejb timer workflows and reporting. | `int8` | Yes | No | - | - |
| `next_date` | Business date used for scheduling, validity, or reporting cutoffs. | `TIMESTAMP` | Yes | No | - | - |
| `previous_run` | Business attribute `previous_run` used by jboss ejb timer workflows and reporting. | `TIMESTAMP` | Yes | No | - | - |
| `primary_key` | Business attribute `primary_key` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `info` | Operational field `info` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `timer_state` | State indicator used to control lifecycle transitions and filtering. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_second` | Business attribute `schedule_expr_second` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_minute` | Business attribute `schedule_expr_minute` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_hour` | Business attribute `schedule_expr_hour` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_day_of_week` | Business attribute `schedule_expr_day_of_week` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_day_of_month` | Business attribute `schedule_expr_day_of_month` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_month` | Business attribute `schedule_expr_month` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_year` | Business attribute `schedule_expr_year` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `schedule_expr_timezone` | Business attribute `schedule_expr_timezone` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `auto_timer` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `timeout_method_declaring_class` | Operational counter/limit used for processing control and performance monitoring. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `timeout_method_name` | Operational counter/limit used for processing control and performance monitoring. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `timeout_method_descriptor` | Operational counter/limit used for processing control and performance monitoring. | `VARCHAR(2147483647)` | Yes | No | - | - |
| `calendar_timer` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `partition_name` | Business attribute `partition_name` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | No | No | - | - |
| `node_name` | Business attribute `node_name` used by jboss ejb timer workflows and reporting. | `VARCHAR(2147483647)` | Yes | No | - | - |

# Relations
