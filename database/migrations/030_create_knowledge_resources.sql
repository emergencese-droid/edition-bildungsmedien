CREATE TABLE IF NOT EXISTS etos.knowledge_resource (

    resource_id UUID PRIMARY KEY
    DEFAULT gen_random_uuid(),

    source_name VARCHAR(100) NOT NULL,

    source_type VARCHAR(100) NOT NULL,

    title VARCHAR(500) NOT NULL,

    description TEXT,

    url TEXT,

    imported_at TIMESTAMPTZ
    DEFAULT CURRENT_TIMESTAMP,

    project_id UUID
    REFERENCES etos.project(project_id)
    ON DELETE SET NULL,

    publication_id UUID
    REFERENCES etos.publication(publication_id)
    ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS
idx_knowledge_resource_source
ON etos.knowledge_resource(source_name);

CREATE INDEX IF NOT EXISTS
idx_knowledge_resource_type
ON etos.knowledge_resource(source_type);
``
