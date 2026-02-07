# custom_attribute_configs
Configuration table for custom attribute configs behavior and defaults. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 4 query files; common companions include [custom_attribute_config_values](custom_attribute_config_values.md), [custom_attributes](custom_attributes.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(100)` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `VARCHAR(60)` | No | No | - | - |
| `rank` | Operational field `rank` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `ref_type` | Classification code describing the ref type category (for example: PERSON). | `VARCHAR(30)` | No | No | - | - |
| `ref_id` | Identifier for the related ref entity used by this record. | `int4` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(15)` | No | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `VARCHAR(30)` | No | No | - | - |

# Relations
- Commonly used with: [custom_attribute_config_values](custom_attribute_config_values.md) (3 query files), [custom_attributes](custom_attributes.md) (3 query files), [persons](persons.md) (3 query files), [centers](centers.md) (2 query files), [employees](employees.md) (2 query files), [person_change_logs](person_change_logs.md) (2 query files).
- FK-linked tables: incoming FK from [custom_attribute_config_values](custom_attribute_config_values.md), [custom_attributes](custom_attributes.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
