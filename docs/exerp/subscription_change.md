# subscription_change
Stores subscription-related data, including lifecycle and financial context. It is typically used where it appears in approximately 186 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `change_time` | Epoch timestamp for change. | `int8` | No | No | - | - |
| `effect_date` | Date for effect. | `DATE` | No | No | - | - |
| `cancel_time` | Epoch timestamp for cancel. | `int8` | Yes | No | - | - |
| `old_subscription_center` | Foreign key field linking this record to `subscriptions`. | `int4` | No | No | [subscriptions](subscriptions.md) via (`old_subscription_center`, `old_subscription_id` -> `center`, `id`) | - |
| `old_subscription_id` | Foreign key field linking this record to `subscriptions`. | `int4` | No | No | [subscriptions](subscriptions.md) via (`old_subscription_center`, `old_subscription_id` -> `center`, `id`) | - |
| `new_subscription_center` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`new_subscription_center`, `new_subscription_id` -> `center`, `id`) | - |
| `new_subscription_id` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`new_subscription_center`, `new_subscription_id` -> `center`, `id`) | - |
| `new_change_center` | Center part of the reference to related new change data. | `int4` | Yes | No | - | - |
| `new_change_id` | Identifier of the related new change record. | `int4` | Yes | No | - | - |
| `prev_change_center` | Center part of the reference to related prev change data. | `int4` | Yes | No | - | - |
| `prev_change_id` | Identifier of the related prev change record. | `int4` | Yes | No | - | - |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `REFERENCE` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (186 query files), [persons](persons.md) (173 query files), [subscriptiontypes](subscriptiontypes.md) (169 query files), [products](products.md) (126 query files), [centers](centers.md) (122 query files), [subscription_price](subscription_price.md) (88 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [campaign_codes](campaign_codes.md), [card_clip_usages](card_clip_usages.md).
