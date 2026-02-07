# usage_point_sources
Operational table for usage point sources records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 6 query files; common companions include [booking_resources](booking_resources.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `usage_point_center` | Foreign key field linking this record to `usage_points`. | `int4` | Yes | No | [usage_points](usage_points.md) via (`usage_point_center`, `usage_point_id` -> `center`, `id`) | - |
| `usage_point_id` | Foreign key field linking this record to `usage_points`. | `int4` | Yes | No | [usage_points](usage_points.md) via (`usage_point_center`, `usage_point_id` -> `center`, `id`) | - |
| `client_id` | Foreign key field linking this record to `clients`. | `int4` | Yes | No | [clients](clients.md) via (`client_id` -> `id`) | - |
| `reader_device_id` | Foreign key field linking this record to `devices`. | `int4` | Yes | No | [devices](devices.md) via (`reader_device_id` -> `id`) | - |
| `reader_device_sub_id` | Identifier of the related reader device sub record. | `text(2147483647)` | Yes | No | - | - |
| `action_center` | Center part of the reference to related action data. | `int4` | Yes | No | - | - |
| `action_id` | Identifier of the related action record. | `int4` | Yes | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `VARCHAR(100)` | Yes | No | - | - |

# Relations
- Commonly used with: [booking_resources](booking_resources.md) (5 query files), [centers](centers.md) (5 query files), [usage_points](usage_points.md) (5 query files), [devices](devices.md) (4 query files), [usage_point_action_res_link](usage_point_action_res_link.md) (4 query files), [usage_point_resources](usage_point_resources.md) (4 query files).
- FK-linked tables: outgoing FK to [clients](clients.md), [devices](devices.md), [usage_points](usage_points.md).
- Second-level FK neighborhood includes: [access_code](access_code.md), [client_instances](client_instances.md), [gates](gates.md), [systemproperties](systemproperties.md), [usage_point_resources](usage_point_resources.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.
