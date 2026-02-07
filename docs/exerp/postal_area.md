# postal_area
Operational table for postal area records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `parent_id` | Foreign key field linking this record to `postal_area`. | `int4` | Yes | No | [postal_area](postal_area.md) via (`parent_id` -> `id`) | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(200)` | No | No | - | - | `Example Name` |
| `alternative_name` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - | `Example Name` |
| `type` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - | `1` |
| `country_id` | Foreign key field linking this record to `countries`. | `VARCHAR(2)` | No | No | [countries](countries.md) via (`country_id` -> `id`) | - | `SE` |

# Relations
- FK-linked tables: outgoing FK to [countries](countries.md), [postal_area](postal_area.md); incoming FK from [postal_address](postal_address.md), [postal_area](postal_area.md), [postal_code_area_mapping](postal_code_area_mapping.md).
- Second-level FK neighborhood includes: [centers](centers.md), [payment_agreements](payment_agreements.md), [postal_code](postal_code.md), [zipcodes](zipcodes.md).
