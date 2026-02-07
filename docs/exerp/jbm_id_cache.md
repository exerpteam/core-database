# jbm_id_cache
Intermediate/cache table used to accelerate jbm id cache processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `node_id` | Identifier of the related node record. | `int4` | No | Yes | - | - | `1001` |
| `cntr` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | Yes | - | - | `42` |
| `jbm_id` | Identifier of the related jbm record. | `VARCHAR(255)` | Yes | No | - | - | `1001` |

# Relations
