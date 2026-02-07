# payment_request_specifications
Financial/transactional table for payment request specifications records. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 412 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `entry_time` | Epoch timestamp for entry. | `int8` | Yes | No | - | - | `1738281600000` |
| `requested_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `collection_fee` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `rejection_fee` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `cancelled` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `original_due_date` | Date for original due. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `total_invoice_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `from_date` | Date for from. | `int8` | Yes | No | - | - | `42` |
| `to_date` | Date for to. | `int8` | Yes | No | - | - | `42` |
| `balance_from` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `balance_to` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `included_overdue_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `open_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `paid_state` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `paid_state_last_entry_time` | Epoch timestamp for paid state last entry. | `int8` | No | No | - | - | `1738281600000` |
| `inv_diff` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `issued_date` | Date for issued. | `int8` | Yes | No | - | - | `42` |
| `fiscal_reference` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - | `Sample value` |
| `fiscal_export_token` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - | `Sample value` |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (376 query files), [persons](persons.md) (349 query files), [payment_requests](payment_requests.md) (339 query files), [ar_trans](ar_trans.md) (274 query files), [centers](centers.md) (264 query files), [payment_agreements](payment_agreements.md) (143 query files).
- FK-linked tables: outgoing FK to [account_receivables](account_receivables.md); incoming FK from [ar_trans](ar_trans.md), [cashcollection_requests](cashcollection_requests.md), [payment_requests](payment_requests.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [art_match](art_match.md), [cashcollection_in](cashcollection_in.md), [cashcollectioncases](cashcollectioncases.md), [cashregistertransactions](cashregistertransactions.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md), [crt_art_link](crt_art_link.md), [employees](employees.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; change timestamps support incremental extraction and reconciliation.
