# client_instances
Operational table for client instances records in the Exerp schema. It is typically used where it appears in approximately 24 query files; common companions include [clients](clients.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `client` | Foreign key field linking this record to `clients`. | `int4` | No | No | [clients](clients.md) via (`client` -> `id`) | - | `42` |
| `session_id` | Identifier of the related session record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `ipaddress` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `macaddress` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `username` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `hostname` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `javainfo` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `osinfo` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `clientname` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `locale` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - | `1738281600000` |
| `startuptime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `shutdowntime` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `1738281600000` |
| `clientversion` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `certificate_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `jvm_arch` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - | `Sample value` |
| `bootstrap_version` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - | `Sample value` |
| `jms_token` | Text field containing descriptive or reference information. | `VARCHAR(30)` | Yes | No | - | - | `Sample value` |

# Relations
- Commonly used with: [clients](clients.md) (22 query files), [centers](centers.md) (13 query files), [devices](devices.md) (5 query files), [cashregisters](cashregisters.md) (4 query files), [systemproperties](systemproperties.md) (2 query files).
- FK-linked tables: outgoing FK to [clients](clients.md); incoming FK from [error_reports](error_reports.md), [log_in_log](log_in_log.md).
- Second-level FK neighborhood includes: [devices](devices.md), [systemproperties](systemproperties.md), [usage_point_sources](usage_point_sources.md).
