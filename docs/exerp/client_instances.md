# client_instances
Operational table for client instances records in the Exerp schema. It is typically used where it appears in approximately 24 query files; common companions include [clients](clients.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `client` | Foreign key field linking this record to `clients`. | `int4` | No | No | [clients](clients.md) via (`client` -> `id`) | - |
| `session_id` | Identifier of the related session record. | `text(2147483647)` | Yes | No | - | - |
| `ipaddress` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `macaddress` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `username` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `hostname` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `javainfo` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `osinfo` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `clientname` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `locale` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - |
| `startuptime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `shutdowntime` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `clientversion` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `certificate_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `jvm_arch` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - |
| `bootstrap_version` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |
| `jms_token` | Text field containing descriptive or reference information. | `VARCHAR(30)` | Yes | No | - | - |

# Relations
- Commonly used with: [clients](clients.md) (22 query files), [centers](centers.md) (13 query files), [devices](devices.md) (5 query files), [cashregisters](cashregisters.md) (4 query files), [systemproperties](systemproperties.md) (2 query files).
- FK-linked tables: outgoing FK to [clients](clients.md); incoming FK from [error_reports](error_reports.md), [log_in_log](log_in_log.md).
- Second-level FK neighborhood includes: [devices](devices.md), [systemproperties](systemproperties.md), [usage_point_sources](usage_point_sources.md).
