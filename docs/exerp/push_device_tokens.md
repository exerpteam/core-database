# push_device_tokens
Operational table for push device tokens records in the Exerp schema. It is typically used where it appears in approximately 12 query files; common companions include [account_receivables](account_receivables.md), [payment_requests](payment_requests.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `person_center` | Center part of the reference to related person data. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | `101` |
| `person_id` | Identifier of the related person record. | `int4` | Yes | No | - | - | `1001` |
| `platform` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `environment` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `device_token` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `register_date_time` | Epoch timestamp for register date. | `int8` | No | No | - | - | `1738281600000` |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (12 query files), [payment_requests](payment_requests.md) (12 query files), [persons](persons.md) (12 query files), [relatives](relatives.md) (12 query files), [subscription_addon](subscription_addon.md) (12 query files), [subscription_freeze_period](subscription_freeze_period.md) (12 query files).
