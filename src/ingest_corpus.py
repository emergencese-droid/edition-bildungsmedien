#!/usr/bin/env python3
# encoding: utf-8
"""
ingest_corpus.py
Deterministisches Ingestion-Skript: liest manifest.json, lädt Kapitel-Inhalte und baut Datensätze für einen späteren Import (z.B. Supabase/Postgres).
"""
import os
import json
from dataclasses import dataclass

@dataclass
class CorpusDocument:
    doc_id: str
    corpus_id: str
    title: str
    content: str
    phase_angle: float
    frequency_hz: float
    torsion_factor: float
    binary_code: str
    target_stage: str


def load_manifest(manifest_path="manifest.json"):
    if not os.path.exists(manifest_path):
        raise FileNotFoundError(f"Manifest nicht gefunden unter: {manifest_path}")
    
    with open(manifest_path, "r", encoding="utf-8") as f:
        return json.load(f)


def build_corpus_records():
    manifest = load_manifest()
    documents = []

    print(f"=== Lade Manifest: {manifest.get('project', '<unknown>')} (v{manifest.get('version', 'n/a')}) ===")

    for corpus in manifest.get("corpora", []):
        corpus_id = corpus["id"]
        corpus_title = corpus.get("title", "")

        for ch in corpus.get("chapters", []):
            file_path = ch["file_path"]
            
            # Falls Datei lokal existiert, Inhalt lesen; sonst Dummy-Inhalt
            if os.path.exists(file_path):
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()
            else:
                content = f"Platzhalter-Inhalt für {ch['title']}"

            doc = CorpusDocument(
                doc_id=ch["chapter_id"],
                corpus_id=corpus_id,
                title=ch.get("title", ""),
                content=content,
                phase_angle=ch.get("phase_angle", 0.0),
                frequency_hz=ch.get("frequency_hz", 0.0),
                torsion_factor=ch.get("torsion_factor", 0.0),
                binary_code=ch.get("binary_code", ""),
                target_stage=ch.get("target_stage", "")
            )
            documents.append(doc)
            print(f"[{corpus_id}] Geladen: {doc.doc_id} -> {doc.title} (Winkel: {doc.phase_angle}°)")

    return documents


if __name__ == "__main__":
    docs = build_corpus_records()
    print(f"\nErfolgreich {len(docs)} Kapitel für die Supabase-Ingestion vorbereitet.")
