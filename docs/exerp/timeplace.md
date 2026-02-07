# timeplace
Operational table for timeplace records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `timerestriction` | Table field used by operational and reporting workloads. | `bytea` | No | No | - | - |

# Relations
