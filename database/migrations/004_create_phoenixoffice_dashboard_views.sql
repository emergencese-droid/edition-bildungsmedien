-- 004_create_phoenixoffice_dashboard_views.sql
-- Dashboard views grounded in the actual ETOS core and Phoenix extension tables.

CREATE INDEX IF NOT EXISTS idx_federation_active ON etos.federation(active);
CREATE INDEX IF NOT EXISTS idx_project_status ON etos.project(project_status);
CREATE INDEX IF NOT EXISTS idx_publication_status ON etos.publication(publication_status);
CREATE INDEX IF NOT EXISTS idx_funding_project ON etos.funding_program(project_id);
CREATE INDEX IF NOT EXISTS idx_federation_axis_federation ON etos.federation_axis(federation_id);
CREATE INDEX IF NOT EXISTS idx_federation_axis_axis ON etos.federation_axis(axis_id);
CREATE INDEX IF NOT EXISTS idx_project_federation_project ON etos.project_federation(project_id);
CREATE INDEX IF NOT EXISTS idx_publication_project ON etos.publication(project_id);
CREATE INDEX IF NOT EXISTS idx_lecture_event_date ON etos.lecture(event_date);

CREATE OR REPLACE VIEW etos.etos_lagebild AS
WITH axis_distribution AS (
  SELECT f.federation_id, COUNT(fa.axis_id)::NUMERIC AS axis_count
  FROM etos.federation f
  LEFT JOIN etos.federation_axis fa ON fa.federation_id = f.federation_id
  WHERE f.active
  GROUP BY f.federation_id
)
SELECT
  (SELECT COUNT(*) FROM etos.federation WHERE active) AS active_federations,
  (SELECT COUNT(*) FROM etos.research_axis) AS research_axes,
  (SELECT COUNT(*) FROM etos.project WHERE project_status = 'AKTIV') AS active_projects,
  (SELECT COUNT(*) FROM etos.publication WHERE publication_status = 'VEROEFFENTLICHT') AS published_publications,
  (SELECT COUNT(*) FROM etos.lecture WHERE event_date >= CURRENT_DATE) AS upcoming_lectures,
  (SELECT COALESCE(SUM(amount_eur), 0) FROM etos.funding_program WHERE funding_status IN ('BEWILLIGT','AUSGEZAHLT')) AS confirmed_funding_eur,
  (SELECT COUNT(*) FROM etos.document WHERE document_status IN ('IN_REVIEW','FREIGEGEBEN','VEROEFFENTLICHT')) AS active_documents,
  ROUND((SELECT AVG(axis_count) FROM axis_distribution), 2) AS average_axes_per_federation,
  ROUND(100.0 * (SELECT COUNT(*) FROM axis_distribution WHERE axis_count >= 2) / NULLIF((SELECT COUNT(*) FROM axis_distribution), 0), 2) AS interdisciplinary_federation_percent;

CREATE OR REPLACE VIEW etos.phoenixoffice_dashboard AS
SELECT
  (SELECT COUNT(*) FROM etos.module WHERE active) AS active_modules,
  (SELECT COUNT(*) FROM etos.document) AS total_documents,
  (SELECT COUNT(*) FROM etos.document_version) AS total_document_versions,
  (SELECT COUNT(*) FROM etos.routing_event WHERE occurred_at >= CURRENT_DATE - INTERVAL '30 days') AS routing_events_30d,
  (SELECT COUNT(*) FROM etos.document WHERE document_status = 'IN_REVIEW') AS documents_in_review,
  (SELECT COUNT(*) FROM etos.project WHERE project_status = 'AKTIV') AS active_projects,
  (SELECT COALESCE(SUM(amount_eur), 0) FROM etos.funding_program WHERE funding_status IN ('BEWILLIGT','AUSGEZAHLT')) AS confirmed_funding_eur,
  (SELECT ROUND(AVG(score), 4) FROM etos.routing_event WHERE score IS NOT NULL) AS average_routing_score,
  (SELECT COUNT(*) FROM etos.publication WHERE publication_status = 'VEROEFFENTLICHT') AS published_publications,
  (SELECT COUNT(*) FROM etos.lecture WHERE event_date >= CURRENT_DATE) AS upcoming_lectures;

