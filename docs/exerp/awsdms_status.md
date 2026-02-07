# awsdms_status
Operational table for awsdms status records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `server_name` | Business attribute `server_name` used by awsdms status workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `task_name` | Business attribute `task_name` used by awsdms status workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `task_status` | State indicator used to control lifecycle transitions and filtering. | `VARCHAR(32)` | Yes | No | - | - |
| `status_time` | State indicator used to control lifecycle transitions and filtering. | `TIMESTAMP` | Yes | No | - | - |
| `pending_changes` | Business attribute `pending_changes` used by awsdms status workflows and reporting. | `int8` | Yes | No | - | - |
| `disk_swap_size` | Business attribute `disk_swap_size` used by awsdms status workflows and reporting. | `int8` | Yes | No | - | - |
| `task_memory` | Business attribute `task_memory` used by awsdms status workflows and reporting. | `int8` | Yes | No | - | - |
| `source_current_position` | Business attribute `source_current_position` used by awsdms status workflows and reporting. | `VARCHAR(128)` | Yes | No | - | - |
| `source_current_timestamp` | Business attribute `source_current_timestamp` used by awsdms status workflows and reporting. | `TIMESTAMP` | Yes | No | - | - |
| `source_tail_position` | Business attribute `source_tail_position` used by awsdms status workflows and reporting. | `VARCHAR(128)` | Yes | No | - | - |
| `source_tail_timestamp` | Business attribute `source_tail_timestamp` used by awsdms status workflows and reporting. | `TIMESTAMP` | Yes | No | - | - |
| `source_timestamp_applied` | Business attribute `source_timestamp_applied` used by awsdms status workflows and reporting. | `TIMESTAMP` | Yes | No | - | - |

# Relations
