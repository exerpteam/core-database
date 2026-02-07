# db_updates
Operational table for db updates records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `customer` | Operational field `customer` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `major` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `minor` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `revision` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `starttime` | Operational field `starttime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `duration` | Operational field `duration` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `type` | Primary key component used to uniquely identify this record. | `VARCHAR(10)` | No | Yes | - | - |
| `version_id` | Identifier of the related db version record used by this row. | `int4` | No | No | [db_version](db_version.md) via (`version_id` -> `id`) | - |
| `mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [db_version](db_version.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
