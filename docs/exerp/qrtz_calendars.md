# qrtz_calendars
Operational table for qrtz calendars records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `calendar_name` | Text field containing descriptive or reference information. | `VARCHAR(200)` | No | Yes | - | - |
| `calendar` | Table field used by operational and reporting workloads. | `bytea` | No | No | - | - |

# Relations
