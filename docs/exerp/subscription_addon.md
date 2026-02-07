# subscription_addon
Stores subscription-related data, including lifecycle and financial context. It is typically used where change-tracking timestamps are available; it appears in approximately 395 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `subscription_center` | Center component of the composite reference to the related subscription record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `subscription_id` | Identifier component of the composite reference to the related subscription record. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `addon_product_id` | Identifier of the related add on product definition record used by this row. | `int4` | Yes | No | [add_on_product_definition](add_on_product_definition.md) via (`addon_product_id` -> `id`) | - |
| `center_id` | Identifier for the related center entity used by this record. | `int4` | Yes | No | - | [centers](centers.md) via (`center_id` -> `id`) |
| `start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `ending_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `employee_creator_center` | Center component of the composite reference to the related employee creator record. | `int4` | Yes | No | - | - |
| `employee_creator_id` | Identifier component of the composite reference to the related employee creator record. | `int4` | Yes | No | - | - |
| `cancelled` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `quantity` | Operational field `quantity` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `use_individual_price` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `individual_price_per_unit` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `binding_end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `sales_center_id` | Identifier for the related sales center entity used by this record. | `int4` | Yes | No | - | - |
| `sales_interface` | Business attribute `sales_interface` used by subscription addon workflows and reporting. | `int4` | Yes | No | - | - |
| `period_commission` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (368 query files), [persons](persons.md) (349 query files), [masterproductregister](masterproductregister.md) (338 query files), [products](products.md) (338 query files), [centers](centers.md) (237 query files), [subscriptiontypes](subscriptiontypes.md) (218 query files).
- FK-linked tables: outgoing FK to [add_on_product_definition](add_on_product_definition.md), [subscriptions](subscriptions.md); incoming FK from [secondary_memberships](secondary_memberships.md).
- Second-level FK neighborhood includes: [add_on_to_product_group_link](add_on_to_product_group_link.md), [campaign_codes](campaign_codes.md), [centers](centers.md), [clipcards](clipcards.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [masterproductregister](masterproductregister.md), [persons](persons.md), [products](products.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation; `start_date` and `end_date` are frequently used for period-window filtering.
