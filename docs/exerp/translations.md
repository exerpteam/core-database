# translations
Operational table for translations records in the Exerp schema. It is typically used where change-tracking timestamps are available.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `source_type` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - |
| `source_key` | Text field containing descriptive or reference information. | `VARCHAR(4000)` | No | No | - | - |
| `language_type` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - |
| `translated` | Text field containing descriptive or reference information. | `VARCHAR(4000)` | No | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | No | No | - | - |
| `last_modified_by_center` | Center part of the reference to related last modified by data. | `int4` | No | No | - | - |
| `last_modified_by_id` | Identifier of the related last modified by record. | `int4` | No | No | - | - |

# Relations
- Interesting data points: change timestamps support incremental extraction and reconciliation.
