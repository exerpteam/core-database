# apple_passes
Operational table for apple passes records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `record_id` | Identifier of the related record record. | `VARCHAR(50)` | No | No | - | - |
| `description` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - |
| `card_uid` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - |
| `pass_layout_id` | Identifier of the related pass layout record. | `VARCHAR(50)` | No | No | - | - |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `valid_until` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | No | No | - | - |
| `member_center` | Center part of the reference to related member data. | `int4` | Yes | No | - | - |
| `member_id` | Identifier of the related member record. | `int4` | Yes | No | - | - |

# Relations
