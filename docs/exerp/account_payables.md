# account_payables
Financial/transactional table for account payables records. It is typically used where rows are center-scoped; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `suppliercenter` | Center component of the composite reference to the related supplier record. | `int4` | No | No | - | - |
| `supplierid` | Identifier component of the composite reference to the related supplier record. | `int4` | No | No | - | - |
| `employeecenter` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `employeeid` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `credit_max` | Business attribute `credit_max` used by account payables workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `liability_accountcenter` | Center component of the composite reference to the related liability account record. | `int4` | Yes | No | - | - |
| `liability_accountid` | Identifier component of the composite reference to the related liability account record. | `int4` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
