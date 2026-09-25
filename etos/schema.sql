-- ETOS 2.0 reference schema
-- Civilian research and innovation network; no operational security or military data.
-- PostgreSQL 14+
BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS etos;

CREATE TYPE etos.project_status AS ENUM ('KONZEPT','PLANUNG','AKTIV','PAUSIERT','ABGESCHLOSSEN');
CREATE TYPE etos.publication_status AS ENUM ('ENTWURF','REVIEW','VEROEFFENTLICHT','ARCHIVIERT');
CREATE TYPE etos.publication_type AS ENUM ('BUCH','PAPER','BERICHT','DATENSATZ','VORTRAG');

CREATE TABLE etos.states (
  state_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_name VARCHAR(100) NOT NULL UNIQUE,
  iso_code CHAR(2) NOT NULL UNIQUE CHECK (iso_code = upper(iso_code)),
  capital VARCHAR(100),
  region VARCHAR(50),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE etos.federations (
  federation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  state_id UUID NOT NULL REFERENCES etos.states(state_id) ON DELETE RESTRICT,
  federation_name VARCHAR(255) NOT NULL,
  federation_type VARCHAR(100) NOT NULL,
  headquarters_city VARCHAR(120),
  established_year INTEGER CHECK (established_year IS NULL OR established_year BETWEEN 1800 AND EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER),
  website TEXT CHECK (website IS NULL OR website ~ '^https?://'),
  scientific_focus TEXT,
  strategic_role TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_federation_state_name UNIQUE (state_id, federation_name)
);

CREATE TABLE etos.council_seats (
  council_seat_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  federation_id UUID NOT NULL UNIQUE REFERENCES etos.federations(federation_id) ON DELETE CASCADE,
  seat_name VARCHAR(255) NOT NULL,
  voting_weight NUMERIC(5,2) NOT NULL DEFAULT 1.00 CHECK (voting_weight > 0),
  active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE etos.research_axes (
  axis_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  axis_code VARCHAR(40) NOT NULL UNIQUE,
  axis_name VARCHAR(120) NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE etos.federation_axes (
  federation_id UUID NOT NULL REFERENCES etos.federations(federation_id) ON DELETE CASCADE,
  axis_id BIGINT NOT NULL REFERENCES etos.research_axes(axis_id) ON DELETE CASCADE,
  relevance SMALLINT NOT NULL DEFAULT 3 CHECK (relevance BETWEEN 1 AND 5),
  PRIMARY KEY (federation_id, axis_id)
);

CREATE TABLE etos.projects (
  project_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_code VARCHAR(40) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status etos.project_status NOT NULL DEFAULT 'KONZEPT',
  start_date DATE,
  target_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (target_date IS NULL OR start_date IS NULL OR target_date >= start_date)
);

CREATE TABLE etos.project_federations (
  project_id UUID NOT NULL REFERENCES etos.projects(project_id) ON DELETE CASCADE,
  federation_id UUID NOT NULL REFERENCES etos.federations(federation_id) ON DELETE CASCADE,
  role_name VARCHAR(120) NOT NULL,
  PRIMARY KEY (project_id, federation_id)
);

CREATE TABLE etos.project_axes (
  project_id UUID NOT NULL REFERENCES etos.projects(project_id) ON DELETE CASCADE,
  axis_id BIGINT NOT NULL REFERENCES etos.research_axes(axis_id) ON DELETE RESTRICT,
  PRIMARY KEY (project_id, axis_id)
);

CREATE TABLE etos.publications (
  publication_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES etos.projects(project_id) ON DELETE SET NULL,
  title VARCHAR(500) NOT NULL,
  publication_type etos.publication_type NOT NULL,
  publication_status etos.publication_status NOT NULL DEFAULT 'ENTWURF',
  publication_date DATE,
  doi VARCHAR(255) UNIQUE,
  CHECK (publication_date IS NULL OR publication_status IN ('VEROEFFENTLICHT','ARCHIVIERT'))
);

CREATE TABLE etos.lectures (
  lecture_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES etos.projects(project_id) ON DELETE SET NULL,
  title VARCHAR(255) NOT NULL,
  city VARCHAR(120),
  country VARCHAR(120),
  event_date DATE NOT NULL,
  delivery_mode VARCHAR(30) NOT NULL DEFAULT 'ONSITE' CHECK (delivery_mode IN ('ONSITE','ONLINE','HYBRID'))
);

CREATE TABLE etos.funding_programs (
  funding_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES etos.projects(project_id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  sponsor VARCHAR(255) NOT NULL,
  amount_eur NUMERIC(18,2) NOT NULL CHECK (amount_eur >= 0),
  funding_status VARCHAR(30) NOT NULL DEFAULT 'PLANUNG' CHECK (funding_status IN ('PLANUNG','BEANTRAGT','BEWILLIGT','ABGESCHLOSSEN'))
);

CREATE TABLE etos.metric_definitions (
  metric_code VARCHAR(60) PRIMARY KEY,
  metric_name VARCHAR(160) NOT NULL,
  unit VARCHAR(40) NOT NULL,
  description TEXT NOT NULL
);

CREATE TABLE etos.metric_measurements (
  measurement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_code VARCHAR(60) NOT NULL REFERENCES etos.metric_definitions(metric_code) ON DELETE RESTRICT,
  federation_id UUID REFERENCES etos.federations(federation_id) ON DELETE SET NULL,
  project_id UUID REFERENCES etos.projects(project_id) ON DELETE SET NULL,
  metric_value NUMERIC(18,4) NOT NULL,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  source_note TEXT NOT NULL
);

CREATE INDEX idx_federations_state ON etos.federations(state_id);
CREATE INDEX idx_projects_status ON etos.projects(status);
CREATE INDEX idx_publications_status ON etos.publications(publication_status);
CREATE INDEX idx_measurements_metric_date ON etos.metric_measurements(metric_code, recorded_at DESC);

CREATE OR REPLACE VIEW etos.dashboard_summary AS
SELECT
  (SELECT count(*) FROM etos.states WHERE active) AS active_states,
  (SELECT count(*) FROM etos.federations WHERE active) AS active_federations,
  (SELECT count(*) FROM etos.research_axes) AS research_axes,
  (SELECT count(*) FROM etos.projects) AS projects_total,
  (SELECT count(*) FROM etos.projects WHERE status = 'AKTIV') AS projects_active,
  (SELECT count(*) FROM etos.publications WHERE publication_status = 'VEROEFFENTLICHT') AS publications_published,
  (SELECT count(*) FROM etos.lectures WHERE event_date >= date_trunc('year', CURRENT_DATE)) AS lectures_this_year,
  (SELECT coalesce(sum(amount_eur), 0) FROM etos.funding_programs WHERE funding_status IN ('BEWILLIGT','ABGESCHLOSSEN')) AS awarded_funding_eur;

COMMIT;
