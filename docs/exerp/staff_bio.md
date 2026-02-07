# staff_bio
People-related master or relationship table for staff bio data. It is typically used where change-tracking timestamps are available.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `staff_id` | Identifier of the related staff record. | `int4` | No | No | - | - | `1001` |
| `staff_center` | Center part of the reference to related staff data. | `int4` | No | No | - | - | `101` |
| `creator_id` | Identifier of the related creator record. | `int4` | No | No | - | - | `1001` |
| `creator_center` | Center part of the reference to related creator data. | `int4` | No | No | - | - | `101` |
| `description` | Text field containing descriptive or reference information. | `VARCHAR(200)` | Yes | No | - | - | `Sample value` |
| `selling_points` | Table field used by operational and reporting workloads. | `json` | Yes | No | - | - | `N/A` |
| `created_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Interesting data points: change timestamps support incremental extraction and reconciliation.
