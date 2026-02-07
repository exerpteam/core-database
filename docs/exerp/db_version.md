# db_version
Operational table for db version records in the Exerp schema. It is typically used where it appears in approximately 3 query files; common companions include [account_trans](account_trans.md), [account_vat_type_group](account_vat_type_group.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `major` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `minor` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `revision` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `customer` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |

# Relations
- Commonly used with: [account_trans](account_trans.md) (3 query files), [account_vat_type_group](account_vat_type_group.md) (3 query files), [account_vat_type_link](account_vat_type_link.md) (3 query files), [accounts](accounts.md) (3 query files), [cashregisters](cashregisters.md) (3 query files), [center_ext_attrs](center_ext_attrs.md) (3 query files).
- FK-linked tables: incoming FK from [db_updates](db_updates.md).
