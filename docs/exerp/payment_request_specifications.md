# payment_request_specifications
Financial/transactional table for payment request specifications records. It is typically used where rows are center-scoped; change-tracking timestamps are available; it appears in approximately 412 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `requested_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `collection_fee` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `rejection_fee` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `cancelled` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `REF` | Operational field `REF` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `original_due_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `total_invoice_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `from_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int8` | Yes | No | - | - |
| `to_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int8` | Yes | No | - | - |
| `balance_from` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `balance_to` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `included_overdue_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `open_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `paid_state` | State indicator used to control lifecycle transitions and filtering. | `text(2147483647)` | No | No | - | - |
| `paid_state_last_entry_time` | State indicator used to control lifecycle transitions and filtering. | `int8` | No | No | - | - |
| `inv_diff` | Business attribute `inv_diff` used by payment request specifications workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `issued_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int8` | Yes | No | - | - |
| `fiscal_reference` | Business attribute `fiscal_reference` used by payment request specifications workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `fiscal_export_token` | Business attribute `fiscal_export_token` used by payment request specifications workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (376 query files), [persons](persons.md) (349 query files), [payment_requests](payment_requests.md) (339 query files), [ar_trans](ar_trans.md) (274 query files), [centers](centers.md) (264 query files), [payment_agreements](payment_agreements.md) (143 query files).
- FK-linked tables: outgoing FK to [account_receivables](account_receivables.md); incoming FK from [ar_trans](ar_trans.md), [cashcollection_requests](cashcollection_requests.md), [payment_requests](payment_requests.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [art_match](art_match.md), [cashcollection_in](cashcollection_in.md), [cashcollectioncases](cashcollectioncases.md), [cashregistertransactions](cashregistertransactions.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md), [crt_art_link](crt_art_link.md), [employees](employees.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; change timestamps support incremental extraction and reconciliation.
