# systemproperties
Configuration table for systemproperties behavior and defaults. It is typically used where it appears in approximately 91 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `globalid` | Operational field `globalid` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `client` | Identifier of the related clients record used by this row. | `int4` | Yes | No | [clients](clients.md) via (`client` -> `id`) | - |
| `txtvalue` | Operational field `txtvalue` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `link_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `link_id` | Identifier for the related link entity used by this record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (78 query files), [persons](persons.md) (59 query files), [area_centers](area_centers.md) (46 query files), [areas](areas.md) (46 query files), [checkins](checkins.md) (39 query files), [participations](participations.md) (32 query files).
- FK-linked tables: outgoing FK to [clients](clients.md).
- Second-level FK neighborhood includes: [client_instances](client_instances.md), [devices](devices.md), [usage_point_sources](usage_point_sources.md).
