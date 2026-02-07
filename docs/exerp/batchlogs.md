# batchlogs
Stores historical/log records for batchlogs events and changes. It is typically used where lifecycle state codes are present; it appears in approximately 3 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `jobname` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `completiontime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `errors` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `fatalerrors` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `status` | Lifecycle status code for the record. | `int4` | Yes | No | - | - |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `startdate` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - |
| `node` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `entity` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
