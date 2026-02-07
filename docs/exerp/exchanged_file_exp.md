# exchanged_file_exp
Operational table for exchanged file exp records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 12 query files; common companions include [exchanged_file](exchanged_file.md), [exchanged_file_op](exchanged_file_op.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `exchanged_file_id` | Identifier of the related exchanged file record used by this row. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`exchanged_file_id` -> `id`) | - |
| `service` | Operational field `service` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `attempt` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `export_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [exchanged_file](exchanged_file.md) (12 query files), [exchanged_file_op](exchanged_file_op.md) (7 query files), [extract](extract.md) (5 query files), [exchanged_file_sc](exchanged_file_sc.md) (4 query files), [aggregated_transactions](aggregated_transactions.md) (3 query files), [gl_export_batches](gl_export_batches.md) (3 query files).
- FK-linked tables: outgoing FK to [exchanged_file](exchanged_file.md).
- Second-level FK neighborhood includes: [cashcollection_requests](cashcollection_requests.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_op](exchanged_file_op.md), [exchanged_file_sc](exchanged_file_sc.md), [gl_export_batches](gl_export_batches.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
