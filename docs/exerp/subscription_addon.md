# subscription_addon
Stores subscription-related data, including lifecycle and financial context. It is typically used where change-tracking timestamps are available; it appears in approximately 395 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `subscription_center` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - | `101` |
| `subscription_id` | Foreign key field linking this record to `subscriptions`. | `int4` | Yes | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - | `1001` |
| `addon_product_id` | Foreign key field linking this record to `add_on_product_definition`. | `int4` | Yes | No | [add_on_product_definition](add_on_product_definition.md) via (`addon_product_id` -> `id`) | - | `1001` |
| `center_id` | Identifier of the related center record. | `int4` | Yes | No | - | [centers](centers.md) via (`center_id` -> `id`) | `1001` |
| `start_date` | Date when the record becomes effective. | `DATE` | No | No | - | - | `2025-01-31` |
| `end_date` | Date when the record ends or expires. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - | `1738281600000` |
| `ending_time` | Epoch timestamp for ending. | `int8` | Yes | No | - | - | `1738281600000` |
| `employee_creator_center` | Center part of the reference to related employee creator data. | `int4` | Yes | No | - | - | `101` |
| `employee_creator_id` | Identifier of the related employee creator record. | `int4` | Yes | No | - | - | `1001` |
| `cancelled` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `use_individual_price` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `individual_price_per_unit` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `binding_end_date` | Date for binding end. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `sales_center_id` | Identifier of the related sales center record. | `int4` | Yes | No | - | - | `1001` |
| `sales_interface` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `period_commission` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (368 query files), [persons](persons.md) (349 query files), [masterproductregister](masterproductregister.md) (338 query files), [products](products.md) (338 query files), [centers](centers.md) (237 query files), [subscriptiontypes](subscriptiontypes.md) (218 query files).
- FK-linked tables: outgoing FK to [add_on_product_definition](add_on_product_definition.md), [subscriptions](subscriptions.md); incoming FK from [secondary_memberships](secondary_memberships.md).
- Second-level FK neighborhood includes: [add_on_to_product_group_link](add_on_to_product_group_link.md), [campaign_codes](campaign_codes.md), [centers](centers.md), [clipcards](clipcards.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [masterproductregister](masterproductregister.md), [persons](persons.md), [products](products.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation; `start_date` and `end_date` are frequently used for period-window filtering.
