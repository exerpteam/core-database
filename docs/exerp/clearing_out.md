# clearing_out
Operational table for clearing out records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 25 query files; common companions include [payment_requests](payment_requests.md), [account_receivables](account_receivables.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `clearinghouse` | Foreign key field linking this record to `clearinghouses`. | `int4` | Yes | No | [clearinghouses](clearinghouses.md) via (`clearinghouse` -> `id`) | - | `42` |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - | `1` |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `generated_date` | Date for generated. | `DATE` | No | No | - | - | `2025-01-31` |
| `sent_date` | Date for sent. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `confirmed_date` | Date for confirmed. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `total_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `invoice_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `total_reversal_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `reversal_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `delivery` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `errors` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `requested_date` | Date for requested. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `handler_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `file_name_provided_by_handler` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `exchanged_file` | Foreign key field linking this record to `exchanged_file`. | `int4` | Yes | No | [exchanged_file](exchanged_file.md) via (`exchanged_file` -> `id`) | - | `42` |

# Relations
- Commonly used with: [payment_requests](payment_requests.md) (25 query files), [account_receivables](account_receivables.md) (17 query files), [payment_request_specifications](payment_request_specifications.md) (16 query files), [persons](persons.md) (15 query files), [payment_agreements](payment_agreements.md) (13 query files), [centers](centers.md) (11 query files).
- FK-linked tables: outgoing FK to [clearinghouses](clearinghouses.md), [exchanged_file](exchanged_file.md); incoming FK from [payment_requests](payment_requests.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [cashcollection_requests](cashcollection_requests.md), [ch_and_pcc_link](ch_and_pcc_link.md), [clearing_in](clearing_in.md), [clearinghouse_creditors](clearinghouse_creditors.md), [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md), [employees](employees.md), [exchanged_file_exp](exchanged_file_exp.md), [exchanged_file_op](exchanged_file_op.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
