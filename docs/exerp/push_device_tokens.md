# push_device_tokens
Operational table for push device tokens records in the Exerp schema. It is typically used where it appears in approximately 12 query files; common companions include [account_receivables](account_receivables.md), [payment_requests](payment_requests.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `person_center` | Center part of the reference to related person data. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier of the related person record. | `int4` | Yes | No | - | - |
| `platform` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `environment` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `device_token` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `register_date_time` | Epoch timestamp for register date. | `int8` | No | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (12 query files), [payment_requests](payment_requests.md) (12 query files), [persons](persons.md) (12 query files), [relatives](relatives.md) (12 query files), [subscription_addon](subscription_addon.md) (12 query files), [subscription_freeze_period](subscription_freeze_period.md) (12 query files).
