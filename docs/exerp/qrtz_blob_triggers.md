# qrtz_blob_triggers
Operational table for qrtz blob triggers records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `trigger_name` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | [qrtz_triggers](qrtz_triggers.md) via (`trigger_name`, `trigger_group` -> `trigger_name`, `trigger_group`) | - |
| `trigger_group` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | [qrtz_triggers](qrtz_triggers.md) via (`trigger_name`, `trigger_group` -> `trigger_name`, `trigger_group`) | - |
| `blob_data` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [qrtz_triggers](qrtz_triggers.md).
- Second-level FK neighborhood includes: [qrtz_cron_triggers](qrtz_cron_triggers.md), [qrtz_job_details](qrtz_job_details.md), [qrtz_simple_triggers](qrtz_simple_triggers.md), [qrtz_trigger_listeners](qrtz_trigger_listeners.md).
