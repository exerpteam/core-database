# availability_overrides
Operational table for availability overrides records in the Exerp schema. It is typically used where it appears in approximately 2 query files; common companions include [availability_periods](availability_periods.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `override_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `start_time` | Timestamp used for event ordering and operational tracking. | `text(2147483647)` | Yes | No | - | - |
| `stop_time` | Timestamp used for event ordering and operational tracking. | `text(2147483647)` | Yes | No | - | - |
| `open_all_day` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `closed_all_day` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `availability_period_id` | Identifier for the related availability period entity used by this record. | `int4` | No | No | - | [availability_periods](availability_periods.md) via (`availability_period_id` -> `id`) |
| `override_scope_id` | Identifier for the related override scope entity used by this record. | `int4` | No | No | - | - |
| `override_scope_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(10)` | Yes | No | - | - |

# Relations
- Commonly used with: [availability_periods](availability_periods.md) (2 query files), [centers](centers.md) (2 query files), [extract](extract.md) (2 query files).
