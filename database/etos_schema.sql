-- ETOS 2.0 civilian research and innovation network
-- PostgreSQL schema, reference model only.
-- The organisations represented by seed data are public reference nodes,
-- not evidence of partnership, mandate, endorsement, or data access.

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS etos;

CREATE TABLE etos.federation (
  federation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_code CHAR(2) NOT NULL,
  country_name VARCHAR(100) NOT NULL,
  organisation_name VARCHAR(255) NOT NULL,
  headquarters_city VARCHAR(120),
  organisation_type VARCHAR(100) NOT NULL,
  website TEXT,
  founded_year INTEGER,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_federation_country UNIQUE (country_code),
  CONSTRAINT uq_federation_name UNIQUE (organisation_name),
  CONSTRAINT chk_federation_country_code CHECK (country_code ~ '^[A-Z]{2}$'),
  CONSTRAINT chk_federation_founded_year CHECK (founded_year IS NULL OR founded_year BETWEEN 1800 AND EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER)
);

CREATE TABLE etos.research_axis (
  axis_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  axis_code VARCHAR(40) NOT NULL UNIQUE,
  axis_name VARCHAR(200) NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE etos.federation_axis (
  federation_id UUID NOT NULL REFERENCES etos.federation(federation_id) ON DELETE CASCADE,
  axis_id BIGINT NOT NULL REFERENCES etos.research_axis(axis_id) ON DELETE CASCADE,
  relevance SMALLINT NOT NULL DEFAULT 3,
  PRIMARY KEY (federation_id, axis_id),
  CONSTRAINT chk_axis_relevance CHECK (relevance BETWEEN 1 AND 5)
);

CREATE TABLE etos.project (
  project_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_code VARCHAR(40) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  project_status VARCHAR(40) NOT NULL DEFAULT 'KONZEPT',
  start_date DATE,
  target_date DATE,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_project_status CHECK (project_status IN ('KONZEPT','PLANUNG','AKTIV','PAUSIERT','ABGESCHLOSSEN')),
  CONSTRAINT chk_project_dates CHECK (target_date IS NULL OR start_date IS NULL OR target_date >= start_date)
);

CREATE TABLE etos.project_federation (
  project_id UUID NOT NULL REFERENCES etos.project(project_id) ON DELETE CASCADE,
  federation_id UUID NOT NULL REFERENCES etos.federation(federation_id) ON DELETE CASCADE,
  role_name VARCHAR(120) NOT NULL,
  PRIMARY KEY (project_id, federation_id)
);

CREATE TABLE etos.publication (
  publication_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(500) NOT NULL,
  publication_type VARCHAR(50) NOT NULL,
  publication_status VARCHAR(50) NOT NULL DEFAULT 'PLANUNG',
  publication_date DATE,
  doi VARCHAR(255) UNIQUE,
  project_id UUID REFERENCES etos.project(project_id) ON DELETE SET NULL,
  CONSTRAINT chk_publication_type CHECK (publication_type IN ('BUCH','ARTIKEL','WHITEPAPER','FORSCHUNGSBERICHT','DATENSATZ','VORTRAG')),
  CONSTRAINT chk_publication_status CHECK (publication_status IN ('PLANUNG','REVIEW','VEROEFFENTLICHT','ARCHIVIERT'))
);

CREATE TABLE etos.lecture (
  lecture_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  city VARCHAR(120),
  country_code CHAR(2),
  event_date DATE,
  project_id UUID REFERENCES etos.project(project_id) ON DELETE SET NULL,
  CONSTRAINT fk_lecture_country FOREIGN KEY (country_code) REFERENCES etos.federation(country_code) ON UPDATE CASCADE
);

CREATE TABLE etos.funding_program (
  funding_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  sponsor VARCHAR(255) NOT NULL,
  amount_eur NUMERIC(18,2) NOT NULL,
  funding_status VARCHAR(40) NOT NULL DEFAULT 'BEANTRAGT',
  project_id UUID REFERENCES etos.project(project_id) ON DELETE SET NULL,
  CONSTRAINT chk_funding_amount CHECK (amount_eur >= 0),
  CONSTRAINT chk_funding_status CHECK (funding_status IN ('BEANTRAGT','BEWILLIGT','AUSGEZAHLT','ABGELEHNT'))
);

CREATE TABLE etos.kpi_measurement (
  measurement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_code VARCHAR(80) NOT NULL,
  metric_name VARCHAR(160) NOT NULL,
  metric_value NUMERIC(18,4) NOT NULL,
  metric_unit VARCHAR(40) NOT NULL,
  measured_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  source_note TEXT,
  CONSTRAINT chk_metric_value CHECK (metric_value >= 0)
);

CREATE INDEX idx_project_status ON etos.project(project_status);
CREATE INDEX idx_project_federation_federation ON etos.project_federation(federation_id);
CREATE INDEX idx_publication_status ON etos.publication(publication_status);
CREATE INDEX idx_kpi_metric_time ON etos.kpi_measurement(metric_code, measured_at DESC);

CREATE VIEW etos.dashboard_summary AS
SELECT
  (SELECT COUNT(*) FROM etos.federation WHERE active) AS active_federations,
  (SELECT COUNT(DISTINCT country_code) FROM etos.federation WHERE active) AS represented_states,
  (SELECT COUNT(*) FROM etos.research_axis) AS research_axes,
  (SELECT COUNT(*) FROM etos.project WHERE project_status = 'AKTIV') AS active_projects,
  (SELECT COUNT(*) FROM etos.publication WHERE publication_status = 'VEROEFFENTLICHT') AS published_publications,
  (SELECT COUNT(*) FROM etos.lecture WHERE event_date IS NULL OR event_date <= CURRENT_DATE) AS lectures_total,
  (SELECT COALESCE(SUM(amount_eur), 0) FROM etos.funding_program WHERE funding_status IN ('BEWILLIGT','AUSGEZAHLT')) AS confirmed_funding_eur;
