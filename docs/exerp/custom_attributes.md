# custom_attributes
Operational table for custom attributes records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 3 query files; common companions include [custom_attribute_config_values](custom_attribute_config_values.md), [custom_attribute_configs](custom_attribute_configs.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `custom_attribute_config_value_id` | Identifier of the related custom attribute config values record used by this row. | `int4` | Yes | No | [custom_attribute_config_values](custom_attribute_config_values.md) via (`custom_attribute_config_value_id` -> `id`) | - |
| `ref_type` | Classification code describing the ref type category (for example: PERSON). | `VARCHAR(15)` | No | No | - | - |
| `ref_id` | Identifier for the related ref entity used by this record. | `int4` | No | No | - | - |
| `ref_center_id` | Identifier for the related ref center entity used by this record. | `int4` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(15)` | No | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `text_value` | Business attribute `text_value` used by custom attributes workflows and reporting. | `VARCHAR(4000)` | Yes | No | - | - |
| `custom_attribute_config_id` | Identifier of the related custom attribute configs record used by this row. | `int4` | No | No | [custom_attribute_configs](custom_attribute_configs.md) via (`custom_attribute_config_id` -> `id`) | - |

# Relations
- Commonly used with: [custom_attribute_config_values](custom_attribute_config_values.md) (3 query files), [custom_attribute_configs](custom_attribute_configs.md) (3 query files), [persons](persons.md) (3 query files), [centers](centers.md) (2 query files), [employees](employees.md) (2 query files), [person_change_logs](person_change_logs.md) (2 query files).
- FK-linked tables: outgoing FK to [custom_attribute_config_values](custom_attribute_config_values.md), [custom_attribute_configs](custom_attribute_configs.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
