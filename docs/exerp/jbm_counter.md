# jbm_counter
Operational table for jbm counter records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `name` | Primary key identifier for this record. | `VARCHAR(255)` | No | Yes | - | - |
| `next_id` | Identifier for the related next entity used by this record. | `int8` | Yes | No | - | - |

# Relations
