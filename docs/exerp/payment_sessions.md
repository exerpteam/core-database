# payment_sessions
Financial/transactional table for payment sessions records. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 2 query files; common companions include [cashregisters](cashregisters.md), [cashregistertransactions](cashregistertransactions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `center` | Center identifier associated with the record. | `int4` | Yes | No | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `created` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `modified` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `shopping_basket_id` | Identifier of the related shopping basket record. | `int4` | Yes | No | - | [shopping_baskets](shopping_baskets.md) via (`shopping_basket_id` -> `id`) | `1001` |
| `serialized_session` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
- Commonly used with: [cashregisters](cashregisters.md) (2 query files), [cashregistertransactions](cashregistertransactions.md) (2 query files), [centers](centers.md) (2 query files), [creditcardtransactions](creditcardtransactions.md) (2 query files), [invoices](invoices.md) (2 query files), [shopping_baskets](shopping_baskets.md) (2 query files).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
