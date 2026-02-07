# substitut_preferences_centers
Operational table for substitut preferences centers records in the Exerp schema. It is typically used where rows are center-scoped.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `foreign_center_id` | Identifier of the related foreign center record. | `int4` | No | No | - | - | `1001` |
| `travel_time` | Epoch timestamp for travel. | `int4` | No | No | - | - | `42` |

# Relations
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
