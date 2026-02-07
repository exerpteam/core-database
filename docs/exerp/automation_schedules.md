# automation_schedules
Operational table for automation schedules records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `entry_time` | Timestamp used for event ordering and operational tracking. | `TIMESTAMP` | No | No | - | - |
| `schedule_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(30)` | No | No | - | - |
| `schedule_configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `VARCHAR(25)` | No | No | - | - |
| `automation_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(30)` | No | No | - | - |
| `automation_key` | Business attribute `automation_key` used by automation schedules workflows and reporting. | `int4` | No | No | - | - |
| `next_time_to_run` | Business attribute `next_time_to_run` used by automation schedules workflows and reporting. | `TIMESTAMP` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
