# batchlogs
Stores historical/log records for batchlogs events and changes. It is typically used where lifecycle state codes are present; it appears in approximately 3 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `jobname` | Business attribute `jobname` used by batchlogs workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `completiontime` | Business attribute `completiontime` used by batchlogs workflows and reporting. | `int8` | No | No | - | - |
| `errors` | Business attribute `errors` used by batchlogs workflows and reporting. | `int4` | No | No | - | - |
| `fatalerrors` | Business attribute `fatalerrors` used by batchlogs workflows and reporting. | `int4` | No | No | - | - |
| `mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `int4` | Yes | No | - | - |
| `starttime` | Operational field `starttime` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `startdate` | Operational field `startdate` used in query filtering and reporting transformations. | `DATE` | Yes | No | - | - |
| `node` | Business attribute `node` used by batchlogs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `entity` | Business attribute `entity` used by batchlogs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
