# subscription_change
Stores subscription-related data, including lifecycle and financial context. It is typically used where it appears in approximately 186 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `change_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `effect_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `cancel_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `old_subscription_center` | Center component of the composite reference to the related old subscription record. | `int4` | No | No | [subscriptions](subscriptions.md) via (`old_subscription_center`, `old_subscription_id` -> `center`, `id`) | - |
| `old_subscription_id` | Identifier component of the composite reference to the related old subscription record. | `int4` | No | No | [subscriptions](subscriptions.md) via (`old_subscription_center`, `old_subscription_id` -> `center`, `id`) | - |
| `new_subscription_center` | Center component of the composite reference to the related new subscription record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`new_subscription_center`, `new_subscription_id` -> `center`, `id`) | - |
| `new_subscription_id` | Identifier component of the composite reference to the related new subscription record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`new_subscription_center`, `new_subscription_id` -> `center`, `id`) | - |
| `new_change_center` | Center component of the composite reference to the related new change record. | `int4` | Yes | No | - | - |
| `new_change_id` | Identifier component of the composite reference to the related new change record. | `int4` | Yes | No | - | - |
| `prev_change_center` | Center component of the composite reference to the related prev change record. | `int4` | Yes | No | - | - |
| `prev_change_id` | Identifier component of the composite reference to the related prev change record. | `int4` | Yes | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `REFERENCE` | Operational field `REFERENCE` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (186 query files), [persons](persons.md) (173 query files), [subscriptiontypes](subscriptiontypes.md) (169 query files), [products](products.md) (126 query files), [centers](centers.md) (122 query files), [subscription_price](subscription_price.md) (88 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [campaign_codes](campaign_codes.md), [card_clip_usages](card_clip_usages.md).
