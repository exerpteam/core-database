# shopping_baskets
Operational table for shopping baskets records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 4 query files; common companions include [centers](centers.md), [cashregisters](cashregisters.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `origin` | Business attribute `origin` used by shopping baskets workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `center` | Operational field `center` used in query filtering and reporting transformations. | `int4` | Yes | No | - | [centers](centers.md) via (`center` -> `id`) |
| `client_center` | Center component of the composite reference to the related client record. | `int4` | Yes | No | - | [clients](clients.md) via (`client_center`, `client_id` -> `center`, `id`) |
| `client_id` | Identifier component of the composite reference to the related client record. | `int4` | Yes | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `created` | Operational field `created` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `modified` | Business attribute `modified` used by shopping baskets workflows and reporting. | `int8` | No | No | - | - |
| `serialized_session` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `VARCHAR(50)` | Yes | No | - | - |
| `configurable_payment_method` | Business attribute `configurable_payment_method` used by shopping baskets workflows and reporting. | `int4` | Yes | No | - | - |
| `cash_register_id` | Identifier for the related cash register entity used by this record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (3 query files), [cashregisters](cashregisters.md) (2 query files), [cashregistertransactions](cashregistertransactions.md) (2 query files), [creditcardtransactions](creditcardtransactions.md) (2 query files), [invoices](invoices.md) (2 query files), [payment_sessions](payment_sessions.md) (2 query files).
- FK-linked tables: incoming FK from [shopping_basket_invoice_link](shopping_basket_invoice_link.md).
- Second-level FK neighborhood includes: [invoices](invoices.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
