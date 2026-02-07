# batch_executions
Operational table for batch executions records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `job_class` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - | `1001` |
| `entity_key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `earliest_exec_time` | Epoch timestamp for earliest exec. | `int8` | No | No | - | - | `1738281600000` |
| `STATE` | State code representing the current processing state. | `int4` | Yes | No | - | - | `1` |
| `start_time` | Epoch timestamp for start. | `int8` | Yes | No | - | - | `1738281600000` |
| `execution_date` | Date for execution. | `DATE` | No | No | - | - | `2025-01-31` |
| `node_id` | Identifier of the related node record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |

# Relations
- FK-linked tables: incoming FK from [batch_executions_dependencies](batch_executions_dependencies.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
