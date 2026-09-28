-- =====================================================
-- ETOS 2.0
-- Migration 032
-- Tensorraum-Knoten
--
-- Verbindung zwischen:
-- knowledge_resource
-- Tensorraum
-- Wissensgraph
-- =====================================================

BEGIN;

CREATE TABLE IF NOT EXISTS etos.tensor_node (

    tensor_node_id UUID PRIMARY KEY
    DEFAULT gen_random_uuid(),

    resource_id UUID NOT NULL
    REFERENCES etos.knowledge_resource(resource_id)
    ON DELETE CASCADE,

    node_type TEXT NOT NULL,

    label TEXT NOT NULL,

    embedding_model TEXT,

    embedding_dimension INTEGER,

    embedded_at TIMESTAMPTZ,

    metadata JSONB
    DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ
    DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- Duplikatschutz
-- -----------------------------------------------------

CREATE UNIQUE INDEX IF NOT EXISTS
idx_tensor_node_resource_unique

ON etos.tensor_node(resource_id);

-- -----------------------------------------------------
-- Performance
-- -----------------------------------------------------

CREATE INDEX IF NOT EXISTS
idx_tensor_node_type

ON etos.tensor_node(node_type);

CREATE INDEX IF NOT EXISTS
idx_tensor_node_label

ON etos.tensor_node(label);

CREATE INDEX IF NOT EXISTS
idx_tensor_node_embedded

ON etos.tensor_node(embedded_at);

-- -----------------------------------------------------
-- Dokumentation
-- -----------------------------------------------------

COMMENT ON TABLE etos.tensor_node IS
'Tensorraum-Repräsentation einer Wissensressource';

COMMENT ON COLUMN etos.tensor_node.resource_id IS
'Verbindung zur Wissensquelle';

COMMENT ON COLUMN etos.tensor_node.node_type IS
'publication, dataset, concept, project, institute usw.';

COMMENT ON COLUMN etos.tensor_node.embedding_model IS
'Name des verwendeten Embedding-Modells';

COMMENT ON COLUMN etos.tensor_node.embedding_dimension IS
'Dimension des Embedding-Vektors';

COMMENT ON COLUMN etos.tensor_node.metadata IS
'Tensorraum-Metadaten';

COMMIT;
