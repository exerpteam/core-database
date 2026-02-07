# account_payables
Financial/transactional table for account payables records. It is typically used where rows are center-scoped; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `suppliercenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `supplierid` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `employeecenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `employeeid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `credit_max` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `liability_accountcenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `liability_accountid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
