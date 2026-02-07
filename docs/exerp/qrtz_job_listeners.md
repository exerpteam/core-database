# qrtz_job_listeners
Operational table for qrtz job listeners records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `job_name` | Foreign key field linking this record to `qrtz_job_details`. | `VARCHAR(200)` | No | Yes | [qrtz_job_details](qrtz_job_details.md) via (`job_name`, `job_group` -> `job_name`, `job_group`) | - |
| `job_group` | Foreign key field linking this record to `qrtz_job_details`. | `VARCHAR(200)` | No | Yes | [qrtz_job_details](qrtz_job_details.md) via (`job_name`, `job_group` -> `job_name`, `job_group`) | - |
| `job_listener` | Text field containing descriptive or reference information. | `VARCHAR(200)` | No | Yes | - | - |

# Relations
- FK-linked tables: outgoing FK to [qrtz_job_details](qrtz_job_details.md).
- Second-level FK neighborhood includes: [qrtz_triggers](qrtz_triggers.md).
