# subscription_reduced_period
Stores subscription-related data, including lifecycle and financial context. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 122 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `freeze_period` | Identifier of the related subscription freeze period record used by this row. | `int4` | Yes | No | [subscription_freeze_period](subscription_freeze_period.md) via (`freeze_period` -> `id`) | - |
| `main_reduced_period` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [subscription_reduced_period](subscription_reduced_period.md) via (`main_reduced_period` -> `id`) | - |
| `subscription_center` | Center component of the composite reference to the related subscription record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `subscription_id` | Identifier component of the composite reference to the related subscription record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `cancel_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `cancel_employee_center` | Center component of the composite reference to the staff member performing the change. | `int4` | Yes | No | [employees](employees.md) via (`cancel_employee_center`, `cancel_employee_id` -> `center`, `id`) | - |
| `cancel_employee_id` | Identifier component of the composite reference to the staff member performing the change. | `int4` | Yes | No | [employees](employees.md) via (`cancel_employee_center`, `cancel_employee_id` -> `center`, `id`) | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (120 query files), [persons](persons.md) (82 query files), [products](products.md) (78 query files), [subscriptiontypes](subscriptiontypes.md) (78 query files), [centers](centers.md) (70 query files), [subscription_price](subscription_price.md) (50 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [subscription_freeze_period](subscription_freeze_period.md), [subscription_reduced_period](subscription_reduced_period.md), [subscriptions](subscriptions.md); incoming FK from [subscription_blocked_period](subscription_blocked_period.md), [subscription_reduced_period](subscription_reduced_period.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [campaign_codes](campaign_codes.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation; `start_date` and `end_date` are frequently used for period-window filtering.
