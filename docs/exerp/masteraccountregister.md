# masteraccountregister
Financial/transactional table for masteraccountregister records. It is typically used where it appears in approximately 3 query files; common companions include [product_account_configurations](product_account_configurations.md), [product_group](product_group.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `globalid` | Operational field `globalid` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `atype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `vattype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `definition` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `available` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `trans_rebook_rule_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `trans_rebook_configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [product_account_configurations](product_account_configurations.md) (2 query files), [product_group](product_group.md) (2 query files), [products](products.md) (2 query files), [accounts](accounts.md) (2 query files).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier.
