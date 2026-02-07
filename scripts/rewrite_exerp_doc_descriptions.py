#!/usr/bin/env python3
import argparse
import csv
import re
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parents[1]
DOCS_DIR = ROOT / "docs" / "exerp"
DDL_DIR = ROOT / "db" / "exerp" / "tables"
EXTRACTS_DIR = ROOT / "queries" / "extracts"
REDSHIFT_DIR = ROOT / "queries" / "redshift" / "public"

ROW_RE = re.compile(r"^\|\s*`([^`]+)`\s*\|")


def tokenize(text: str):
    return re.findall(r"[A-Za-z_][A-Za-z0-9_]*", text.lower())


def parse_docs_rows(doc_path: Path):
    text = doc_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    in_structure = False
    rows = []
    for idx, line in enumerate(lines):
        if line.startswith("# Structure"):
            in_structure = True
            continue
        if line.startswith("# Relations"):
            in_structure = False
            continue
        if in_structure and ROW_RE.match(line):
            split_parts = line.split("|")
            if len(split_parts) < 9:
                continue
            # markdown row cells are between the leading/trailing pipes
            cells = [p.strip() for p in split_parts[1:-1]]
            if len(cells) < 7:
                continue
            col = cells[0].strip("`")
            desc = cells[1]
            dtype = cells[2]
            is_pk = cells[4].lower() == "yes"
            physical_fk = cells[5]
            logical_fk = cells[6]
            rows.append({
                "line_idx": idx,
                "column": col,
                "description": desc,
                "dtype": dtype,
                "is_pk": is_pk,
                "physical_fk": physical_fk,
                "logical_fk": logical_fk,
                "cells": cells,
            })
    return lines, rows


def parse_ddl_metadata():
    table_meta = defaultdict(lambda: {
        "pk": [],
        "fks": [],
        "cols": set(),
    })

    for ddl in DDL_DIR.glob("*.sql"):
        table = ddl.stem.lower()
        txt = ddl.read_text(encoding="utf-8", errors="ignore")

        # Column names from CREATE TABLE body
        create_m = re.search(r"CREATE\s+TABLE\s+[^\(]+\((.*)\)\s*;", txt, flags=re.I | re.S)
        if create_m:
            body = create_m.group(1)
            for line in body.splitlines():
                s = line.strip().rstrip(",")
                if not s or s.upper().startswith(("PRIMARY KEY", "CONSTRAINT", "FOREIGN KEY")):
                    continue
                m = re.match(r'"?([A-Za-z_][A-Za-z0-9_]*)"?\s+', s)
                if m:
                    table_meta[table]["cols"].add(m.group(1).lower())

        # PK
        pk_m = re.search(r"PRIMARY\s+KEY\s*\(([^\)]+)\)", txt, flags=re.I | re.S)
        if pk_m:
            pk_cols = [c.strip().strip('"').lower() for c in pk_m.group(1).split(",")]
            table_meta[table]["pk"] = pk_cols

        # FK constraints
        for m in re.finditer(
            r"FOREIGN\s+KEY\s*\(([^\)]+)\)\s+REFERENCES\s+\"?exerp\"?\.\"?([A-Za-z_][A-Za-z0-9_]*)\"?\s*\(([^\)]+)\)",
            txt,
            flags=re.I | re.S,
        ):
            src_cols = [c.strip().strip('"').lower() for c in m.group(1).split(",")]
            tgt_table = m.group(2).lower()
            tgt_cols = [c.strip().strip('"').lower() for c in m.group(3).split(",")]
            table_meta[table]["fks"].append({
                "src_cols": src_cols,
                "tgt_table": tgt_table,
                "tgt_cols": tgt_cols,
                "is_self": tgt_table == table,
            })

    return table_meta


def parse_sql_evidence():
    case_map = defaultdict(set)
    usage_count = defaultdict(int)

    sql_files = list(EXTRACTS_DIR.rglob("*.sql")) + list(REDSHIFT_DIR.glob("*.sql"))
    for fp in sql_files:
        txt = fp.read_text(encoding="utf-8", errors="ignore")
        for tok in set(tokenize(txt)):
            usage_count[tok] += 1

        for cm in re.finditer(r"CASE\s+([A-Za-z0-9_\.\"]+)\s+(.*?)\s+END", txt, flags=re.I | re.S):
            expr = cm.group(1).strip().strip('"')
            body = cm.group(2)
            field = expr.split(".")[-1].strip('"').lower()
            labels = re.findall(r"THEN\s+'([^']+)'", body, flags=re.I)
            for lab in labels[:8]:
                if lab:
                    case_map[field].add(lab)

    return case_map, usage_count


def nice_table_name(name: str):
    return name.replace("_", " ")


