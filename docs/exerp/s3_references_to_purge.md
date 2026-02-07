# s3_references_to_purge
Operational table for s3 references to purge records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `s3bucket` | Primary key component used to uniquely identify this record. | `VARCHAR(64)` | No | Yes | - | - |
| `s3key` | Primary key component used to uniquely identify this record. | `VARCHAR(1024)` | No | Yes | - | - |
| `entity` | Business attribute `entity` used by s3 references to purge workflows and reporting. | `VARCHAR(64)` | No | No | - | - |
| `deleted_in_s3` | Business attribute `deleted_in_s3` used by s3 references to purge workflows and reporting. | `int8` | Yes | No | - | - |
| `deleted_in_db` | Business attribute `deleted_in_db` used by s3 references to purge workflows and reporting. | `int8` | No | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `int4` | No | No | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
