# delivery_lines_mt
Operational table for delivery lines mt records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`)<br>[delivery](delivery.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [delivery](delivery.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `product_center` | Foreign key field linking this record to `products`. | `int4` | No | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `product_id` | Foreign key field linking this record to `products`. | `int4` | No | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `number_of_parcels` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `items_per_parcel` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `total_cost_price` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `manual_cost_price` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `coment` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `error` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [centers](centers.md), [delivery](delivery.md), [products](products.md); incoming FK from [deliverylines_vat_at_link](deliverylines_vat_at_link.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
