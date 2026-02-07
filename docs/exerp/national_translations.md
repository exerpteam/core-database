# national_translations
Operational table for national translations records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `original_text` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | Yes | - | - |
| `country` | Country code linked to the record. | `VARCHAR(2)` | No | Yes | - | - |
| `translat` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `field` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
