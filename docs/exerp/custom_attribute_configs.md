# custom_attribute_configs
Configuration table for custom attribute configs behavior and defaults. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 4 query files; common companions include [custom_attribute_config_values](custom_attribute_config_values.md), [custom_attributes](custom_attributes.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(100)` | No | No | - | - | `Example Name` |
| `external_id` | External/business identifier used in integrations and exports. | `VARCHAR(60)` | No | No | - | - | `EXT-1001` |
| `rank` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `ref_type` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - | `Sample value` |
| `ref_id` | Identifier of the related ref record. | `int4` | No | No | - | - | `1001` |
| `STATE` | State code representing the current processing state. | `VARCHAR(15)` | No | No | - | - | `1` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `type` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - | `1` |

# Relations
- Commonly used with: [custom_attribute_config_values](custom_attribute_config_values.md) (3 query files), [custom_attributes](custom_attributes.md) (3 query files), [persons](persons.md) (3 query files), [centers](centers.md) (2 query files), [employees](employees.md) (2 query files), [person_change_logs](person_change_logs.md) (2 query files).
- FK-linked tables: incoming FK from [custom_attribute_config_values](custom_attribute_config_values.md), [custom_attributes](custom_attributes.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.
