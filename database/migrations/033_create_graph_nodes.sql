SQL
-- =====================================================
-- ETOS 2.0
-- Migration 033
-- Graph Nodes
--
-- Universelle Knotenstruktur für:
-- Projekte
-- Publikationen
-- Institute
-- Behörden
-- Tensorraum
-- ORKG
-- GitHub
-- Wissensquellen
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
-- Indizes
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
'Universelle Wissensgraph-Knoten für ETOS, Tensorraum, ORKG und PhoenixOffice';
 
COMMENT ON COLUMN etos.graph_node.node_type IS
'Typ des Knotens, z.B. project, publication, institute, repository';
 
COMMENT ON COLUMN etos.graph_node.external_source IS
'Externe Quelle wie ORKG, GitHub, OpenAlex, Zenodo oder TIB';
 
COMMENT ON COLUMN etos.graph_node.external_id IS
'Externe ID des jeweiligen Systems';
 
COMMENT ON COLUMN etos.graph_node.metadata IS
'Erweiterbare strukturierte Zusatzinformationen';
 
COMMIT;
