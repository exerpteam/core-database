# clearing_in
Operational table for clearing in records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 56 query files; common companions include [account_receivables](account_receivables.md), [payment_requests](payment_requests.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `clearinghouse` | Foreign key field linking this record to `clearinghouses`. | `int4` | Yes | No | [clearinghouses](clearinghouses.md) via (`clearinghouse` -> `id`) | - | `42` |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - | `1` |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `payment_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `total_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `received_date` | Date for received. | `DATE` | No | No | - | - | `2025-01-31` |
| `generated_date` | Date for generated. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `delivery` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `errors` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `substate` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `filename` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `checksum` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `exchanged_file_id` | Foreign key field linking this record to `exchanged_file`. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`exchanged_file_id` -> `id`) | - | `1001` |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (49 query files), [payment_requests](payment_requests.md) (42 query files), [persons](persons.md) (37 query files), [payment_agreements](payment_agreements.md) (33 query files), [payment_request_specifications](payment_request_specifications.md) (27 query files), [centers](centers.md) (26 query files).
- FK-linked tables: outgoing FK to [clearinghouses](clearinghouses.md), [exchanged_file](exchanged_file.md); incoming FK from [payment_requests](payment_requests.md), [unplaced_payments](unplaced_payments.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [cashcollection_requests](cashcollection_requests.md), [ch_and_pcc_link](ch_and_pcc_link.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
