# qrtz_triggers
Operational table for qrtz triggers records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `trigger_name` | Text field containing descriptive or reference information. | `VARCHAR(200)` | No | Yes | - | - | `Example Name` |
| `trigger_group` | Text field containing descriptive or reference information. | `VARCHAR(200)` | No | Yes | - | - | `Sample value` |
| `job_name` | Foreign key field linking this record to `qrtz_job_details`. | `text(2147483647)` | No | No | [qrtz_job_details](qrtz_job_details.md) via (`job_name`, `job_group` -> `job_name`, `job_group`) | - | `Example Name` |
| `job_group` | Foreign key field linking this record to `qrtz_job_details`. | `text(2147483647)` | No | No | [qrtz_job_details](qrtz_job_details.md) via (`job_name`, `job_group` -> `job_name`, `job_group`) | - | `Sample value` |
| `is_volatile` | Boolean flag indicating whether volatile applies. | `bool` | No | No | - | - | `true` |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `next_fire_time` | Epoch timestamp for next fire. | `float8(17,17)` | Yes | No | - | - | `N/A` |
| `prev_fire_time` | Epoch timestamp for prev fire. | `float8(17,17)` | Yes | No | - | - | `N/A` |
| `priority` | Table field used by operational and reporting workloads. | `float8(17,17)` | Yes | No | - | - | `N/A` |
| `trigger_state` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `trigger_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `start_time` | Epoch timestamp for start. | `float8(17,17)` | No | No | - | - | `Sample` |
| `end_time` | Epoch timestamp for end. | `float8(17,17)` | Yes | No | - | - | `N/A` |
| `calendar_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `misfire_instr` | Table field used by operational and reporting workloads. | `float4(8,8)` | Yes | No | - | - | `N/A` |
| `job_data` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
- FK-linked tables: outgoing FK to [qrtz_job_details](qrtz_job_details.md); incoming FK from [qrtz_blob_triggers](qrtz_blob_triggers.md), [qrtz_cron_triggers](qrtz_cron_triggers.md), [qrtz_simple_triggers](qrtz_simple_triggers.md), [qrtz_trigger_listeners](qrtz_trigger_listeners.md).
- Second-level FK neighborhood includes: [qrtz_job_listeners](qrtz_job_listeners.md).
