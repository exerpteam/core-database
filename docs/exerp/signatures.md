# signatures
Operational table for signatures records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 13 query files; common companions include [journalentries](journalentries.md), [journalentry_signatures](journalentry_signatures.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `signature_document` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `signed_document` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `signed_document_mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `signature_image_mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `signature_image_data` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `signature_receipt` | Business attribute `signature_receipt` used by signatures workflows and reporting. | `int4` | No | No | - | - |
| `signature_hash` | Business attribute `signature_hash` used by signatures workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `signature_hash_b` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `document_receipt` | Business attribute `document_receipt` used by signatures workflows and reporting. | `int4` | No | No | - | - |
| `document_hash` | Business attribute `document_hash` used by signatures workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `document_hash_b` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `device_key` | Business attribute `device_key` used by signatures workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `s3bucket_signature_image_data` | Business attribute `s3bucket_signature_image_data` used by signatures workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3bucket_signed_document` | Business attribute `s3bucket_signed_document` used by signatures workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3key_signature_image_data` | Business attribute `s3key_signature_image_data` used by signatures workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3key_signed_document` | Business attribute `s3key_signed_document` used by signatures workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [journalentries](journalentries.md) (11 query files), [journalentry_signatures](journalentry_signatures.md) (10 query files), [persons](persons.md) (9 query files), [subscription_sales](subscription_sales.md) (7 query files), [centers](centers.md) (6 query files), [subscriptions](subscriptions.md) (6 query files).
- FK-linked tables: incoming FK from [journalentry_signatures](journalentry_signatures.md).
- Second-level FK neighborhood includes: [journalentries](journalentries.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.
