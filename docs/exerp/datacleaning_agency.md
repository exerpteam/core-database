# datacleaning_agency
Operational table for datacleaning agency records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `plugin_id` | Identifier for the related plugin entity used by this record. | `text(2147483647)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |

# Relations
- FK-linked tables: incoming FK from [data_cleaning_in](data_cleaning_in.md), [data_cleaning_out](data_cleaning_out.md).
- Second-level FK neighborhood includes: [data_cleaning_in_line](data_cleaning_in_line.md), [data_cleaning_out_line](data_cleaning_out_line.md), [exchanged_file](exchanged_file.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
