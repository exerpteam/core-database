# jbm_counter
Operational table for jbm counter records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(255)` | No | Yes | - | - | `Example Name` |
| `next_id` | Identifier of the related next record. | `int8` | Yes | No | - | - | `1001` |

# Relations
