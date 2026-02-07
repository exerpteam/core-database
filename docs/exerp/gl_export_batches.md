# gl_export_batches
Operational table for gl export batches records in the Exerp schema. It is typically used where it appears in approximately 5 query files; common companions include [aggregated_transactions](aggregated_transactions.md), [exchanged_file](exchanged_file.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `exchanged_file_id` | Foreign key field linking this record to `exchanged_file`. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`exchanged_file_id` -> `id`) | - | `1001` |

# Relations
- Commonly used with: [aggregated_transactions](aggregated_transactions.md) (5 query files), [exchanged_file](exchanged_file.md) (5 query files), [exchanged_file_exp](exchanged_file_exp.md) (3 query files).
- FK-linked tables: outgoing FK to [exchanged_file](exchanged_file.md); incoming FK from [aggregated_transactions](aggregated_transactions.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [cashcollection_requests](cashcollection_requests.md), [centers](centers.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md).
