# entityidentifiers
Operational table for entityidentifiers records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 312 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `idmethod` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `IDENTITY` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `cached` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `ref_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `ref_center` | Center part of the reference to related ref data. | `int4` | Yes | No | - | - | `101` |
| `ref_id` | Identifier of the related ref record. | `int4` | Yes | No | - | - | `1001` |
| `ref_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `entitystatus` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - | `1001` |
| `start_time` | Epoch timestamp for start. | `int8` | No | No | - | - | `1738281600000` |
| `stop_time` | Epoch timestamp for stop. | `int8` | Yes | No | - | - | `1738281600000` |
| `invoiceline_center` | Center part of the reference to related invoiceline data. | `int4` | Yes | No | - | - | `101` |
| `invoiceline_id` | Identifier of the related invoiceline record. | `int4` | Yes | No | - | - | `1001` |
| `invoiceline_subid` | Sub-identifier for related invoiceline detail rows. | `int4` | Yes | No | - | - | `1` |
| `assign_employee_center` | Center part of the reference to related assign employee data. | `int4` | Yes | No | - | - | `101` |
| `assign_employee_id` | Identifier of the related assign employee record. | `int4` | Yes | No | - | - | `1001` |
| `block_employee_center` | Center part of the reference to related block employee data. | `int4` | Yes | No | - | - | `101` |
| `block_employee_id` | Identifier of the related block employee record. | `int4` | Yes | No | - | - | `1001` |
| `sub_idmethod` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `source_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [persons](persons.md) (256 query files), [centers](centers.md) (210 query files), [person_ext_attrs](person_ext_attrs.md) (180 query files), [subscriptions](subscriptions.md) (159 query files), [products](products.md) (141 query files), [subscriptiontypes](subscriptiontypes.md) (106 query files).
- Interesting data points: change timestamps support incremental extraction and reconciliation.
