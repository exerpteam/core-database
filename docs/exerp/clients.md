# clients
Operational table for clients records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 44 query files; common companions include [centers](centers.md), [client_instances](client_instances.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `clientid` | Business attribute `clientid` used by clients workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `center` | Operational field `center` used in query filtering and reporting transformations. | `int4` | Yes | No | - | [centers](centers.md) via (`center` -> `id`) |
| `expiration_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `last_contact` | Business attribute `last_contact` used by clients workflows and reporting. | `int8` | Yes | No | - | - |
| `alert_sent_for_last_contact_at` | Business attribute `alert_sent_for_last_contact_at` used by clients workflows and reporting. | `int8` | Yes | No | - | - |
| `is_registered` | Boolean flag indicating whether `registered` applies to this record. | `bool` | No | No | - | - |
| `available_as_template` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (28 query files), [client_instances](client_instances.md) (22 query files), [devices](devices.md) (18 query files), [usage_points](usage_points.md) (8 query files), [systemproperties](systemproperties.md) (6 query files), [booking_resources](booking_resources.md) (6 query files).
- FK-linked tables: incoming FK from [client_instances](client_instances.md), [devices](devices.md), [systemproperties](systemproperties.md), [usage_point_sources](usage_point_sources.md).
- Second-level FK neighborhood includes: [error_reports](error_reports.md), [gates](gates.md), [log_in_log](log_in_log.md), [usage_points](usage_points.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
