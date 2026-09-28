-- =====================================================
-- ETOS 2.0
-- Migration 034
-- Graph Relations
--
-- Universelle Beziehungen zwischen Graph-Knoten
--
-- Beispiele:
--
-- Projekt       -> uses            -> Repository
-- Projekt       -> references      -> ORKG Concept
-- Institut      -> contains        -> Forschungsgruppe
-- Publikation   -> cites           -> Publikation
-- Forschungsgrp -> contributes_to  -> Projekt
--
-- =====================================================

BEGIN;

CREATE TABLE IF NOT EXISTS etos.graph_relation (

    relation_id UUID PRIMARY KEY
    DEFAULT gen_random_uuid(),

    source_node UUID NOT NULL
    REFERENCES etos.graph_node(node_id)
    ON DELETE CASCADE,

    target_node UUID NOT NULL
    REFERENCES etos.graph_node(node_id)
    ON DELETE CASCADE,

    relation_type TEXT NOT NULL,

    weight NUMERIC(10,4)
    DEFAULT 1.0000,

    confidence NUMERIC(5,4)
    DEFAULT 1.0000,

    metadata JSONB
    DEFAULT '{}'::jsonb,

    created_at TIMESTAMPTZ
    DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_graph_relation_weight
    CHECK (
        weight >= 0
    ),

    CONSTRAINT chk_graph_relation_confidence
    CHECK (
        confidence >= 0
        AND confidence <= 1
    ),

    CONSTRAINT chk_graph_relation_not_self
    CHECK (
        source_node <> target_node
    )
);

-- -----------------------------------------------------
-- Indizes
-- -----------------------------------------------------

CREATE INDEX IF NOT EXISTS
idx_graph_relation_source
ON etos.graph_relation(source_node);

CREATE INDEX IF NOT EXISTS
idx_graph_relation_target
ON etos.graph_relation(target_node);

CREATE INDEX IF NOT EXISTS
idx_graph_relation_type
ON etos.graph_relation(relation_type);

-- -----------------------------------------------------
-- Dokumentation
-- -----------------------------------------------------

COMMENT ON TABLE etos.graph_relation IS
'Wissensgraph-Beziehungen zwischen ETOS-Knoten';

COMMENT ON COLUMN etos.graph_relation.source_node IS
'Quellknoten der Beziehung';

COMMENT ON COLUMN etos.graph_relation.target_node IS
'Zielknoten der Beziehung';

COMMENT ON COLUMN etos.graph_relation.relation_type IS
'Beziehungstyp wie uses, references, contains, contributes_to, cites';

COMMENT ON COLUMN etos.graph_relation.weight IS
'Gewichtung der Beziehung';

COMMENT ON COLUMN etos.graph_relation.confidence IS
'Vertrauenswert zwischen 0 und 1';

COMMENT ON COLUMN etos.graph_relation.metadata IS
'Zusätzliche strukturierte Metadaten';

COMMIT;
