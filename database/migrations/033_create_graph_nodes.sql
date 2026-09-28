-- =====================================================
-- ETOS 2.0
-- Migration 033
-- Graph Nodes
-- Universeller Wissensgraph
-- =====================================================

BEGIN;

CREATE TABLE IF NOT EXISTS etos.graph_node (

    node_id UUID PRIMARY KEY
    DEFAULT gen_random_uuid(),

    node_type TEXT NOT NULL,

    title TEXT NOT NULL,

    description TEXT,

    external_source TEXT,

    external_id TEXT,

    tensor_node_id UUID
    REFERENCES etos.tensor_node(tensor_node_id)
    ON DELETE SET NULL,

    resource_id UUID
    REFERENCES etos.knowledge_resource(resource_id)
    ON DELETE SET NULL,

    metadata JSONB
    DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ
    DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- Duplikatschutz
-- -----------------------------------------------------

CREATE UNIQUE INDEX IF NOT EXISTS
idx_graph_node_external_unique

ON etos.graph_node(
    external_source,
    external_id
)

WHERE external_source IS NOT NULL
AND external_id IS NOT NULL;

-- -----------------------------------------------------
-- Performance
-- -----------------------------------------------------

CREATE INDEX IF NOT EXISTS
idx_graph_node_type
ON etos.graph_node(node_type);

CREATE INDEX IF NOT EXISTS
idx_graph_node_source
ON etos.graph_node(external_source);

CREATE INDEX IF NOT EXISTS
idx_graph_node_external_id
ON etos.graph_node(external_id);

CREATE INDEX IF NOT EXISTS
idx_graph_node_resource
ON etos.graph_node(resource_id);

-- -----------------------------------------------------
-- Dokumentation
-- -----------------------------------------------------

COMMENT ON TABLE etos.graph_node IS
'Universeller Wissensgraph-Knoten';

COMMIT;
