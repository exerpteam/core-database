# batch_executions_dependencies
Operational table for batch executions dependencies records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `from_exec` | Foreign key field linking this record to `batch_executions`. | `int4` | No | Yes | [batch_executions](batch_executions.md) via (`from_exec` -> `id`) | - | `42` |
| `to_exec` | Foreign key field linking this record to `batch_executions`. | `int4` | No | Yes | [batch_executions](batch_executions.md) via (`to_exec` -> `id`) | - | `42` |

# Relations
- FK-linked tables: outgoing FK to [batch_executions](batch_executions.md).
