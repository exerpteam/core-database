# qrtz_job_listeners
Operational table for qrtz job listeners records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `job_name` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | [qrtz_job_details](qrtz_job_details.md) via (`job_name`, `job_group` -> `job_name`, `job_group`) | - |
| `job_group` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | [qrtz_job_details](qrtz_job_details.md) via (`job_name`, `job_group` -> `job_name`, `job_group`) | - |
| `job_listener` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | - | - |

# Relations
- FK-linked tables: outgoing FK to [qrtz_job_details](qrtz_job_details.md).
- Second-level FK neighborhood includes: [qrtz_triggers](qrtz_triggers.md).
