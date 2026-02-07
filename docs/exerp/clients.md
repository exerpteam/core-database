# clients
Operational table for clients records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 44 query files; common companions include [centers](centers.md), [client_instances](client_instances.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `clientid` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `description` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `center` | Center identifier associated with the record. | `int4` | Yes | No | - | [centers](centers.md) via (`center` -> `id`) |
| `expiration_date` | Date for expiration. | `DATE` | Yes | No | - | - |
| `last_contact` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `alert_sent_for_last_contact_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `is_registered` | Boolean flag indicating whether registered applies. | `bool` | No | No | - | - |
| `available_as_template` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (28 query files), [client_instances](client_instances.md) (22 query files), [devices](devices.md) (18 query files), [usage_points](usage_points.md) (8 query files), [systemproperties](systemproperties.md) (6 query files), [booking_resources](booking_resources.md) (6 query files).
- FK-linked tables: incoming FK from [client_instances](client_instances.md), [devices](devices.md), [systemproperties](systemproperties.md), [usage_point_sources](usage_point_sources.md).
- Second-level FK neighborhood includes: [error_reports](error_reports.md), [gates](gates.md), [log_in_log](log_in_log.md), [usage_points](usage_points.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
