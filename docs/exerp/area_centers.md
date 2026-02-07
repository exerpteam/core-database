# area_centers
Operational table for area centers records in the Exerp schema. It is typically used where it appears in approximately 300 query files; common companions include [areas](areas.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `area` | Foreign key field linking this record to `areas`. | `int4` | No | Yes | [areas](areas.md) via (`area` -> `id`) | - |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |

# Relations
- Commonly used with: [areas](areas.md) (294 query files), [centers](centers.md) (273 query files), [persons](persons.md) (179 query files), [products](products.md) (125 query files), [subscriptions](subscriptions.md) (82 query files), [participations](participations.md) (66 query files).
- FK-linked tables: outgoing FK to [areas](areas.md), [centers](centers.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [countries](countries.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery](delivery.md).
