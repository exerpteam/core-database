# pe_ext_attr_event_conditions
Operational table for pe ext attr event conditions records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `attribute_name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `attribute_value` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `regex_value` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - |

# Relations
