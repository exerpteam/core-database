# qrtz_job_details
Operational table for qrtz job details records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `job_name` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | - | - |
| `job_group` | Primary key component used to uniquely identify this record. | `VARCHAR(200)` | No | Yes | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `job_class_name` | Business attribute `job_class_name` used by qrtz job details workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `is_durable` | Boolean flag indicating whether `durable` applies to this record. | `bool` | No | No | - | - |
| `is_volatile` | Boolean flag indicating whether `volatile` applies to this record. | `bool` | No | No | - | - |
| `is_stateful` | Boolean flag indicating whether `stateful` applies to this record. | `bool` | No | No | - | - |
| `requests_recovery` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `job_data` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- FK-linked tables: incoming FK from [qrtz_job_listeners](qrtz_job_listeners.md), [qrtz_triggers](qrtz_triggers.md).
- Second-level FK neighborhood includes: [qrtz_blob_triggers](qrtz_blob_triggers.md), [qrtz_cron_triggers](qrtz_cron_triggers.md), [qrtz_simple_triggers](qrtz_simple_triggers.md), [qrtz_trigger_listeners](qrtz_trigger_listeners.md).
