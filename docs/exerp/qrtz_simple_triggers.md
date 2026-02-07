# qrtz_simple_triggers
Operational table for qrtz simple triggers records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `trigger_name` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | [qrtz_triggers](qrtz_triggers.md) via (`trigger_name`, `trigger_group` -> `trigger_name`, `trigger_group`) | - |
| `trigger_group` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | [qrtz_triggers](qrtz_triggers.md) via (`trigger_name`, `trigger_group` -> `trigger_name`, `trigger_group`) | - |
| `repeat_count` | Operational counter/limit used for processing control and performance monitoring. | `float8(17,17)` | No | No | - | - |
| `repeat_interval` | Business attribute `repeat_interval` used by qrtz simple triggers workflows and reporting. | `float8(17,17)` | No | No | - | - |
| `times_triggered` | Business attribute `times_triggered` used by qrtz simple triggers workflows and reporting. | `float8(17,17)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [qrtz_triggers](qrtz_triggers.md).
- Second-level FK neighborhood includes: [qrtz_blob_triggers](qrtz_blob_triggers.md), [qrtz_cron_triggers](qrtz_cron_triggers.md), [qrtz_job_details](qrtz_job_details.md), [qrtz_trigger_listeners](qrtz_trigger_listeners.md).
