# master_vat_types
Operational table for master vat types records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `globalid` | Operational field `globalid` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `master_account` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | No | No | - | - |
| `rate` | Operational field `rate` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | No | No | - | - |
| `orig_rate` | Business attribute `orig_rate` used by master vat types workflows and reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `definition` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `available` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Interesting data points: `external_id` is commonly used as an integration-facing identifier.
