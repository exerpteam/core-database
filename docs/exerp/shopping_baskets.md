# shopping_baskets
Operational table for shopping baskets records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 4 query files; common companions include [centers](centers.md), [cashregisters](cashregisters.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - |
| `origin` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `center` | Center identifier associated with the record. | `int4` | Yes | No | - | [centers](centers.md) via (`center` -> `id`) |
| `client_center` | Center part of the reference to related client data. | `int4` | Yes | No | - | [clients](clients.md) via (`client_center`, `client_id` -> `center`, `id`) |
| `client_id` | Identifier of the related client record. | `int4` | Yes | No | - | - |
| `employee_center` | Center part of the reference to related employee data. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier of the related employee record. | `int4` | Yes | No | - | - |
| `created` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `modified` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `serialized_session` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `VARCHAR(50)` | Yes | No | - | - |
| `configurable_payment_method` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `cash_register_id` | Identifier of the related cash register record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (3 query files), [cashregisters](cashregisters.md) (2 query files), [cashregistertransactions](cashregistertransactions.md) (2 query files), [creditcardtransactions](creditcardtransactions.md) (2 query files), [invoices](invoices.md) (2 query files), [payment_sessions](payment_sessions.md) (2 query files).
- FK-linked tables: incoming FK from [shopping_basket_invoice_link](shopping_basket_invoice_link.md).
- Second-level FK neighborhood includes: [invoices](invoices.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
