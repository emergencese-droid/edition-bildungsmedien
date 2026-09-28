-- =====================================================
-- ETOS 2.0
-- Migration 032
-- Tensorraum-Knoten
-- =====================================================
 
BEGIN;
 
CREATE TABLE IF NOT EXISTS etos.tensor_node (
 
tensor_node_id UUID PRIMARY KEY
DEFAULT gen_random_uuid(),
 
resource_id UUID
REFERENCES etos.knowledge_resource(resource_id)
ON DELETE CASCADE,
 
node_type TEXT NOT NULL,
 
label TEXT NOT NULL,
 
metadata JSONB
DEFAULT '{}'::jsonb,
 
created_at TIMESTAMPTZ
DEFAULT CURRENT_TIMESTAMP
);
 
CREATE INDEX IF NOT EXISTS
idx_tensor_node_resource
ON etos.tensor_node(resource_id);
 
CREATE INDEX IF NOT EXISTS
idx_tensor_node_type
ON etos.tensor_node(node_type);
 
COMMIT;
