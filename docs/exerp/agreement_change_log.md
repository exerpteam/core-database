# agreement_change_log
Stores historical/log records for agreement change events and changes. It is typically used where lifecycle state codes are present; it appears in approximately 73 query files; common companions include [account_receivables](account_receivables.md), [payment_agreements](payment_agreements.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `log_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `agreement_center` | Center component of the composite reference to the related agreement record. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - |
| `agreement_id` | Identifier component of the composite reference to the related agreement record. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - |
| `agreement_subid` | Identifier of the related payment agreements record used by this row. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `code` | Operational field `code` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `clearing_in` | Operational field `clearing_in` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (70 query files), [payment_agreements](payment_agreements.md) (68 query files), [persons](persons.md) (68 query files), [subscriptions](subscriptions.md) (49 query files), [payment_accounts](payment_accounts.md) (42 query files), [products](products.md) (40 query files).
- FK-linked tables: outgoing FK to [payment_agreements](payment_agreements.md).
- Second-level FK neighborhood includes: [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [clearinghouse_creditors](clearinghouse_creditors.md), [payment_accounts](payment_accounts.md), [postal_address](postal_address.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