CREATE OR REPLACE VIEW etos.phoenixoffice_dashboard_kpis AS
SELECT
  (SELECT COUNT(*) FROM etos.federation WHERE active) AS active_federations,
  (SELECT COUNT(*) FROM etos.project WHERE project_status = 'AKTIV') AS active_projects,
  (SELECT COUNT(*) FROM etos.publication WHERE publication_status = 'VEROEFFENTLICHT') AS published_publications,
  (SELECT COUNT(*) FROM etos.lecture WHERE event_date >= CURRENT_DATE) AS upcoming_lectures,
  (SELECT COALESCE(SUM(amount_eur), 0) FROM etos.funding_program WHERE funding_status IN ('BEWILLIGT','AUSGEZAHLT')) AS confirmed_funding_eur,
  (SELECT COUNT(*) FROM etos.document WHERE document_status IN ('IN_REVIEW','FREIGEGEBEN','VEROEFFENTLICHT')) AS active_documents,
  (SELECT COUNT(*) FROM etos.routing_event WHERE occurred_at >= CURRENT_DATE - INTERVAL '30 days') AS routing_events_last_30d,
  (SELECT ROUND(AVG(score), 4) FROM etos.routing_event WHERE score IS NOT NULL) AS avg_routing_score;

CREATE OR REPLACE VIEW etos.phoenixoffice_heatmap AS
SELECT
  s.module_name AS source_module,
  t.module_name AS target_module,
  COUNT(*) AS event_count,
  ROUND(AVG(re.score), 4) AS avg_score,
  MAX(re.occurred_at) AS last_event_at
FROM etos.routing_event re
JOIN etos.module s ON s.module_id = re.source_module_id
JOIN etos.module t ON t.module_id = re.target_module_id
GROUP BY s.module_id, s.module_name, t.module_id, t.module_name;

CREATE OR REPLACE VIEW etos.phoenixoffice_module_matrix AS
SELECT
  s.module_name AS source_module,
  t.module_name AS target_module,
  COUNT(*) AS event_count,
  ROUND(AVG(re.score), 4) AS average_score,
  COUNT(*) FILTER (WHERE re.event_status = 'ERFASST') AS events_erfasst,
  COUNT(*) FILTER (WHERE re.event_status = 'AUSGEWERTET') AS events_ausgewertet,
  COUNT(*) FILTER (WHERE re.event_status = 'ARCHIVIERT') AS events_archiviert,
  MAX(re.occurred_at) AS last_event_at
FROM etos.routing_event re
JOIN etos.module s ON s.module_id = re.source_module_id
JOIN etos.module t ON t.module_id = re.target_module_id
GROUP BY s.module_id, s.module_name, t.module_id, t.module_name;

CREATE OR REPLACE VIEW etos.phoenixoffice_document_pipeline AS
SELECT
  d.document_id, d.document_code, d.title, d.document_type, d.document_status,
  d.created_at, MAX(dv.version_number) AS latest_version_number,
  MAX(dv.created_at) AS latest_version_created_at, COUNT(dv.version_id) AS total_versions,
  p.title AS related_project_title
FROM etos.document d
LEFT JOIN etos.document_version dv ON dv.document_id = d.document_id
LEFT JOIN etos.project p ON p.project_id = d.project_id
GROUP BY d.document_id, d.document_code, d.title, d.document_type, d.document_status, d.created_at, p.title;

CREATE OR REPLACE VIEW etos.phoenixoffice_document_status_overview AS
SELECT document_status, document_type, COUNT(*) AS document_count,
  ROUND(AVG(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at)) / 86400.0), 1) AS avg_age_days
FROM etos.document
GROUP BY document_status, document_type;

CREATE OR REPLACE VIEW etos.phoenixoffice_research_overview AS
WITH axis_projects AS (
  SELECT a.axis_id, a.axis_name, COUNT(DISTINCT p.project_id) AS project_count,
    COUNT(DISTINCT pub.publication_id) AS publication_count
  FROM etos.research_axis a
  LEFT JOIN etos.federation_axis fa ON fa.axis_id = a.axis_id
  LEFT JOIN etos.project_federation pf ON pf.federation_id = fa.federation_id
  LEFT JOIN etos.project p ON p.project_id = pf.project_id
  LEFT JOIN etos.publication pub ON pub.project_id = p.project_id
  GROUP BY a.axis_id, a.axis_name
), axis_funding AS (
  SELECT a.axis_id, COALESCE(SUM(DISTINCT f.amount_eur), 0) AS funding_total_eur
  FROM etos.research_axis a
  LEFT JOIN etos.federation_axis fa ON fa.axis_id = a.axis_id
  LEFT JOIN etos.project_federation pf ON pf.federation_id = fa.federation_id
  LEFT JOIN etos.funding_program f ON f.project_id = pf.project_id
  GROUP BY a.axis_id
)
SELECT ap.axis_name, ap.project_count, ap.publication_count, af.funding_total_eur
FROM axis_projects ap
JOIN axis_funding af ON af.axis_id = ap.axis_id;
