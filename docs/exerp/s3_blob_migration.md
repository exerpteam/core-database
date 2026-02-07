# s3_blob_migration
Operational table for s3 blob migration records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `document_migration_key` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - |
| `document_name` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - |

# Relations
