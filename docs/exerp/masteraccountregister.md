# masteraccountregister
Financial/transactional table for masteraccountregister records. It is typically used where it appears in approximately 3 query files; common companions include [product_account_configurations](product_account_configurations.md), [product_group](product_group.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - | `1001` |
| `atype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `vattype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `definition` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `available` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `trans_rebook_rule_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `trans_rebook_configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
- Commonly used with: [product_account_configurations](product_account_configurations.md) (2 query files), [product_group](product_group.md) (2 query files), [products](products.md) (2 query files), [accounts](accounts.md) (2 query files).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier.
