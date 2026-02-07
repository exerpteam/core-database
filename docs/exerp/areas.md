# areas
Operational table for areas records in the Exerp schema. It is typically used where it appears in approximately 385 query files; common companions include [centers](centers.md), [area_centers](area_centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `parent` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [areas](areas.md) via (`parent` -> `id`) | - |
| `types` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `copied_from` | Business attribute `copied_from` used by areas workflows and reporting. | `int4` | Yes | No | - | - |
| `root_area` | Identifier referencing another record in the same table hierarchy. | `int4` | No | No | [areas](areas.md) via (`root_area` -> `id`) | - |

# Relations
- Commonly used with: [centers](centers.md) (323 query files), [area_centers](area_centers.md) (294 query files), [persons](persons.md) (209 query files), [products](products.md) (134 query files), [subscriptions](subscriptions.md) (85 query files), [masterproductregister](masterproductregister.md) (69 query files).
- FK-linked tables: outgoing FK to [areas](areas.md); incoming FK from [area_centers](area_centers.md), [areas](areas.md).
- Second-level FK neighborhood includes: [centers](centers.md).
