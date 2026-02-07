# subscription_freeze_period
Stores subscription-related data, including lifecycle and financial context. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 240 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `subscription_center` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - | `101` |
| `subscription_id` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - | `1001` |
| `start_invoice_line_center` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`start_invoice_line_center`, `start_invoice_line_id`, `start_invoice_line_subid` -> `center`, `id`, `subid`) | - | `101` |
| `start_invoice_line_id` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`start_invoice_line_center`, `start_invoice_line_id`, `start_invoice_line_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `start_invoice_line_subid` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`start_invoice_line_center`, `start_invoice_line_id`, `start_invoice_line_subid` -> `center`, `id`, `subid`) | - | `1` |
| `start_date` | Date when the record becomes effective. | `DATE` | No | No | - | - | `2025-01-31` |
| `end_date` | Date when the record ends or expires. | `DATE` | No | No | - | - | `2025-01-31` |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `1` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `cancel_time` | Epoch timestamp for cancel. | `int8` | Yes | No | - | - | `1738281600000` |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `entry_interface_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `cancel_employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`cancel_employee_center`, `cancel_employee_id` -> `center`, `id`) | - | `101` |
| `cancel_employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`cancel_employee_center`, `cancel_employee_id` -> `center`, `id`) | - | `1001` |
| `cancel_interface_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `end_notified` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (227 query files), [persons](persons.md) (188 query files), [subscriptiontypes](subscriptiontypes.md) (166 query files), [products](products.md) (163 query files), [centers](centers.md) (150 query files), [subscription_price](subscription_price.md) (96 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [invoice_lines_mt](invoice_lines_mt.md), [subscriptions](subscriptions.md); incoming FK from [subscription_blocked_period](subscription_blocked_period.md), [subscription_reduced_period](subscription_reduced_period.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [bundle_campaign_usages](bundle_campaign_usages.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation; `start_date` and `end_date` are frequently used for period-window filtering.
