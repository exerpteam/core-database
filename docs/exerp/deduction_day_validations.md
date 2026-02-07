# deduction_day_validations
Operational table for deduction day validations records in the Exerp schema.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `payment_cycle_config_id` | Identifier of the related payment cycle config record used by this row. | `int4` | No | No | [payment_cycle_config](payment_cycle_config.md) via (`payment_cycle_config_id` -> `id`) | - |
| `plugin_id` | Identifier for the related plugin entity used by this record. | `text(2147483647)` | No | No | - | - |
| `plugin_config` | Binary payload storing structured runtime data for this record. | `bytea` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [payment_cycle_config](payment_cycle_config.md).
- Second-level FK neighborhood includes: [ch_and_pcc_link](ch_and_pcc_link.md).
