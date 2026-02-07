# booking_resource_perspective
Operational table for booking resource perspective records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `center_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `resource_keys` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |

# Relations
