# qrtz_fired_triggers
Operational table for qrtz fired triggers records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `entry_id` | Primary key identifier for this record. | `VARCHAR(95)` | No | Yes | - | - |
| `trigger_name` | Business attribute `trigger_name` used by qrtz fired triggers workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `trigger_group` | Business attribute `trigger_group` used by qrtz fired triggers workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `is_volatile` | Boolean flag indicating whether `volatile` applies to this record. | `bool` | No | No | - | - |
| `instance_name` | Business attribute `instance_name` used by qrtz fired triggers workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `fired_time` | Timestamp used for event ordering and operational tracking. | `float8(17,17)` | No | No | - | - |
| `priority` | Business attribute `priority` used by qrtz fired triggers workflows and reporting. | `float8(17,17)` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `job_name` | Business attribute `job_name` used by qrtz fired triggers workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `job_group` | Business attribute `job_group` used by qrtz fired triggers workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `is_stateful` | Boolean flag indicating whether `stateful` applies to this record. | `bool` | Yes | No | - | - |
| `requests_recovery` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
