# apple_passes
Operational table for apple passes records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `record_id` | Identifier for the related record entity used by this record. | `VARCHAR(50)` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `VARCHAR(100)` | No | No | - | - |
| `card_uid` | Business attribute `card_uid` used by apple passes workflows and reporting. | `VARCHAR(50)` | No | No | - | - |
| `pass_layout_id` | Identifier for the related pass layout entity used by this record. | `VARCHAR(50)` | No | No | - | - |
| `valid_from` | Operational field `valid_from` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `valid_until` | Operational field `valid_until` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `member_center` | Center component of the composite reference to the related member record. | `int4` | Yes | No | - | - |
| `member_id` | Identifier component of the composite reference to the related member record. | `int4` | Yes | No | - | - |

# Relations
