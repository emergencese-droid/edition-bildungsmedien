from supabase import create_client
from models import KnowledgeResource
import os


SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

supabase = create_client(
    SUPABASE_URL,
    SUPABASE_KEY
)


def save_tib_resource(resource: KnowledgeResource):

    payload = {
        "source_name": "TIB",
        "source_type": resource.source_type,
        "title": resource.title,
        "description": resource.description,
        "url": resource.url
    }

    return (
        supabase.table("knowledge_resource")
        .insert(payload)
        .execute()
    )


if __name__ == "__main__":

    resource = KnowledgeResource(
        source_type="Video",
        title="Wissenschaftliches Arbeiten Teil 1",
        description="TIB Tutorial",
        url="https://av.tib.eu/media/60763"
    )

    print(save_tib_resource(resource))
