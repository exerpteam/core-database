# national_translations
Operational table for national translations records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `original_text` | Primary key component used to uniquely identify this record. | `VARCHAR(100)` | No | Yes | - | - |
| `country` | Primary key component used to uniquely identify this record. | `VARCHAR(2)` | No | Yes | - | - |
| `translat` | Business attribute `translat` used by national translations workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `field` | Operational field `field` used in query filtering and reporting transformations. | `int4` | No | No | - | - |

# Relations
