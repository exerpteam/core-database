# pe_ext_attr_event_conditions
Operational table for pe ext attr event conditions records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `attribute_name` | Business attribute `attribute_name` used by pe ext attr event conditions workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `attribute_value` | Business attribute `attribute_value` used by pe ext attr event conditions workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `regex_value` | Business attribute `regex_value` used by pe ext attr event conditions workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |

# Relations
