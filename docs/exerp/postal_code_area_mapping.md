# postal_code_area_mapping
Bridge table that links related entities for postal code area mapping relationships.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `postal_code_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [postal_code](postal_code.md) via (`postal_code_id` -> `id`) | - |
| `postal_area_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [postal_area](postal_area.md) via (`postal_area_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [postal_area](postal_area.md), [postal_code](postal_code.md).
- Second-level FK neighborhood includes: [countries](countries.md), [postal_address](postal_address.md).
