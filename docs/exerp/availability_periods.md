# availability_periods
Operational table for availability periods records in the Exerp schema. It is typically used where it appears in approximately 3 query files; common companions include [extract](extract.md), [availability_overrides](availability_overrides.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `schedule_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `schedule_value` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `deleted` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `availability_period_id` | Identifier for the related availability period entity used by this record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [extract](extract.md) (3 query files), [availability_overrides](availability_overrides.md) (2 query files), [centers](centers.md) (2 query files).
