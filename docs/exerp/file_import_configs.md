# file_import_configs
Configuration table for file import configs behavior and defaults. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(50)` | No | No | - | - |
| `service` | Operational field `service` used in query filtering and reporting transformations. | `VARCHAR(50)` | No | No | - | - |
| `agency` | Business attribute `agency` used by file import configs workflows and reporting. | `int4` | No | No | - | - |
| `target_id` | Identifier of the related sftp targets record used by this row. | `int4` | No | No | [sftp_targets](sftp_targets.md) via (`target_id` -> `id`) | - |
| `source` | Operational field `source` used in query filtering and reporting transformations. | `VARCHAR(100)` | Yes | No | - | - |
| `filename_pattern` | Business attribute `filename_pattern` used by file import configs workflows and reporting. | `VARCHAR(100)` | Yes | No | - | - |
| `description` | Free-text content providing business context or operator notes for the record. | `VARCHAR(2000)` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `VARCHAR(20)` | No | No | - | - |
| `quick_file_process` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [sftp_targets](sftp_targets.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
