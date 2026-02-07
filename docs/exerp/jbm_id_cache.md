# jbm_id_cache
Intermediate/cache table used to accelerate jbm id cache processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `node_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `cntr` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `jbm_id` | Identifier for the related jbm entity used by this record. | `VARCHAR(255)` | Yes | No | - | - |

# Relations
