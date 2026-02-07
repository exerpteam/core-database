# areas
Operational table for areas records in the Exerp schema. It is typically used where it appears in approximately 385 query files; common companions include [centers](centers.md), [area_centers](area_centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `parent` | Foreign key field linking this record to `areas`. | `int4` | Yes | No | [areas](areas.md) via (`parent` -> `id`) | - |
| `types` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `copied_from` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `root_area` | Foreign key field linking this record to `areas`. | `int4` | No | No | [areas](areas.md) via (`root_area` -> `id`) | - |

# Relations
- Commonly used with: [centers](centers.md) (323 query files), [area_centers](area_centers.md) (294 query files), [persons](persons.md) (209 query files), [products](products.md) (134 query files), [subscriptions](subscriptions.md) (85 query files), [masterproductregister](masterproductregister.md) (69 query files).
- FK-linked tables: outgoing FK to [areas](areas.md); incoming FK from [area_centers](area_centers.md), [areas](areas.md).
- Second-level FK neighborhood includes: [centers](centers.md).
