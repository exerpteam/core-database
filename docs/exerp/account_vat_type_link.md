# account_vat_type_link
Bridge table that links related entities for account vat type link relationships. It is typically used where it appears in approximately 38 query files; common companions include [vat_types](vat_types.md), [accounts](accounts.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `vat_type_center` | Foreign key field linking this record to `vat_types`. | `int4` | No | No | [vat_types](vat_types.md) via (`vat_type_center`, `vat_type_id` -> `center`, `id`) | - | `101` |
| `vat_type_id` | Foreign key field linking this record to `vat_types`. | `int4` | No | No | [vat_types](vat_types.md) via (`vat_type_center`, `vat_type_id` -> `center`, `id`) | - | `1001` |
| `account_vat_type_group_id` | Foreign key field linking this record to `account_vat_type_group`. | `int4` | No | No | [account_vat_type_group](account_vat_type_group.md) via (`account_vat_type_group_id` -> `id`) | - | `1001` |

# Relations
- Commonly used with: [vat_types](vat_types.md) (38 query files), [accounts](accounts.md) (35 query files), [products](products.md) (35 query files), [account_vat_type_group](account_vat_type_group.md) (34 query files), [centers](centers.md) (33 query files), [persons](persons.md) (29 query files).
- FK-linked tables: outgoing FK to [account_vat_type_group](account_vat_type_group.md), [vat_types](vat_types.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md).
