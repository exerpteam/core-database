# translations
Operational table for translations records in the Exerp schema. It is typically used where change-tracking timestamps are available.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `source_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(100)` | No | No | - | - |
| `source_key` | Business attribute `source_key` used by translations workflows and reporting. | `VARCHAR(4000)` | No | No | - | - |
| `language_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(50)` | No | No | - | - |
| `translated` | Business attribute `translated` used by translations workflows and reporting. | `VARCHAR(4000)` | No | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `last_modified_by_center` | Center component of the composite reference to the related last modified by record. | `int4` | No | No | - | - |
| `last_modified_by_id` | Identifier component of the composite reference to the related last modified by record. | `int4` | No | No | - | - |

# Relations
- Interesting data points: change timestamps support incremental extraction and reconciliation.
