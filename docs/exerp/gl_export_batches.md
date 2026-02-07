# gl_export_batches
Operational table for gl export batches records in the Exerp schema. It is typically used where it appears in approximately 5 query files; common companions include [aggregated_transactions](aggregated_transactions.md), [exchanged_file](exchanged_file.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `exchanged_file_id` | Identifier of the related exchanged file record used by this row. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`exchanged_file_id` -> `id`) | - |

# Relations
- Commonly used with: [aggregated_transactions](aggregated_transactions.md) (5 query files), [exchanged_file](exchanged_file.md) (5 query files), [exchanged_file_exp](exchanged_file_exp.md) (3 query files).
- FK-linked tables: outgoing FK to [exchanged_file](exchanged_file.md); incoming FK from [aggregated_transactions](aggregated_transactions.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [cashcollection_requests](cashcollection_requests.md), [centers](centers.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md).
