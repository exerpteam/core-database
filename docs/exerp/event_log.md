# event_log
Stores historical/log records for event events and changes. It is typically used where it appears in approximately 7 query files; common companions include [persons](persons.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `event_configuration_id` | Serialized configuration payload used by runtime processing steps. | `int4` | No | No | - | - |
| `time_stamp` | Business attribute `time_stamp` used by event log workflows and reporting. | `int8` | No | No | - | - |
| `reference_center` | Center component of the composite reference to the related reference record. | `int4` | Yes | No | - | - |
| `reference_id` | Identifier component of the composite reference to the related reference record. | `int4` | Yes | No | - | - |
| `reference_sub_id` | Identifier for the related reference sub entity used by this record. | `int4` | Yes | No | - | - |
| `reference_table` | Business attribute `reference_table` used by event log workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (5 query files), [subscriptions](subscriptions.md) (3 query files), [event_type_config](event_type_config.md) (3 query files), [account_receivables](account_receivables.md) (3 query files), [ar_trans](ar_trans.md) (3 query files), [products](products.md) (3 query files).
