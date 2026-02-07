# payment_sessions
Financial/transactional table for payment sessions records. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 2 query files; common companions include [cashregisters](cashregisters.md), [cashregistertransactions](cashregistertransactions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `center` | Operational field `center` used in query filtering and reporting transformations. | `int4` | Yes | No | - | [centers](centers.md) via (`center` -> `id`) |
| `created` | Operational field `created` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `modified` | Business attribute `modified` used by payment sessions workflows and reporting. | `int8` | No | No | - | - |
| `shopping_basket_id` | Identifier for the related shopping basket entity used by this record. | `int4` | Yes | No | - | [shopping_baskets](shopping_baskets.md) via (`shopping_basket_id` -> `id`) |
| `serialized_session` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [cashregisters](cashregisters.md) (2 query files), [cashregistertransactions](cashregistertransactions.md) (2 query files), [centers](centers.md) (2 query files), [creditcardtransactions](creditcardtransactions.md) (2 query files), [invoices](invoices.md) (2 query files), [shopping_baskets](shopping_baskets.md) (2 query files).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
