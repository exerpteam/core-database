# qrtz_triggers
Operational table for qrtz triggers records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `trigger_name` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | - | - |
| `trigger_group` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | - | - |
| `job_name` | Identifier of the related qrtz job details record used by this row. | `text(2147483647)` | No | No | [qrtz_job_details](qrtz_job_details.md) via (`job_name`, `job_group` -> `job_name`, `job_group`) | - |
| `job_group` | Identifier of the related qrtz job details record used by this row. | `text(2147483647)` | No | No | [qrtz_job_details](qrtz_job_details.md) via (`job_name`, `job_group` -> `job_name`, `job_group`) | - |
| `is_volatile` | Boolean flag indicating whether `volatile` applies to this record. | `bool` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `next_fire_time` | Timestamp used for event ordering and operational tracking. | `float8(17,17)` | Yes | No | - | - |
| `prev_fire_time` | Timestamp used for event ordering and operational tracking. | `float8(17,17)` | Yes | No | - | - |
| `priority` | Business attribute `priority` used by qrtz triggers workflows and reporting. | `float8(17,17)` | Yes | No | - | - |
| `trigger_state` | State indicator used to control lifecycle transitions and filtering. | `text(2147483647)` | No | No | - | - |
| `trigger_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `start_time` | Timestamp used for event ordering and operational tracking. | `float8(17,17)` | No | No | - | - |
| `end_time` | Timestamp used for event ordering and operational tracking. | `float8(17,17)` | Yes | No | - | - |
| `calendar_name` | Business attribute `calendar_name` used by qrtz triggers workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `misfire_instr` | Business attribute `misfire_instr` used by qrtz triggers workflows and reporting. | `float4(8,8)` | Yes | No | - | - |
| `job_data` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [qrtz_job_details](qrtz_job_details.md); incoming FK from [qrtz_blob_triggers](qrtz_blob_triggers.md), [qrtz_cron_triggers](qrtz_cron_triggers.md), [qrtz_simple_triggers](qrtz_simple_triggers.md), [qrtz_trigger_listeners](qrtz_trigger_listeners.md).
- Second-level FK neighborhood includes: [qrtz_job_listeners](qrtz_job_listeners.md).
