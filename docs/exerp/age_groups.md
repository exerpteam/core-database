# age_groups
Operational table for age groups records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `min_age` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `max_age` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `strict_min_age` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `min_age_time_unit` | Text field containing descriptive or reference information. | `VARCHAR(6)` | Yes | No | - | - | `Sample value` |
| `max_age_time_unit` | Text field containing descriptive or reference information. | `VARCHAR(6)` | Yes | No | - | - | `Sample value` |

# Relations
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
