# jbm_cluster
Operational table for jbm cluster records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `node_id` | Identifier of the related node record. | `int4` | No | Yes | - | - |
| `ping_timestamp` | Table field used by operational and reporting workloads. | `TIMESTAMP` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `int4` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
