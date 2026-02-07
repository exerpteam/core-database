# push_device_tokens
Operational table for push device tokens records in the Exerp schema. It is typically used where it appears in approximately 12 query files; common companions include [account_receivables](account_receivables.md), [payment_requests](payment_requests.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | - | - |
| `platform` | Business attribute `platform` used by push device tokens workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `environment` | Business attribute `environment` used by push device tokens workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `device_token` | Business attribute `device_token` used by push device tokens workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `register_date_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (12 query files), [payment_requests](payment_requests.md) (12 query files), [persons](persons.md) (12 query files), [relatives](relatives.md) (12 query files), [subscription_addon](subscription_addon.md) (12 query files), [subscription_freeze_period](subscription_freeze_period.md) (12 query files).
