# apple_passes
Operational table for apple passes records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `record_id` | Identifier of the related record record. | `VARCHAR(50)` | No | No | - | - | `1001` |
| `description` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - | `Sample value` |
| `card_uid` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - | `Sample value` |
| `pass_layout_id` | Identifier of the related pass layout record. | `VARCHAR(50)` | No | No | - | - | `1001` |
| `valid_from` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `valid_until` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | No | No | - | - | `1738281600000` |
| `member_center` | Center part of the reference to related member data. | `int4` | Yes | No | - | - | `101` |
| `member_id` | Identifier of the related member record. | `int4` | Yes | No | - | - | `1001` |

# Relations
