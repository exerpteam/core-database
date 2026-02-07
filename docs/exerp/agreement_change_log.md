# agreement_change_log
Stores historical/log records for agreement change events and changes. It is typically used where lifecycle state codes are present; it appears in approximately 73 query files; common companions include [account_receivables](account_receivables.md), [payment_agreements](payment_agreements.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `log_date` | Date for log. | `DATE` | No | No | - | - | `2025-01-31` |
| `agreement_center` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - | `101` |
| `agreement_id` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `agreement_subid` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - | `1` |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - | `1` |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `code` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `clearing_in` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `employee_center` | Center part of the reference to related employee data. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | `101` |
| `employee_id` | Identifier of the related employee record. | `int4` | Yes | No | - | - | `1001` |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (70 query files), [payment_agreements](payment_agreements.md) (68 query files), [persons](persons.md) (68 query files), [subscriptions](subscriptions.md) (49 query files), [payment_accounts](payment_accounts.md) (42 query files), [products](products.md) (40 query files).
- FK-linked tables: outgoing FK to [payment_agreements](payment_agreements.md).
- Second-level FK neighborhood includes: [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [clearinghouse_creditors](clearinghouse_creditors.md), [payment_accounts](payment_accounts.md), [postal_address](postal_address.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
