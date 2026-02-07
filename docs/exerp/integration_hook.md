# integration_hook
Operational table for integration hook records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `plugin` | Business attribute `plugin` used by integration hook workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |

# Relations
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
