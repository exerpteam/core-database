# unplaced_payments
Financial/transactional table for unplaced payments records. It is typically used where lifecycle state codes are present; it appears in approximately 6 query files; common companions include [account_receivables](account_receivables.md), [clearing_in](clearing_in.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - | `1` |
| `xfr_delivery` | Foreign key field linking this record to `clearing_in`. | `int4` | Yes | No | [clearing_in](clearing_in.md) via (`xfr_delivery` -> `id`) | - | `42` |
| `xfr_rec_no` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `xfr_date` | Date for xfr. | `DATE` | No | No | - | - | `2025-01-31` |
| `xfr_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `xfr_info` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `xfr_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `xfr_debitor_id` | Identifier of the related xfr debitor record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `xfr_creditor_id` | Identifier of the related xfr creditor record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `account_center` | Center part of the reference to related account data. | `int4` | Yes | No | - | [accounts](accounts.md) via (`account_center`, `account_id` -> `center`, `id`) | `101` |
| `account_id` | Identifier of the related account record. | `int4` | Yes | No | - | - | `1001` |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (5 query files), [clearing_in](clearing_in.md) (4 query files), [persons](persons.md) (4 query files), [payment_requests](payment_requests.md) (4 query files), [clearinghouses](clearinghouses.md) (3 query files), [clearinghouse_creditors](clearinghouse_creditors.md) (2 query files).
- FK-linked tables: outgoing FK to [clearing_in](clearing_in.md).
- Second-level FK neighborhood includes: [clearinghouses](clearinghouses.md), [exchanged_file](exchanged_file.md), [payment_requests](payment_requests.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
