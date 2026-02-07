# awsdms_history
Stores historical/log records for awsdms events and changes.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `server_name` | Business attribute `server_name` used by awsdms history workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `task_name` | Business attribute `task_name` used by awsdms history workflows and reporting. | `VARCHAR(128)` | No | No | - | - |
| `timeslot_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(32)` | No | No | - | - |
| `timeslot` | Business attribute `timeslot` used by awsdms history workflows and reporting. | `TIMESTAMP` | No | No | - | - |
| `timeslot_duration` | Business attribute `timeslot_duration` used by awsdms history workflows and reporting. | `int8` | Yes | No | - | - |
| `timeslot_latency` | Business attribute `timeslot_latency` used by awsdms history workflows and reporting. | `int8` | Yes | No | - | - |
| `timeslot_records` | Business attribute `timeslot_records` used by awsdms history workflows and reporting. | `int8` | Yes | No | - | - |
| `timeslot_volume` | Business attribute `timeslot_volume` used by awsdms history workflows and reporting. | `int8` | Yes | No | - | - |

# Relations
