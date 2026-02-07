# s3_blob_migration
Operational table for s3 blob migration records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `document_migration_key` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - | `Sample value` |
| `document_name` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - | `Example Name` |

# Relations
