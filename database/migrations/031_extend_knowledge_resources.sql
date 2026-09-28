-- =====================================================
-- ETOS 2.0
-- Migration 031
-- Erweiterung der Knowledge-Resource-Schicht
--
-- Ziel:
-- ORKG, Tensorraum, DOI, Tags und Embedding-Status
-- als Vorbereitung für Wissensgraphen und Vektorräume.
-- =====================================================
 
BEGIN;
 
-- -----------------------------------------------------
-- ORKG Referenzen
-- -----------------------------------------------------
 
ALTER TABLE etos.knowledge_resource
ADD COLUMN IF NOT EXISTS orkg_id TEXT;
 
-- -----------------------------------------------------
-- Wissenschaftliche Referenzen
-- -----------------------------------------------------
 
ALTER TABLE etos.knowledge_resource
ADD COLUMN IF NOT EXISTS doi TEXT;
 
-- -----------------------------------------------------
-- Tensorraum-Verbindung
-- -----------------------------------------------------
 
ALTER TABLE etos.knowledge_resource
ADD COLUMN IF NOT EXISTS tensor_node_id TEXT;
 
-- -----------------------------------------------------
-- Semantische Tags
-- -----------------------------------------------------
 
ALTER TABLE etos.knowledge_resource
ADD COLUMN IF NOT EXISTS tags JSONB
DEFAULT '[]'::jsonb;
 
-- -----------------------------------------------------
-- Embedding Status
-- -----------------------------------------------------
 
ALTER TABLE etos.knowledge_resource
ADD COLUMN IF NOT EXISTS embedded BOOLEAN
DEFAULT FALSE;
 
-- -----------------------------------------------------
-- Zusätzliche Metadaten
-- -----------------------------------------------------
 
ALTER TABLE etos.knowledge_resource
ADD COLUMN IF NOT EXISTS source_identifier TEXT;
 
ALTER TABLE etos.knowledge_resource
ADD COLUMN IF NOT EXISTS language_code VARCHAR(10);
 
ALTER TABLE etos.knowledge_resource
ADD COLUMN IF NOT EXISTS organisation_name VARCHAR(255);
 
-- -----------------------------------------------------
-- Indizes
-- -----------------------------------------------------
 
CREATE INDEX IF NOT EXISTS
idx_knowledge_resource_orkg_id
ON etos.knowledge_resource(orkg_id);
 
CREATE INDEX IF NOT EXISTS
idx_knowledge_resource_doi
ON etos.knowledge_resource(doi);
 
CREATE INDEX IF NOT EXISTS
idx_knowledge_resource_embedded
ON etos.knowledge_resource(embedded);
 
-- -----------------------------------------------------
-- Dokumentation
-- -----------------------------------------------------
 
COMMENT ON COLUMN etos.knowledge_resource.orkg_id IS
'Externe ORKG Ressource oder Konzept-ID';
 
COMMENT ON COLUMN etos.knowledge_resource.doi IS
'Digital Object Identifier der Ressource';
 
COMMENT ON COLUMN etos.knowledge_resource.tensor_node_id IS
'Verbindung zum Tensorraum-Knoten';
 
COMMENT ON COLUMN etos.knowledge_resource.embedded IS
'Kennzeichnet ob bereits Embeddings erzeugt wurden';
 
COMMENT ON COLUMN etos.knowledge_resource.tags IS
'Semantische Schlagworte zur Suche und Kategorisierung';
 
COMMIT;
