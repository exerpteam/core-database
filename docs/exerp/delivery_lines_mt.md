# delivery_lines_mt
Operational table for delivery lines mt records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`)<br>[delivery](delivery.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [delivery](delivery.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `product_center` | Center component of the composite reference to the related product record. | `int4` | No | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `product_id` | Identifier component of the composite reference to the related product record. | `int4` | No | No | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `quantity` | Operational field `quantity` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `number_of_parcels` | Business attribute `number_of_parcels` used by delivery lines mt workflows and reporting. | `int4` | No | No | - | - |
| `items_per_parcel` | Business attribute `items_per_parcel` used by delivery lines mt workflows and reporting. | `int4` | No | No | - | - |
| `total_cost_price` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `manual_cost_price` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `coment` | Operational field `coment` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `error` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [centers](centers.md), [delivery](delivery.md), [products](products.md); incoming FK from [deliverylines_vat_at_link](deliverylines_vat_at_link.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
