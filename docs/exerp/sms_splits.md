# sms_splits
Operational table for sms splits records in the Exerp schema. It is typically used where it appears in approximately 7 query files; common companions include [messages](messages.md), [sms](sms.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `sms_center` | Foreign key field linking this record to `sms`. | `int4` | No | Yes | [sms](sms.md) via (`sms_center`, `sms_id` -> `center`, `id`) | - | `101` |
| `sms_id` | Foreign key field linking this record to `sms`. | `int4` | No | Yes | [sms](sms.md) via (`sms_center`, `sms_id` -> `center`, `id`) | - | `1001` |
| `ref_no` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | Yes | - | - | `Sample value` |
| `ok` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [messages](messages.md) (7 query files), [sms](sms.md) (7 query files), [centers](centers.md) (5 query files).
- FK-linked tables: outgoing FK to [sms](sms.md).
- Second-level FK neighborhood includes: [messages](messages.md).
