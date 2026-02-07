# availability_overrides
Operational table for availability overrides records in the Exerp schema. It is typically used where it appears in approximately 2 query files; common companions include [availability_periods](availability_periods.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `override_date` | Date for override. | `DATE` | No | No | - | - | `2025-01-31` |
| `start_time` | Epoch timestamp for start. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `stop_time` | Epoch timestamp for stop. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `open_all_day` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `closed_all_day` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `availability_period_id` | Identifier of the related availability period record. | `int4` | No | No | - | [availability_periods](availability_periods.md) via (`availability_period_id` -> `id`) | `1001` |
| `override_scope_id` | Identifier of the related override scope record. | `int4` | No | No | - | - | `1001` |
| `override_scope_type` | Text field containing descriptive or reference information. | `VARCHAR(10)` | Yes | No | - | - | `Sample value` |

# Relations
- Commonly used with: [availability_periods](availability_periods.md) (2 query files), [centers](centers.md) (2 query files), [EXTRACT](EXTRACT.md) (2 query files).
