# account_vat_type_link
Bridge table that links related entities for account vat type link relationships. It is typically used where it appears in approximately 38 query files; common companions include [vat_types](vat_types.md), [accounts](accounts.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `vat_type_center` | Center component of the composite reference to the related vat type record. | `int4` | No | No | [vat_types](vat_types.md) via (`vat_type_center`, `vat_type_id` -> `center`, `id`) | - |
| `vat_type_id` | Identifier component of the composite reference to the related vat type record. | `int4` | No | No | [vat_types](vat_types.md) via (`vat_type_center`, `vat_type_id` -> `center`, `id`) | - |
| `account_vat_type_group_id` | Identifier of the related account vat type group record used by this row. | `int4` | No | No | [account_vat_type_group](account_vat_type_group.md) via (`account_vat_type_group_id` -> `id`) | - |

# Relations
- Commonly used with: [vat_types](vat_types.md) (38 query files), [accounts](accounts.md) (35 query files), [products](products.md) (35 query files), [account_vat_type_group](account_vat_type_group.md) (34 query files), [centers](centers.md) (33 query files), [persons](persons.md) (29 query files).
- FK-linked tables: outgoing FK to [account_vat_type_group](account_vat_type_group.md), [vat_types](vat_types.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md).
