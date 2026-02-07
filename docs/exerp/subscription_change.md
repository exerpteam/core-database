# subscription_change
Stores subscription-related data, including lifecycle and financial context. It is typically used where it appears in approximately 186 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `1` |
| `change_time` | Epoch timestamp for change. | `int8` | No | No | - | - | `1738281600000` |
| `effect_date` | Date for effect. | `DATE` | No | No | - | - | `2025-01-31` |
| `cancel_time` | Epoch timestamp for cancel. | `int8` | Yes | No | - | - | `1738281600000` |
| `old_subscription_center` | Foreign key field linking this record to `subscriptions`. | `int4` | No | No | [subscriptions](subscriptions.md) via (`old_subscription_center`, `old_subscription_id` -> `center`, `id`) | - | `101` |
| `old_subscription_id` | Foreign key field linking this record to `subscriptions`. | `int4` | No | No | [subscriptions](subscriptions.md) via (`old_subscription_center`, `old_subscription_id` -> `center`, `id`) | - | `1001` |
| `new_subscription_center` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`new_subscription_center`, `new_subscription_id` -> `center`, `id`) | - | `101` |
| `new_subscription_id` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`new_subscription_center`, `new_subscription_id` -> `center`, `id`) | - | `1001` |
| `new_change_center` | Center part of the reference to related new change data. | `int4` | Yes | No | - | - | `101` |
| `new_change_id` | Identifier of the related new change record. | `int4` | Yes | No | - | - | `1001` |
| `prev_change_center` | Center part of the reference to related prev change data. | `int4` | Yes | No | - | - | `101` |
| `prev_change_id` | Identifier of the related prev change record. | `int4` | Yes | No | - | - | `1001` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `REFERENCE` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (186 query files), [persons](persons.md) (173 query files), [subscriptiontypes](subscriptiontypes.md) (169 query files), [products](products.md) (126 query files), [centers](centers.md) (122 query files), [subscription_price](subscription_price.md) (88 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [campaign_codes](campaign_codes.md), [card_clip_usages](card_clip_usages.md).
