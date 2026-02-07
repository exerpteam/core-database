# db_updates
Operational table for db updates records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `customer` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `major` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | Yes | - | - |
| `minor` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | Yes | - | - |
| `revision` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | Yes | - | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `duration` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - |
| `type` | Text field containing descriptive or reference information. | `VARCHAR(10)` | No | Yes | - | - |
| `version_id` | Foreign key field linking this record to `db_version`. | `int4` | No | No | [db_version](db_version.md) via (`version_id` -> `id`) | - |
| `mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [db_version](db_version.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
