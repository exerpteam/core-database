# kpi_data
Operational table for kpi data records in the Exerp schema. It is typically used where it appears in approximately 72 query files; common companions include [kpi_fields](kpi_fields.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `field` | Foreign key field linking this record to `kpi_fields`. | `int4` | No | Yes | [kpi_fields](kpi_fields.md) via (`field` -> `id`) | - |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `for_date` | Date for for. | `DATE` | No | Yes | - | - |
| `VALUE` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `TIMESTAMP` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `kind` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [kpi_fields](kpi_fields.md) (65 query files), [centers](centers.md) (63 query files), [area_centers](area_centers.md) (34 query files), [areas](areas.md) (34 query files), [bookings](bookings.md) (23 query files), [countries](countries.md) (19 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [kpi_fields](kpi_fields.md).
- Second-level FK neighborhood includes: [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [countries](countries.md), [credit_note_lines_mt](credit_note_lines_mt.md).
