# countries
Operational table for countries records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 161 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `VARCHAR(2)` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `area` | Operational field `area` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `defaultlanguage` | Business attribute `defaultlanguage` used by countries workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `defaulttimezone` | Operational field `defaulttimezone` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (150 query files), [persons](persons.md) (122 query files), [subscriptions](subscriptions.md) (69 query files), [products](products.md) (64 query files), [bookings](bookings.md) (44 query files), [product_group](product_group.md) (39 query files).
- FK-linked tables: incoming FK from [centers](centers.md), [postal_area](postal_area.md), [postal_code](postal_code.md), [zipcodes](zipcodes.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery](delivery.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
