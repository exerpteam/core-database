# subscription_price
Stores subscription-related data, including lifecycle and financial context. It is typically used where change-tracking timestamps are available; it appears in approximately 813 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `from_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `to_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `subscription_center` | Center component of the composite reference to the related subscription record. | `int4` | No | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `subscription_id` | Identifier component of the composite reference to the related subscription record. | `int4` | No | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `price` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `binding` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `notified` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `applied` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `cancelled` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `approved` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `pending` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `approved_employee_center` | Center component of the composite reference to the related approved employee record. | `int4` | Yes | No | - | - |
| `approved_employee_id` | Identifier component of the composite reference to the related approved employee record. | `int4` | Yes | No | - | - |
| `approved_entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `cancelled_employee_center` | Center component of the composite reference to the related cancelled employee record. | `int4` | Yes | No | - | - |
| `cancelled_employee_id` | Identifier component of the composite reference to the related cancelled employee record. | `int4` | Yes | No | - | - |
| `cancelled_entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `aggregated_change_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `template_id` | Identifier for the related template entity used by this record. | `int4` | Yes | No | - | [templates](templates.md) via (`template_id` -> `id`) |
| `event_config_id` | Identifier for the related event config entity used by this record. | `int4` | Yes | No | - | - |
| `prorata_sessions` | Business attribute `prorata_sessions` used by subscription price workflows and reporting. | `int4` | Yes | No | - | - |
| `prorata_sessions_total` | Business attribute `prorata_sessions_total` used by subscription price workflows and reporting. | `int4` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (794 query files), [persons](persons.md) (696 query files), [products](products.md) (675 query files), [centers](centers.md) (529 query files), [subscriptiontypes](subscriptiontypes.md) (515 query files), [person_ext_attrs](person_ext_attrs.md) (337 query files).
- FK-linked tables: outgoing FK to [employees](employees.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [campaign_codes](campaign_codes.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
