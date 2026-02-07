# batch_executions
Operational table for batch executions records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `job_class` | Business attribute `job_class` used by batch executions workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `entity_key` | Business attribute `entity_key` used by batch executions workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `earliest_exec_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | Yes | No | - | - |
| `start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `execution_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `node_id` | Identifier for the related node entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `rank` | Operational field `rank` used in query filtering and reporting transformations. | `int4` | No | No | - | - |

# Relations
- FK-linked tables: incoming FK from [batch_executions_dependencies](batch_executions_dependencies.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
