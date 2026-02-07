# unplaced_payments
Financial/transactional table for unplaced payments records. It is typically used where lifecycle state codes are present; it appears in approximately 6 query files; common companions include [account_receivables](account_receivables.md), [clearing_in](clearing_in.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | - |
| `xfr_delivery` | Identifier of the related clearing in record used by this row. | `int4` | Yes | No | [clearing_in](clearing_in.md) via (`xfr_delivery` -> `id`) | - |
| `xfr_rec_no` | Business attribute `xfr_rec_no` used by unplaced payments workflows and reporting. | `int4` | Yes | No | - | - |
| `xfr_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `xfr_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `xfr_info` | Operational field `xfr_info` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `xfr_text` | Business attribute `xfr_text` used by unplaced payments workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `xfr_debitor_id` | Identifier for the related xfr debitor entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `xfr_creditor_id` | Identifier for the related xfr creditor entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `account_center` | Center component of the composite reference to the related account record. | `int4` | Yes | No | - | [accounts](accounts.md) via (`account_center`, `account_id` -> `center`, `id`) |
| `account_id` | Identifier component of the composite reference to the related account record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (5 query files), [clearing_in](clearing_in.md) (4 query files), [persons](persons.md) (4 query files), [payment_requests](payment_requests.md) (4 query files), [clearinghouses](clearinghouses.md) (3 query files), [clearinghouse_creditors](clearinghouse_creditors.md) (2 query files).
- FK-linked tables: outgoing FK to [clearing_in](clearing_in.md).
- Second-level FK neighborhood includes: [clearinghouses](clearinghouses.md), [exchanged_file](exchanged_file.md), [payment_requests](payment_requests.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