def role_from_prefix(prefix: str):
    p = prefix.lower()
    if p in {"owner"}:
        return "owner person"
    if p in {"creator", "orig_creator"}:
        return "creator staff member"
    if p in {"employee", "assigned_staff", "assignee", "asignee"}:
        return "assigned staff member"
    if p in {"sales_employee"}:
        return "sales staff member"
    if p in {"change_employee", "changed_by", "cancel_employee"}:
        return "staff member performing the change"
    if p in {"person"}:
        return "related person"
    if p in {"subscriptiontype"}:
        return "subscription type"
    if p in {"payment_agreement"}:
        return "payment agreement"
    if p in {"extract"}:
        return "extract definition"
    if p in {"group", "extract_group"}:
        return "group"
    if p in {"role"}:
        return "role"
    if p in {"center"}:
        return "center"
    return f"related {p.replace('_', ' ')} record"


def choose_description(table: str, col: str, dtype: str, table_rows_cols: set, table_meta, fk_by_col, case_map, usage_count):
    lc = col.lower()
    dtype_l = dtype.lower()
    pk_cols = table_meta.get(table, {}).get("pk", [])

    # 1) key semantics
    if lc in pk_cols:
        if lc == "center" and "id" in pk_cols:
            return "Primary key component that defines the center scope for this record.", "pk"
        if lc == "id" and "center" in pk_cols:
            return "Primary key component that uniquely identifies the record within its center scope.", "pk"
        if len(pk_cols) > 1:
            return "Primary key component used to uniquely identify this record.", "pk"
        return "Primary key identifier for this record.", "pk"

    # 2) booleans first so names like individual_price and end_date_auto_* do not get misclassified
    if "bool" in dtype_l:
        if "blocked" in lc:
            return "Boolean flag indicating whether the record is blocked from normal use.", "boolean"
        if lc.startswith("is_"):
            return f"Boolean flag indicating whether `{lc[3:]}` applies to this record.", "boolean"
        return "Boolean flag controlling related business behavior for this record.", "boolean"

    # 3) explicit decode evidence for enumerated columns
    enum_like = (
        lc in {"state", "status", "sub_state", "type", "request_type", "target_type", "scope_type"}
        or lc.endswith("_type")
        or lc.endswith("_state")
        or lc.endswith("_status")
    )
    if enum_like and lc in case_map and case_map[lc]:
        labels = sorted(case_map[lc])[:4]
        sample = ", ".join(labels)
        if lc in {"state", "status", "sub_state"}:
            return f"Lifecycle state code used for process filtering and reporting (for example: {sample}).", "case_decode"
        if "type" in lc:
            return f"Classification code describing the {lc.replace('_', ' ')} category (for example: {sample}).", "case_decode"
        return f"Business classification code used in reporting transformations (for example: {sample}).", "case_decode"

    # 4) scope semantics
    if lc == "scope_type":
        return "Scope discriminator that defines whether the record is global/tree-, area-, or center-scoped.", "scope"
    if lc == "scope_id":
        return "Identifier of the scoped entity selected by `scope_type`.", "scope"
    if lc == "top_node_id":
        return "Identifier of the top hierarchy node used to organize scoped records.", "scope"

    # 5) FK and relationship roles
    if lc.endswith("_center"):
        prefix = lc[:-7]
        partner = f"{prefix}_id"
        if partner in table_rows_cols:
            role = role_from_prefix(prefix)
            return f"Center component of the composite reference to the {role}.", "paired_fk"
    if lc.endswith("center") and lc != "center":
        prefix = lc[:-6]
        partner = f"{prefix}id"
        if partner in table_rows_cols:
            role = role_from_prefix(prefix)
            return f"Center component of the composite reference to the {role}.", "paired_fk"
    if lc.endswith("_id"):
        prefix = lc[:-3]
        partner = f"{prefix}_center"
        if partner in table_rows_cols:
            role = role_from_prefix(prefix)
            return f"Identifier component of the composite reference to the {role}.", "paired_fk"
    if lc.endswith("id") and lc != "id":
        prefix = lc[:-2]
        partner = f"{prefix}center"
        if partner in table_rows_cols:
            role = role_from_prefix(prefix)
            return f"Identifier component of the composite reference to the {role}.", "paired_fk"

    if lc in fk_by_col:
        tgt = fk_by_col[lc][0]["tgt_table"]
        if tgt == table:
            return "Identifier referencing another record in the same table hierarchy.", "fk"
        return f"Identifier of the related {nice_table_name(tgt)} record used by this row.", "fk"

    # 6) actor attribution
    if lc.startswith("creator_"):
        return "Reference component identifying the staff member who created the record.", "actor"
    if lc.startswith("owner_"):
        return "Reference component identifying the owning person for the record.", "actor"
    if lc.startswith("employee_"):
        return "Reference component identifying the staff member associated with the record action.", "actor"
    if lc.startswith("assigned_") or lc.startswith("asignee_") or lc.startswith("assignee_"):
        return "Reference component identifying the staff member assigned to handle the record.", "actor"

    # 7) lifecycle/process
    if lc in {"state", "status", "sub_state"}:
        return "Lifecycle state code indicating the current processing stage of the record.", "lifecycle"
    if "state" in lc or "status" in lc:
        return "State indicator used to control lifecycle transitions and filtering.", "lifecycle"
    if "type" in lc or lc.endswith("_kind"):
        return "Type code defining the business category used for workflow and reporting logic.", "lifecycle"

    # 8) temporal
    if lc.endswith("_date") or lc in {"date", "birthdate", "due_date", "start_date", "end_date", "follow_up"}:
        return "Business date used for scheduling, validity, or reporting cutoffs.", "temporal"
    if lc.endswith("_time") or lc in {"time", "last_modified", "creation_time", "entry_time", "trans_time", "last_update_time", "last_edit_time"}:
        if "int" in dtype_l:
            return "Timestamp value (epoch milliseconds) used for event ordering and incremental extraction.", "temporal"
        return "Timestamp used for event ordering and operational tracking.", "temporal"

    # 9) amount/counters/perf
    if any(k in lc for k in ["amount", "price", "fee", "balance", "cost", "vat", "tax", "discount", "commission"]):
        return "Monetary value used in financial calculation, settlement, or reporting.", "finance"
    if any(k in lc for k in ["count", "capacity", "rows", "retry", "attempt", "clips", "timeout", "time_used"]):
        return "Operational counter/limit used for processing control and performance monitoring.", "counter"

    # 10) textual/blob semantic patterns
    if lc in {"name", "rolename", "title", "label"}:
        return "Human-readable value used to identify this record in user interfaces and reports.", "text"
    if lc in {"description", "comment", "sub_comment", "text", "text2"}:
        return "Free-text content providing business context or operator notes for the record.", "text"
    if "external_id" in lc:
        return "External business identifier used for integration and cross-system matching.", "text"
    if "sql_query" in lc:
        return "Serialized SQL definition executed by the extract/report runtime.", "blob"
    if "configuration" in lc:
        return "Serialized configuration payload used by runtime processing steps.", "blob"
    if lc == "report":
        return "Serialized report artifact associated with this record.", "blob"
    if "blob" in lc or "mime" in lc or "bytea" in dtype_l:
        return "Binary payload storing structured runtime data for this record.", "blob"

    # 11) identifier fallback
    if lc == "id":
        return "Identifier for this record.", "fallback"
    if lc.endswith("_id"):
        prefix = lc[:-3].replace("_", " ")
        return f"Identifier for the related {prefix} entity used by this record.", "fallback"

    # 12) usage-sensitive fallback
    if usage_count.get(lc, 0) > 30:
        return f"Operational field `{col}` used in query filtering and reporting transformations.", "usage_fallback"

    return f"Business attribute `{col}` used by {nice_table_name(table)} workflows and reporting.", "fallback"


