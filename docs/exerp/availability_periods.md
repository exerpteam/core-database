# availability_periods
Operational table for availability periods records in the Exerp schema. It is typically used where it appears in approximately 3 query files; common companions include [EXTRACT](EXTRACT.md), [availability_overrides](availability_overrides.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `schedule_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `schedule_value` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `deleted` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `availability_period_id` | Identifier of the related availability period record. | `int4` | Yes | No | - | - | `1001` |

# Relations
- Commonly used with: [EXTRACT](EXTRACT.md) (3 query files), [availability_overrides](availability_overrides.md) (2 query files), [centers](centers.md) (2 query files).
