# availability_periods
Operational table for availability periods records in the Exerp schema. It is typically used where it appears in approximately 3 query files; common companions include [extract](extract.md), [availability_overrides](availability_overrides.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `schedule_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `schedule_value` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `deleted` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `availability_period_id` | Identifier of the related availability period record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [extract](extract.md) (3 query files), [availability_overrides](availability_overrides.md) (2 query files), [centers](centers.md) (2 query files).
