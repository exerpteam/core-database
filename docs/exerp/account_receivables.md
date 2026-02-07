# account_receivables
Financial/transactional table for account receivables records. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 1820 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `ar_type` | Classification code describing the ar type category (for example: 515005, 515030, CASH, CASH ACCOUNT). | `int4` | No | No | - | - |
| `employeecenter` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `employeeid` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `customercenter` | Center component of the composite reference to the related customer record. | `int4` | No | No | [persons](persons.md) via (`customercenter`, `customerid` -> `center`, `id`) | - |
| `customerid` | Identifier component of the composite reference to the related customer record. | `int4` | No | No | [persons](persons.md) via (`customercenter`, `customerid` -> `center`, `id`) | - |
| `debit_max` | Operational field `debit_max` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | Yes | No | - | - |
| `asset_accountcenter` | Center component of the composite reference to the related asset account record. | `int4` | Yes | No | [accounts](accounts.md) via (`asset_accountcenter`, `asset_accountid` -> `center`, `id`) | - |
| `asset_accountid` | Identifier component of the composite reference to the related asset account record. | `int4` | Yes | No | [accounts](accounts.md) via (`asset_accountcenter`, `asset_accountid` -> `center`, `id`) | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `balance` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `last_entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `last_trans_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | - |
| `collected_until` | Business attribute `collected_until` used by account receivables workflows and reporting. | `int8` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (1593 query files), [centers](centers.md) (1024 query files), [ar_trans](ar_trans.md) (869 query files), [payment_agreements](payment_agreements.md) (780 query files), [payment_accounts](payment_accounts.md) (614 query files), [subscriptions](subscriptions.md) (600 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md), [employees](employees.md), [persons](persons.md); incoming FK from [ar_trans](ar_trans.md), [cashcollectioncases](cashcollectioncases.md), [payment_accounts](payment_accounts.md), [payment_request_specifications](payment_request_specifications.md), [payment_requests](payment_requests.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md), [advance_notices](advance_notices.md), [art_match](art_match.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
