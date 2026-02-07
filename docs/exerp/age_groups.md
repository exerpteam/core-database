# age_groups
Operational table for age groups records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 2 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `min_age` | Business attribute `min_age` used by age groups workflows and reporting. | `int4` | Yes | No | - | - |
| `max_age` | Business attribute `max_age` used by age groups workflows and reporting. | `int4` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `strict_min_age` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `min_age_time_unit` | Business attribute `min_age_time_unit` used by age groups workflows and reporting. | `VARCHAR(6)` | Yes | No | - | - |
| `max_age_time_unit` | Business attribute `max_age_time_unit` used by age groups workflows and reporting. | `VARCHAR(6)` | Yes | No | - | - |

# Relations
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.
