# sftp_targets
Operational table for sftp targets records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(50)` | No | No | - | - |
| `host` | Business attribute `host` used by sftp targets workflows and reporting. | `VARCHAR(100)` | No | No | - | - |
| `port` | Business attribute `port` used by sftp targets workflows and reporting. | `int4` | No | No | - | - |
| `username` | Business attribute `username` used by sftp targets workflows and reporting. | `VARCHAR(50)` | No | No | - | - |
| `password` | Business attribute `password` used by sftp targets workflows and reporting. | `VARCHAR(50)` | No | No | - | - |
| `private_key` | Monetary value used in financial calculation, settlement, or reporting. | `VARCHAR(4000)` | Yes | No | - | - |
| `public_key` | Business attribute `public_key` used by sftp targets workflows and reporting. | `VARCHAR(4000)` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `VARCHAR(20)` | No | No | - | - |

# Relations
- FK-linked tables: incoming FK from [file_import_configs](file_import_configs.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.
