# ch_and_pcc_link
Bridge table that links related entities for ch and pcc link relationships. It is typically used where it appears in approximately 18 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `clearing_house_id` | Foreign key field linking this record to `clearinghouses`. | `int4` | No | Yes | [clearinghouses](clearinghouses.md) via (`clearing_house_id` -> `id`) | - | `1001` |
| `payment_cycle_id` | Foreign key field linking this record to `payment_cycle_config`. | `int4` | No | Yes | [payment_cycle_config](payment_cycle_config.md) via (`payment_cycle_id` -> `id`) | - | `1001` |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (18 query files), [persons](persons.md) (18 query files), [payment_accounts](payment_accounts.md) (17 query files), [payment_cycle_config](payment_cycle_config.md) (17 query files), [areas](areas.md) (16 query files), [clearinghouses](clearinghouses.md) (16 query files).
- FK-linked tables: outgoing FK to [clearinghouses](clearinghouses.md), [payment_cycle_config](payment_cycle_config.md).
- Second-level FK neighborhood includes: [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md), [deduction_day_validations](deduction_day_validations.md).
