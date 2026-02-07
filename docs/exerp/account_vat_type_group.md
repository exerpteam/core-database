# account_vat_type_group
Financial/transactional table for account vat type group records. It is typically used where it appears in approximately 58 query files; common companions include [accounts](accounts.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `account_center` | Foreign key field linking this record to `accounts`. | `int4` | No | No | [accounts](accounts.md) via (`account_center`, `account_id` -> `center`, `id`) | - | `101` |
| `account_id` | Foreign key field linking this record to `accounts`. | `int4` | No | No | [accounts](accounts.md) via (`account_center`, `account_id` -> `center`, `id`) | - | `1001` |
| `global_id` | Identifier of the related global record. | `text(2147483647)` | Yes | No | - | - | `1001` |

# Relations
- Commonly used with: [accounts](accounts.md) (55 query files), [products](products.md) (55 query files), [product_account_configurations](product_account_configurations.md) (47 query files), [persons](persons.md) (45 query files), [vat_types](vat_types.md) (45 query files), [centers](centers.md) (42 query files).
- FK-linked tables: outgoing FK to [accounts](accounts.md); incoming FK from [account_vat_type_link](account_vat_type_link.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [cashregisters](cashregisters.md), [clearinghouse_creditors](clearinghouse_creditors.md), [products](products.md), [vat_types](vat_types.md).
