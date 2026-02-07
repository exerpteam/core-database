# countries
Operational table for countries records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 161 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `VARCHAR(2)` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `area` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `defaultlanguage` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `defaulttimezone` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [centers](centers.md) (150 query files), [persons](persons.md) (122 query files), [subscriptions](subscriptions.md) (69 query files), [products](products.md) (64 query files), [bookings](bookings.md) (44 query files), [product_group](product_group.md) (39 query files).
- FK-linked tables: incoming FK from [centers](centers.md), [postal_area](postal_area.md), [postal_code](postal_code.md), [zipcodes](zipcodes.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery](delivery.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
