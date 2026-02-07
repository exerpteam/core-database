# temp_chunk_file
Intermediate/cache table used to accelerate temp chunk file processing.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `file_ref_id` | Identifier for the related file ref entity used by this record. | `int4` | No | No | - | - |
| `mime_value` | Binary payload storing structured runtime data for this record. | `bytea` | No | No | - | - |
| `created_time` | Timestamp used for event ordering and operational tracking. | `TIMESTAMP` | No | No | - | - |

# Relations
