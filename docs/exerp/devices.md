# devices
Operational table for devices records in the Exerp schema. It is typically used where it appears in approximately 20 query files; common companions include [clients](clients.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `client` | Foreign key field linking this record to `clients`. | `int4` | Yes | No | [clients](clients.md) via (`client` -> `id`) | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `driver` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `enabled` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `uninstall_driver` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |

# Relations
- Commonly used with: [clients](clients.md) (18 query files), [centers](centers.md) (16 query files), [usage_point_resources](usage_point_resources.md) (5 query files), [usage_points](usage_points.md) (5 query files), [client_instances](client_instances.md) (5 query files), [gates](gates.md) (4 query files).
- FK-linked tables: outgoing FK to [clients](clients.md); incoming FK from [gates](gates.md), [usage_point_sources](usage_point_sources.md).
- Second-level FK neighborhood includes: [client_instances](client_instances.md), [systemproperties](systemproperties.md), [usage_point_resources](usage_point_resources.md), [usage_points](usage_points.md).
