# qrtz_trigger_listeners
Operational table for qrtz trigger listeners records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `trigger_name` | Foreign key field linking this record to `qrtz_triggers`. | `VARCHAR(200)` | No | Yes | [qrtz_triggers](qrtz_triggers.md) via (`trigger_name`, `trigger_group` -> `trigger_name`, `trigger_group`) | - | `Example Name` |
| `trigger_group` | Foreign key field linking this record to `qrtz_triggers`. | `VARCHAR(200)` | No | Yes | [qrtz_triggers](qrtz_triggers.md) via (`trigger_name`, `trigger_group` -> `trigger_name`, `trigger_group`) | - | `Sample value` |
| `trigger_listener` | Text field containing descriptive or reference information. | `VARCHAR(200)` | No | Yes | - | - | `Sample value` |

# Relations
- FK-linked tables: outgoing FK to [qrtz_triggers](qrtz_triggers.md).
- Second-level FK neighborhood includes: [qrtz_blob_triggers](qrtz_blob_triggers.md), [qrtz_cron_triggers](qrtz_cron_triggers.md), [qrtz_job_details](qrtz_job_details.md), [qrtz_simple_triggers](qrtz_simple_triggers.md).
