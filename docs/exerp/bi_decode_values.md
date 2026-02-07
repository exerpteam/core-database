# bi_decode_values
Operational table for bi decode values records in the Exerp schema. It is typically used where it appears in approximately 4 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Identifier of the record, typically unique within `center`. | `int4` | Yes | No | - | - |
| `table_name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |
| `field_name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |
| `num_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `text_value` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |

# Relations
