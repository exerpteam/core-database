# postal_area
Operational table for postal area records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `parent_id` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [postal_area](postal_area.md) via (`parent_id` -> `id`) | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(200)` | No | No | - | - |
| `alternative_name` | Business attribute `alternative_name` used by postal area workflows and reporting. | `VARCHAR(200)` | Yes | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `VARCHAR(50)` | No | No | - | - |
| `country_id` | Identifier of the related countries record used by this row. | `VARCHAR(2)` | No | No | [countries](countries.md) via (`country_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [countries](countries.md), [postal_area](postal_area.md); incoming FK from [postal_address](postal_address.md), [postal_area](postal_area.md), [postal_code_area_mapping](postal_code_area_mapping.md).
- Second-level FK neighborhood includes: [centers](centers.md), [payment_agreements](payment_agreements.md), [postal_code](postal_code.md), [zipcodes](zipcodes.md).
