# master_vat_types
Operational table for master vat types records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `master_account` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `rate` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `orig_rate` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |
| `definition` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `available` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |

# Relations
- Interesting data points: `external_id` is commonly used as an integration-facing identifier.
