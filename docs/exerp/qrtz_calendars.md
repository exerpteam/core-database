# qrtz_calendars
Operational table for qrtz calendars records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `calendar_name` | Primary key identifier for this record. | `VARCHAR(200)` | No | Yes | - | - |
| `calendar` | Binary payload storing structured runtime data for this record. | `bytea` | No | No | - | - |

# Relations
