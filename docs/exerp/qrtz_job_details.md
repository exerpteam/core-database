# qrtz_job_details
Operational table for qrtz job details records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `job_name` | Text field containing descriptive or reference information. | `VARCHAR(200)` | No | Yes | - | - |
| `job_group` | Text field containing descriptive or reference information. | `VARCHAR(200)` | No | Yes | - | - |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `job_class_name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `is_durable` | Boolean flag indicating whether durable applies. | `bool` | No | No | - | - |
| `is_volatile` | Boolean flag indicating whether volatile applies. | `bool` | No | No | - | - |
| `is_stateful` | Boolean flag indicating whether stateful applies. | `bool` | No | No | - | - |
| `requests_recovery` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `job_data` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
- FK-linked tables: incoming FK from [qrtz_job_listeners](qrtz_job_listeners.md), [qrtz_triggers](qrtz_triggers.md).
- Second-level FK neighborhood includes: [qrtz_blob_triggers](qrtz_blob_triggers.md), [qrtz_cron_triggers](qrtz_cron_triggers.md), [qrtz_simple_triggers](qrtz_simple_triggers.md), [qrtz_trigger_listeners](qrtz_trigger_listeners.md).
