# bi_decode_values
Operational table for bi decode values records in the Exerp schema. It is typically used where it appears in approximately 4 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Identifier of the record, typically unique within `center`. | `int4` | Yes | No | - | - | `1001` |
| `table_name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - | `Example Name` |
| `field_name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - | `Example Name` |
| `num_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `text_value` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - | `Sample value` |

# Relations
