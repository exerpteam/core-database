# product_and_product_group_link
Bridge table that links related entities for product and product group link relationships. It is typically used where it appears in approximately 783 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `product_center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `product_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [products](products.md) via (`product_center`, `product_id` -> `center`, `id`) | - |
| `product_group_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [product_group](product_group.md) via (`product_group_id` -> `id`) | - |

# Relations
- Commonly used with: [products](products.md) (706 query files), [persons](persons.md) (623 query files), [centers](centers.md) (608 query files), [subscriptions](subscriptions.md) (585 query files), [product_group](product_group.md) (436 query files), [subscriptiontypes](subscriptiontypes.md) (421 query files).
- FK-linked tables: outgoing FK to [product_group](product_group.md), [products](products.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [add_on_to_product_group_link](add_on_to_product_group_link.md), [centers](centers.md), [client_profiles](client_profiles.md), [clipcardtypes](clipcardtypes.md), [colour_groups](colour_groups.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [gift_cards](gift_cards.md), [inventory_trans](inventory_trans.md).
