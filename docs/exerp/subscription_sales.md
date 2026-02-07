# subscription_sales
Stores subscription-related data, including lifecycle and financial context. It is typically used where change-tracking timestamps are available; it appears in approximately 368 query files; common companions include [persons](persons.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `owner_center` | Center component of the composite reference to the owner person. | `int4` | No | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `owner_id` | Identifier component of the composite reference to the owner person. | `int4` | No | No | [persons](persons.md) via (`owner_center`, `owner_id` -> `center`, `id`) | - |
| `owner_type` | Classification code describing the owner type category (for example: CORPORATE, FAMILY, FRIEND, ONEMANCORPORATE). | `int4` | No | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `company_center` | Center component of the composite reference to the related company record. | `int4` | Yes | No | [persons](persons.md) via (`company_center`, `company_id` -> `center`, `id`) | - |
| `company_id` | Identifier component of the composite reference to the related company record. | `int4` | Yes | No | [persons](persons.md) via (`company_center`, `company_id` -> `center`, `id`) | - |
| `subscription_type_center` | Center component of the composite reference to the related subscription type record. | `int4` | No | No | [products](products.md) via (`subscription_type_center`, `subscription_type_id` -> `center`, `id`)<br>[subscriptiontypes](subscriptiontypes.md) via (`subscription_type_center`, `subscription_type_id` -> `center`, `id`) | - |
| `subscription_type_id` | Identifier component of the composite reference to the related subscription type record. | `int4` | No | No | [products](products.md) via (`subscription_type_center`, `subscription_type_id` -> `center`, `id`)<br>[subscriptiontypes](subscriptiontypes.md) via (`subscription_type_center`, `subscription_type_id` -> `center`, `id`) | - |
| `subscription_type_type` | Classification code describing the subscription type type category (for example: CASH, Cash, EFT, Prospect). | `int4` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `int4` | No | No | - | - |
| `price_new` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_new_sponsored` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_new_discount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_initial` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_initial_sponsored` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_initial_discount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_period` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `price_admin_fee` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_admin_fee_sponsored` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_admin_fee_discount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `credited` | Operational field `credited` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | Yes | No | - | - |
| `binding_days` | Business attribute `binding_days` used by subscription sales workflows and reporting. | `int4` | Yes | No | - | - |
| `start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `sales_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `subscription_center` | Center component of the composite reference to the related subscription record. | `int4` | Yes | No | [centers](centers.md) via (`subscription_center` -> `id`)<br>[subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `subscription_id` | Identifier component of the composite reference to the related subscription record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `cancellation_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `termination_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `cancellation_employee_center` | Center component of the composite reference to the related cancellation employee record. | `int4` | Yes | No | - | - |
| `cancellation_employee_id` | Identifier component of the composite reference to the related cancellation employee record. | `int4` | Yes | No | - | - |
| `price_prorata` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_prorata_sponsored` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_prorata_discount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `contract_excluding_sponsor` | Business attribute `contract_excluding_sponsor` used by subscription sales workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `contract_including_sponsor` | Business attribute `contract_including_sponsor` used by subscription sales workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `contract_sponsored` | Business attribute `contract_sponsored` used by subscription sales workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `signatures_completed_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (347 query files), [subscriptions](subscriptions.md) (323 query files), [products](products.md) (315 query files), [centers](centers.md) (253 query files), [subscriptiontypes](subscriptiontypes.md) (248 query files), [person_ext_attrs](person_ext_attrs.md) (185 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [employees](employees.md), [persons](persons.md), [products](products.md), [subscriptions](subscriptions.md), [subscriptiontypes](subscriptiontypes.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [attends](attends.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation; `start_date` and `end_date` are frequently used for period-window filtering.
