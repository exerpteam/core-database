# qrtz_cron_triggers
Operational table for qrtz cron triggers records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `trigger_name` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | [qrtz_triggers](qrtz_triggers.md) via (`trigger_name`, `trigger_group` -> `trigger_name`, `trigger_group`) | - |
| `trigger_group` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | [qrtz_triggers](qrtz_triggers.md) via (`trigger_name`, `trigger_group` -> `trigger_name`, `trigger_group`) | - |
| `cron_expression` | Business attribute `cron_expression` used by qrtz cron triggers workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `time_zone_id` | Identifier for the related time zone entity used by this record. | `text(2147483647)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [qrtz_triggers](qrtz_triggers.md).
- Second-level FK neighborhood includes: [qrtz_blob_triggers](qrtz_blob_triggers.md), [qrtz_job_details](qrtz_job_details.md), [qrtz_simple_triggers](qrtz_simple_triggers.md), [qrtz_trigger_listeners](qrtz_trigger_listeners.md).
