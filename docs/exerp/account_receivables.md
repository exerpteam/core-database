# account_receivables
Financial/transactional table for account receivables records. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 1820 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `ar_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `employeecenter` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `employeeid` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `customercenter` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`customercenter`, `customerid` -> `center`, `id`) | - |
| `customerid` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`customercenter`, `customerid` -> `center`, `id`) | - |
| `debit_max` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `asset_accountcenter` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`asset_accountcenter`, `asset_accountid` -> `center`, `id`) | - |
| `asset_accountid` | Foreign key field linking this record to `accounts`. | `int4` | Yes | No | [accounts](accounts.md) via (`asset_accountcenter`, `asset_accountid` -> `center`, `id`) | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |
| `balance` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `last_entry_time` | Epoch timestamp for last entry. | `int8` | Yes | No | - | - |
| `last_trans_time` | Epoch timestamp for last trans. | `int8` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - |
| `collected_until` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (1593 query files), [centers](centers.md) (1024 query files), [ar_trans](ar_trans.md) (869 query files), [payment_agreements](payment_agreements.md) (780 query files), [payment_accounts](payment_accounts.md) (614 query files), [subscriptions](subscriptions.md) (600 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md), [employees](employees.md), [persons](persons.md); incoming FK from [ar_trans](ar_trans.md), [cashcollectioncases](cashcollectioncases.md), [payment_accounts](payment_accounts.md), [payment_request_specifications](payment_request_specifications.md), [payment_requests](payment_requests.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md), [advance_notices](advance_notices.md), [art_match](art_match.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
