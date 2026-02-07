# journalentry_and_role_link
Bridge table that links related entities for journalentry and role link relationships. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `journalentry_id` | Foreign key field linking this record to `journalentries`. | `int4` | No | Yes | [journalentries](journalentries.md) via (`journalentry_id` -> `id`) | - |
| `role_id` | Foreign key field linking this record to `roles`. | `int4` | No | Yes | [roles](roles.md) via (`role_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [journalentries](journalentries.md), [roles](roles.md).
- Second-level FK neighborhood includes: [cashcollectionjournalentries](cashcollectionjournalentries.md), [companyagreements](companyagreements.md), [custom_journal_document_types](custom_journal_document_types.md), [doc_requirement_items](doc_requirement_items.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_signatures](journalentry_signatures.md), [kpi_group_and_role_link](kpi_group_and_role_link.md).
