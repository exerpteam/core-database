# devices
Operational table for devices records in the Exerp schema. It is typically used where it appears in approximately 20 query files; common companions include [clients](clients.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `client` | Identifier of the related clients record used by this row. | `int4` | Yes | No | [clients](clients.md) via (`client` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `driver` | Business attribute `driver` used by devices workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `enabled` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `uninstall_driver` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |

# Relations
- Commonly used with: [clients](clients.md) (18 query files), [centers](centers.md) (16 query files), [usage_point_resources](usage_point_resources.md) (5 query files), [usage_points](usage_points.md) (5 query files), [client_instances](client_instances.md) (5 query files), [gates](gates.md) (4 query files).
- FK-linked tables: outgoing FK to [clients](clients.md); incoming FK from [gates](gates.md), [usage_point_sources](usage_point_sources.md).
- Second-level FK neighborhood includes: [client_instances](client_instances.md), [systemproperties](systemproperties.md), [usage_point_resources](usage_point_resources.md), [usage_points](usage_points.md).
