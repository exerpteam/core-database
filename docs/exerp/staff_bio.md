# staff_bio
People-related master or relationship table for staff bio data. It is typically used where change-tracking timestamps are available.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `staff_id` | Identifier component of the composite reference to the related staff record. | `int4` | No | No | - | - |
| `staff_center` | Center component of the composite reference to the related staff record. | `int4` | No | No | - | - |
| `creator_id` | Identifier component of the composite reference to the creator staff member. | `int4` | No | No | - | - |
| `creator_center` | Center component of the composite reference to the creator staff member. | `int4` | No | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `VARCHAR(200)` | Yes | No | - | - |
| `selling_points` | Business attribute `selling_points` used by staff bio workflows and reporting. | `json` | Yes | No | - | - |
| `created_at` | Business attribute `created_at` used by staff bio workflows and reporting. | `int8` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Interesting data points: change timestamps support incremental extraction and reconciliation.
