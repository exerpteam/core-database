# event_log
Stores historical/log records for event events and changes. It is typically used where it appears in approximately 7 query files; common companions include [persons](persons.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `event_configuration_id` | Identifier of the related event configuration record. | `int4` | No | No | - | - |
| `time_stamp` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `reference_center` | Center part of the reference to related reference data. | `int4` | Yes | No | - | - |
| `reference_id` | Identifier of the related reference record. | `int4` | Yes | No | - | - |
| `reference_sub_id` | Identifier of the related reference sub record. | `int4` | Yes | No | - | - |
| `reference_table` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (5 query files), [subscriptions](subscriptions.md) (3 query files), [event_type_config](event_type_config.md) (3 query files), [account_receivables](account_receivables.md) (3 query files), [ar_trans](ar_trans.md) (3 query files), [products](products.md) (3 query files).
