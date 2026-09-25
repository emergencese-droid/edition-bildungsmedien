-- ETOS 2.0 extensions for PhoenixOffice, PhoenixWrite and routing.
-- Civilian workflow metadata only; no operational security data.

CREATE TABLE etos.module (
  module_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_code VARCHAR(60) NOT NULL UNIQUE,
  module_name VARCHAR(160) NOT NULL UNIQUE,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE etos.routing_event (
  event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  route_name VARCHAR(100) NOT NULL,
  source_module_id UUID NOT NULL REFERENCES etos.module(module_id) ON DELETE RESTRICT,
  target_module_id UUID NOT NULL REFERENCES etos.module(module_id) ON DELETE RESTRICT,
  score NUMERIC(10,4),
  event_status VARCHAR(30) NOT NULL DEFAULT 'ERFASST',
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_route_modules_differ CHECK (source_module_id <> target_module_id),
  CONSTRAINT chk_route_score CHECK (score IS NULL OR score BETWEEN 0 AND 1),
  CONSTRAINT chk_route_status CHECK (event_status IN ('ERFASST','AUSGEWERTET','ARCHIVIERT'))
);

CREATE INDEX idx_routing_event_time ON etos.routing_event(occurred_at DESC);
CREATE INDEX idx_routing_event_source ON etos.routing_event(source_module_id);
CREATE INDEX idx_routing_event_target ON etos.routing_event(target_module_id);

CREATE TABLE etos.document (
  document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_code VARCHAR(60) NOT NULL UNIQUE,
  title VARCHAR(500) NOT NULL,
  document_type VARCHAR(60) NOT NULL,
  document_status VARCHAR(40) NOT NULL DEFAULT 'ENTWURF',
  project_id UUID REFERENCES etos.project(project_id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_document_type CHECK (document_type IN ('MANUSKRIPT','FORSCHUNGSBERICHT','WHITEPAPER','VORTRAG','BUCH','ARBEITSPAPIER')),
  CONSTRAINT chk_document_status CHECK (document_status IN ('ENTWURF','IN_REVIEW','FREIGEGEBEN','VEROEFFENTLICHT','ARCHIVIERT'))
);

CREATE TABLE etos.document_version (
  version_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES etos.document(document_id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,
  change_summary TEXT,
  content_uri TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (document_id, version_number),
  CONSTRAINT chk_version_number CHECK (version_number > 0)
);

CREATE INDEX idx_document_status ON etos.document(document_status);
CREATE INDEX idx_document_version_document ON etos.document_version(document_id, version_number DESC);

INSERT INTO etos.module (module_code, module_name) VALUES
  ('DASHBOARD','Lagebild'),
  ('COMMUNICATION','Kommunikation'),
  ('PHOENIX_WRITE','PhoenixWrite'),
  ('RESEARCH','Forschung'),
  ('STATISTICS','Statistik'),
  ('SUPPORT','Support'),
  ('SHOP','Shop')
ON CONFLICT (module_code) DO NOTHING;

INSERT INTO etos.document (document_code, title, document_type, document_status)
VALUES
  ('ETOS-DOC-001','ETOS 2.0 Civilian Network Model','WHITEPAPER','ENTWURF'),
  ('ETOS-DOC-002','Wissenssysteme und Bildungsarchitektur','FORSCHUNGSBERICHT','IN_REVIEW')
ON CONFLICT (document_code) DO NOTHING;

INSERT INTO etos.document_version (document_id, version_number, change_summary)
SELECT document_id, 1, 'Initiale Referenzfassung'
FROM etos.document
WHERE document_code IN ('ETOS-DOC-001','ETOS-DOC-002')
ON CONFLICT (document_id, version_number) DO NOTHING;
