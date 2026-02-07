# sms_splits
Operational table for sms splits records in the Exerp schema. It is typically used where it appears in approximately 7 query files; common companions include [messages](messages.md), [sms](sms.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `sms_center` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [sms](sms.md) via (`sms_center`, `sms_id` -> `center`, `id`) | - |
| `sms_id` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | [sms](sms.md) via (`sms_center`, `sms_id` -> `center`, `id`) | - |
| `ref_no` | Primary key component used to uniquely identify this record. | `VARCHAR(30)` | No | Yes | - | - |
| `ok` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [messages](messages.md) (7 query files), [sms](sms.md) (7 query files), [centers](centers.md) (5 query files).
- FK-linked tables: outgoing FK to [sms](sms.md).
- Second-level FK neighborhood includes: [messages](messages.md).
