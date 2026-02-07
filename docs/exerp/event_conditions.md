# event_conditions
Operational table for event conditions records in the Exerp schema. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `POSITION` | Operational field `POSITION` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `event_configuration_id` | Serialized configuration payload used by runtime processing steps. | `int4` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |

# Relations
