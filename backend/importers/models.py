from dataclasses import dataclass
from datetime import datetime


@dataclass
class KnowledgeResource:
    source_name: str
    source_type: str
    title: str
    description: str | None = None
    url: str | None = None
    imported_at: datetime | None = None
