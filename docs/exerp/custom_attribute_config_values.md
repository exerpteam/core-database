# custom_attribute_config_values
Configuration table for custom attribute config values behavior and defaults. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 4 query files; common companions include [custom_attribute_configs](custom_attribute_configs.md), [custom_attributes](custom_attributes.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `external_id` | External/business identifier used in integrations and exports. | `VARCHAR(100)` | No | No | - | - | `EXT-1001` |
| `VALUE` | Text field containing descriptive or reference information. | `VARCHAR(4000)` | No | No | - | - | `Sample value` |
| `custom_attribute_config_id` | Foreign key field linking this record to `custom_attribute_configs`. | `int4` | No | No | [custom_attribute_configs](custom_attribute_configs.md) via (`custom_attribute_config_id` -> `id`) | - | `1001` |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `STATE` | State code representing the current processing state. | `VARCHAR(15)` | No | No | - | - | `1` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [custom_attribute_configs](custom_attribute_configs.md) (3 query files), [custom_attributes](custom_attributes.md) (3 query files), [persons](persons.md) (3 query files), [centers](centers.md) (2 query files), [employees](employees.md) (2 query files), [person_change_logs](person_change_logs.md) (2 query files).
- FK-linked tables: outgoing FK to [custom_attribute_configs](custom_attribute_configs.md); incoming FK from [custom_attributes](custom_attributes.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
