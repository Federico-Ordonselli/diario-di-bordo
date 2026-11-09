"""Extract the supplied workbook without adding spreadsheet dependencies.

Run from the project root: python3 scripts/import-checklist.py
The original row, columns, links, comments and section headings remain traceable.
"""
import json
import posixpath
import re
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NS = {"s": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
RID = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id"
SHEETS = {
    "Achievements": ("achievements", "Trofei", "Trofei"),
    "Coliseum": ("coliseum", "Monte Olimpo", "Sfide"),
    "Ansems Reports": ("reports", "Rapporti di Ansem", "Diario di Grillo"),
    "Characters": ("characters", "Personaggi e nemici", "Diario di Grillo"),
    "Dalmatians": ("dalmatians", "101 Dalmata", "Diario di Grillo"),
    "Mini Games": ("minigames", "Minigiochi", "Diario di Grillo"),
    "Trinity Marks": ("trinities", "Marchi Trio", "Diario di Grillo"),
    "Treasures": ("treasures", "Tesori", "Raccolta"),
    "Synthesis Recipes": ("synthesis", "Sintesi", "Raccolta"),
    "Gummi Ship Blueprints": ("blueprints", "Progetti Gummi", "Gummiship"),
    "Gummi Missions": ("missions", "Missioni Gummi", "Gummiship"),
    "Keyblades": ("keyblades", "Keyblade", "Equipaggiamento"),
    "Staves": ("staves", "Bastoni di Paperino", "Equipaggiamento"),
    "Shields": ("shields", "Scudi di Pippo", "Equipaggiamento"),
    "Magic & Summons": ("magic", "Magie ed evocazioni", "Equipaggiamento"),
}
WORLD_GROUPS = {"treasures", "missions"}


def extract(path):
    with zipfile.ZipFile(path) as z:
        strings = []
        if "xl/sharedStrings.xml" in z.namelist():
            strings = ["".join(e.itertext()) for e in ET.fromstring(z.read("xl/sharedStrings.xml"))]

        def relationships(part):
            relpath = posixpath.join(posixpath.dirname(part), "_rels", posixpath.basename(part) + ".rels")
            if relpath not in z.namelist():
                return {}
            return {r.attrib["Id"]: r.attrib for r in ET.fromstring(z.read(relpath))}

        def resolve(part, target):
            return target.lstrip("/") if target.startswith("/") else posixpath.normpath(posixpath.join(posixpath.dirname(part), target))

        def value(cell):
            v = cell.find("s:v", NS)
            inline = cell.find("s:is", NS)
            raw = v.text if v is not None else "".join(inline.itertext()) if inline is not None else ""
            if cell.attrib.get("t") == "s":
                return strings[int(raw)]
            if raw and cell.attrib.get("t") not in ("b", "str", "inlineStr"):
                try:
                    number = float(raw)
                    return str(int(number)) if number.is_integer() else raw
                except ValueError:
                    pass
            return raw or ""

        wb = ET.fromstring(z.read("xl/workbook.xml"))
        rels = relationships("xl/workbook.xml")
        categories, guides = [], []
        for sheet in wb.find("s:sheets", NS):
            name = sheet.attrib["name"]
            if name not in SHEETS and name not in ("Synthesis Materials", "More Tips"):
                continue
            part = resolve("xl/workbook.xml", rels[sheet.attrib[RID]]["Target"])
            doc = ET.fromstring(z.read(part))
            srels = relationships(part)
            links = {}
            for h in doc.findall(".//s:hyperlink", NS):
                link = srels.get(h.attrib.get(RID), {}).get("Target", "")
                loc = h.attrib.get("location", "")
                target_name = loc.split("!")[0].strip("'")
                target = SHEETS.get(target_name, (None,))[0]
                entry = {"label": h.attrib.get("display", "Guida"), "url": link if re.match(r"https?://", link) else "", "category": target}
                if target_name == "Synthesis Materials":
                    entry["guide"] = "materials"
                if entry["url"] or entry["category"] or entry.get("guide"):
                    links[h.attrib["ref"].split(":")[0]] = entry
            comments = {}
            for rel in srels.values():
                if rel["Type"].endswith("/comments"):
                    comment_doc = ET.fromstring(z.read(resolve(part, rel["Target"])))
                    for c in comment_doc.findall(".//s:comment", NS):
                        comments[c.attrib["ref"]] = "".join(c.find("s:text", NS).itertext())
            rows = []
            for row in doc.findall(".//s:sheetData/s:row", NS):
                cells = {re.sub(r"\d+", "", c.attrib["r"]): value(c) for c in row}
                rows.append((int(row.attrib["r"]), cells))
            if name in SHEETS:
                cid, label, family = SHEETS[name]
                header = next(c for _, c in rows if c.get("A", "").strip() == "✓")
                columns = [{"key": k, "label": v.strip()} for k, v in header.items() if k != "A" and v.strip()]
                group, items, notes = "", [], []
                for rownum, cells in rows:
                    row_links = [link for ref, link in links.items() if int(re.sub(r"\D", "", ref)) == rownum]
                    if cells.get("A") in ("0", "1", "TRUE", "FALSE") and cells.get("D" if cid == "achievements" else "B"):
                        fields = {col["key"]: cells.get(col["key"], "").strip() for col in columns}
                        title = fields.get("D") if cid == "achievements" else fields.get("B")
                        title = title or fields.get("B")
                        if cid == "trinities":
                            title = f"{group} · {title}"
                        elif cid == "missions":
                            title = f"{group} · Mission {title}"
                        elif cid == "dalmatians":
                            title = f"Puppies {title}"
                        world = fields.get("C", "") if cid in ("dalmatians", "trinities") else group if cid in WORLD_GROUPS else ""
                        row_comments = [text for ref, text in comments.items() if int(re.sub(r"\D", "", ref)) == rownum]
                        items.append({"id": f"{cid}-r{rownum}", "title": title, "group": group, "world": world, "row": rownum, "fields": fields, "links": row_links, "comments": row_comments, "initialDone": cells["A"] in ("1", "TRUE")})
                    elif cells.get("B") and not cells.get("A") and len([v for v in cells.values() if v.strip()]) == 1 and rownum > 3:
                        group = cells["B"].strip()
                    elif rownum > 2 and cells.get("A") and cells.get("A") != "✓":
                        text = "\n\n".join(v.strip() for v in cells.values() if v.strip())
                        notes.append({"text": text, "links": row_links, "row": rownum})
                expected = next((int(m.group(1)) for _, c in rows for v in c.values() if (m := re.search(r"\d+/(\d+)\s+(?:completed|obtained|unlocked)", v))), None)
                if len(items) != expected:
                    raise ValueError(f"{name}: expected {expected}, extracted {len(items)}")
                categories.append({"id": cid, "label": label, "family": family, "sheet": name, "columns": columns, "items": items, "notes": notes})
            else:
                sections = []
                for rownum, cells in rows:
                    if rownum < (3 if name == "Synthesis Materials" else 2):
                        continue
                    text = "\n\n".join(v.strip() for v in cells.values() if v.strip())
                    if text:
                        sections.append({"row": rownum, "fields": cells, "text": text, "links": [link for ref, link in links.items() if int(re.sub(r"\D", "", ref)) == rownum]})
                guides.append({"id": "materials" if name == "Synthesis Materials" else "tips", "label": "Materiali di sintesi" if name == "Synthesis Materials" else "Consigli e boss segreti", "sheet": name, "sections": sections})
        return {"version": "kh1fm-checklist-1.03", "source": path.name.removeprefix("Copia di "), "categories": categories, "guides": guides}


if __name__ == "__main__":
    # L’Excel originale contiene artwork ufficiale: sta in private/ (fuori da git).
    workbooks = list((ROOT / "private/radice").glob("*.xlsx"))
    if len(workbooks) != 1:
        raise SystemExit("Expected exactly one .xlsx in private/radice")
    data = extract(workbooks[0])
    (ROOT / "legacy/web/src/completion-data.json").write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
    synthesis = json.loads((ROOT / "assets/datasets/synthesis.json").read_text())
    def normalized(name):
        return re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")
    recipe_ids = {normalized(r["name"]): r["id"] for r in synthesis["recipes"]}
    items = []
    for category in data["categories"]:
        for item in category["items"]:
            enriched = dict(item, categoryId=category["id"], categoryLabel=category["label"])
            if category["id"] == "synthesis":
                enriched["recipeId"] = recipe_ids[normalized(item["title"])]
            items.append(enriched)
    (ROOT / "assets/datasets/completion.json").write_text(json.dumps(dict(data, items=items), ensure_ascii=False, indent=2) + "\n")
    for category in data["categories"]:
        print(f'{category["label"]}: {len(category["items"])}')
    print("Total:", sum(len(c["items"]) for c in data["categories"]))
