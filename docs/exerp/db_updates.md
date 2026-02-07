# db_updates
Operational table for db updates records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `customer` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `major` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | Yes | - | - | `42` |
| `minor` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | Yes | - | - | `42` |
| `revision` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | Yes | - | - | `42` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `duration` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - | `1` |
| `type` | Text field containing descriptive or reference information. | `VARCHAR(10)` | No | Yes | - | - | `1` |
| `version_id` | Foreign key field linking this record to `db_version`. | `int4` | No | No | [db_version](db_version.md) via (`version_id` -> `id`) | - | `1001` |
| `mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |

# Relations
- FK-linked tables: outgoing FK to [db_version](db_version.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
