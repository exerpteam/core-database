# custom_attributes
Operational table for custom attributes records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 3 query files; common companions include [custom_attribute_config_values](custom_attribute_config_values.md), [custom_attribute_configs](custom_attribute_configs.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `custom_attribute_config_value_id` | Foreign key field linking this record to `custom_attribute_config_values`. | `int4` | Yes | No | [custom_attribute_config_values](custom_attribute_config_values.md) via (`custom_attribute_config_value_id` -> `id`) | - |
| `ref_type` | Text field containing descriptive or reference information. | `VARCHAR(15)` | No | No | - | - |
| `ref_id` | Identifier of the related ref record. | `int4` | No | No | - | - |
| `ref_center_id` | Identifier of the related ref center record. | `int4` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `VARCHAR(15)` | No | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `text_value` | Text field containing descriptive or reference information. | `VARCHAR(4000)` | Yes | No | - | - |
| `custom_attribute_config_id` | Foreign key field linking this record to `custom_attribute_configs`. | `int4` | No | No | [custom_attribute_configs](custom_attribute_configs.md) via (`custom_attribute_config_id` -> `id`) | - |

# Relations
- Commonly used with: [custom_attribute_config_values](custom_attribute_config_values.md) (3 query files), [custom_attribute_configs](custom_attribute_configs.md) (3 query files), [persons](persons.md) (3 query files), [centers](centers.md) (2 query files), [employees](employees.md) (2 query files), [person_change_logs](person_change_logs.md) (2 query files).
- FK-linked tables: outgoing FK to [custom_attribute_config_values](custom_attribute_config_values.md), [custom_attribute_configs](custom_attribute_configs.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