def rewrite_docs(audit_csv_path: Path):
    table_meta = parse_ddl_metadata()
    case_map, usage_count = parse_sql_evidence()

    docs = sorted(DOCS_DIR.glob("*.md"))
    total_rows = 0
    changed_rows = 0
    changed_files = 0

    with audit_csv_path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(["file", "table", "column", "old_description", "new_description", "evidence_source_type"])

        for doc in docs:
            table = doc.stem.lower()
            lines, rows = parse_docs_rows(doc)
            if not rows:
                continue

            table_cols = {r["column"].lower() for r in rows}
            fk_by_col = defaultdict(list)
            for fk in table_meta.get(table, {}).get("fks", []):
                for c in fk["src_cols"]:
                    fk_by_col[c].append(fk)

            file_changed = False
            for row in rows:
                total_rows += 1
                col = row["column"]
                old_desc = row["description"]
                new_desc, evidence = choose_description(
                    table,
                    col,
                    row["dtype"],
                    table_cols,
                    table_meta,
                    fk_by_col,
                    case_map,
                    usage_count,
                )

                cells = list(row["cells"])
                cells[1] = new_desc
                normalized_line = "| " + " | ".join(cells) + " |"

                if lines[row["line_idx"]] != normalized_line:
                    lines[row["line_idx"]] = normalized_line
                    changed_rows += 1
                    file_changed = True

                writer.writerow([
                    str(doc.relative_to(ROOT)),
                    table,
                    col,
                    old_desc,
                    new_desc,
                    evidence,
                ])

            if file_changed:
                doc.write_text("\n".join(lines) + "\n", encoding="utf-8")
                changed_files += 1

    return {
        "docs": len(docs),
        "total_rows": total_rows,
        "changed_rows": changed_rows,
        "changed_files": changed_files,
    }


def main():
    parser = argparse.ArgumentParser(description="Rewrite Exerp docs field descriptions with semantic purpose text.")
    parser.add_argument("--audit-csv", default="/tmp/exerp_doc_semantics_audit.csv")
    args = parser.parse_args()

    summary = rewrite_docs(Path(args.audit_csv))
    print(
        f"Processed {summary['docs']} docs, {summary['total_rows']} rows; "
        f"updated {summary['changed_rows']} rows in {summary['changed_files']} files."
    )
    print(f"Audit CSV: {args.audit_csv}")


if __name__ == "__main__":
    main()
