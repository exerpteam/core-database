# signatures
Operational table for signatures records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 13 query files; common companions include [journalentries](journalentries.md), [journalentry_signatures](journalentry_signatures.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `signature_document` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `signed_document` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `signed_document_mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `signature_image_mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `signature_image_data` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `signature_receipt` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `signature_hash` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `signature_hash_b` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `document_receipt` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `document_hash` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `document_hash_b` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `device_key` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - |
| `s3bucket_signature_image_data` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `s3bucket_signed_document` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `s3key_signature_image_data` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `s3key_signed_document` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [journalentries](journalentries.md) (11 query files), [journalentry_signatures](journalentry_signatures.md) (10 query files), [persons](persons.md) (9 query files), [subscription_sales](subscription_sales.md) (7 query files), [centers](centers.md) (6 query files), [subscriptions](subscriptions.md) (6 query files).
- FK-linked tables: incoming FK from [journalentry_signatures](journalentry_signatures.md).
- Second-level FK neighborhood includes: [journalentries](journalentries.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
