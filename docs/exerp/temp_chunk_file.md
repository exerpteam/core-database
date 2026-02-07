# temp_chunk_file
Intermediate/cache table used to accelerate temp chunk file processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `file_ref_id` | Identifier of the related file ref record. | `int4` | No | No | - | - | `1001` |
| `mime_value` | Table field used by operational and reporting workloads. | `bytea` | No | No | - | - | `Sample` |
| `created_time` | Epoch timestamp when the row was created. | `TIMESTAMP` | No | No | - | - | `Sample` |

# Relations
