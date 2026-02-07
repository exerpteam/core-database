# deduction_day_validations
Operational table for deduction day validations records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `payment_cycle_config_id` | Foreign key field linking this record to `payment_cycle_config`. | `int4` | No | No | [payment_cycle_config](payment_cycle_config.md) via (`payment_cycle_config_id` -> `id`) | - | `1001` |
| `plugin_id` | Identifier of the related plugin record. | `text(2147483647)` | No | No | - | - | `1001` |
| `plugin_config` | Table field used by operational and reporting workloads. | `bytea` | No | No | - | - | `Sample` |

# Relations
- FK-linked tables: outgoing FK to [payment_cycle_config](payment_cycle_config.md).
- Second-level FK neighborhood includes: [ch_and_pcc_link](ch_and_pcc_link.md).
