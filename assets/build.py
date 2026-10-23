import os
from pathlib import Path

class DocumentBuilder:
    def __init__(self, output_dir: str = "vault"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def build_document(self, doc_id: str, title: str, doc_type: str, author: str, summary: str, body: str) -> str:
        """Erzeugt ein Dokument im Storage Vault."""
        filename = f"{doc_id}_{doc_type}.docx"
        file_path = self.output_dir / filename
        
        # Basis-Struktur schreiben (kompatibel mit DOCX-Textformat)
        content = (
            f"DOKUMENT: {title}\n"
            f"TYP: {doc_type}\n"
            f"AUTOR: {author}\n"
            f"SUMMARY: {summary}\n"
            f"{'=' * 40}\n\n"
            f"{body}\n"
        )
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
            
        return str(file_path)
