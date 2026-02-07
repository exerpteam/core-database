# client_instances
Operational table for client instances records in the Exerp schema. It is typically used where it appears in approximately 24 query files; common companions include [clients](clients.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `client` | Identifier of the related clients record used by this row. | `int4` | No | No | [clients](clients.md) via (`client` -> `id`) | - |
| `session_id` | Identifier for the related session entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `ipaddress` | Business attribute `ipaddress` used by client instances workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `macaddress` | Business attribute `macaddress` used by client instances workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `username` | Business attribute `username` used by client instances workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `hostname` | Business attribute `hostname` used by client instances workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `javainfo` | Business attribute `javainfo` used by client instances workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `osinfo` | Business attribute `osinfo` used by client instances workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `clientname` | Business attribute `clientname` used by client instances workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `locale` | Business attribute `locale` used by client instances workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `startuptime` | Business attribute `startuptime` used by client instances workflows and reporting. | `int8` | No | No | - | - |
| `shutdowntime` | Business attribute `shutdowntime` used by client instances workflows and reporting. | `int8` | Yes | No | - | - |
| `clientversion` | Business attribute `clientversion` used by client instances workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `certificate_name` | Business attribute `certificate_name` used by client instances workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `jvm_arch` | Business attribute `jvm_arch` used by client instances workflows and reporting. | `VARCHAR(20)` | Yes | No | - | - |
| `bootstrap_version` | Business attribute `bootstrap_version` used by client instances workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |
| `jms_token` | Business attribute `jms_token` used by client instances workflows and reporting. | `VARCHAR(30)` | Yes | No | - | - |

# Relations
- Commonly used with: [clients](clients.md) (22 query files), [centers](centers.md) (13 query files), [devices](devices.md) (5 query files), [cashregisters](cashregisters.md) (4 query files), [systemproperties](systemproperties.md) (2 query files).
- FK-linked tables: outgoing FK to [clients](clients.md); incoming FK from [error_reports](error_reports.md), [log_in_log](log_in_log.md).
- Second-level FK neighborhood includes: [devices](devices.md), [systemproperties](systemproperties.md), [usage_point_sources](usage_point_sources.md).
