# postal_code
Operational table for postal code records in the Exerp schema. It is typically used where it appears in approximately 48 query files; common companions include [persons](persons.md), [zipcodes](zipcodes.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `code` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - | `Sample value` |
| `country_id` | Foreign key field linking this record to `countries`. | `VARCHAR(2)` | No | No | [countries](countries.md) via (`country_id` -> `id`) | - | `SE` |

# Relations
- Commonly used with: [persons](persons.md) (33 query files), [zipcodes](zipcodes.md) (24 query files), [relatives](relatives.md) (21 query files), [centers](centers.md) (21 query files), [person_ext_attrs](person_ext_attrs.md) (16 query files), [converter_entity_state](converter_entity_state.md) (7 query files).
- FK-linked tables: outgoing FK to [countries](countries.md); incoming FK from [postal_address](postal_address.md), [postal_code_area_mapping](postal_code_area_mapping.md).
- Second-level FK neighborhood includes: [centers](centers.md), [payment_agreements](payment_agreements.md), [postal_area](postal_area.md), [zipcodes](zipcodes.md).
