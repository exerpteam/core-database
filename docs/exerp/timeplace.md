# timeplace
Operational table for timeplace records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `timerestriction` | Binary payload storing structured runtime data for this record. | `bytea` | No | No | - | - |

# Relations
