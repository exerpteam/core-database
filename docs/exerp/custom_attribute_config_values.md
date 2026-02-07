# custom_attribute_config_values
Configuration table for custom attribute config values behavior and defaults. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 4 query files; common companions include [custom_attribute_configs](custom_attribute_configs.md), [custom_attributes](custom_attributes.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `VARCHAR(100)` | No | No | - | - |
| `VALUE` | Operational field `VALUE` used in query filtering and reporting transformations. | `VARCHAR(4000)` | No | No | - | - |
| `custom_attribute_config_id` | Identifier of the related custom attribute configs record used by this row. | `int4` | No | No | [custom_attribute_configs](custom_attribute_configs.md) via (`custom_attribute_config_id` -> `id`) | - |
| `rank` | Operational field `rank` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(15)` | No | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [custom_attribute_configs](custom_attribute_configs.md) (3 query files), [custom_attributes](custom_attributes.md) (3 query files), [persons](persons.md) (3 query files), [centers](centers.md) (2 query files), [employees](employees.md) (2 query files), [person_change_logs](person_change_logs.md) (2 query files).
- FK-linked tables: outgoing FK to [custom_attribute_configs](custom_attribute_configs.md); incoming FK from [custom_attributes](custom_attributes.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
