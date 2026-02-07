# bi_decode_values
Operational table for bi decode values records in the Exerp schema. It is typically used where it appears in approximately 4 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Identifier for this record. | `int4` | Yes | No | - | - |
| `table_name` | Business attribute `table_name` used by bi decode values workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |
| `field_name` | Business attribute `field_name` used by bi decode values workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |
| `num_value` | Business attribute `num_value` used by bi decode values workflows and reporting. | `int4` | Yes | No | - | - |
| `text_value` | Business attribute `text_value` used by bi decode values workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |

# Relations
