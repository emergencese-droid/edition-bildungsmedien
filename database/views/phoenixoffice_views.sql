CREATE OR REPLACE VIEW etos.phoenixoffice_dashboard_kpis AS
SELECT
  (SELECT COUNT(*) FROM etos.federation WHERE active = TRUE) AS active_federations,
  (SELECT COUNT(*) FROM etos.project WHERE project_status = 'AKTIV') AS active_projects,
  (SELECT COUNT(*) FROM etos.publication WHERE publication_status = 'VEROEFFENTLICHT') AS published_publications,
  (SELECT COUNT(*) FROM etos.lecture WHERE event_date >= CURRENT_DATE) AS upcoming_lectures,
  (SELECT COALESCE(SUM(amount_eur), 0) FROM etos.funding_program WHERE funding_status IN ('BEWILLIGT', 'AUSGEZAHLT')) AS confirmed_funding_eur,
  (SELECT COUNT(*) FROM etos.document WHERE document_status IN ('IN_REVIEW', 'FREIGEGEBEN', 'VEROEFFENTLICHT')) AS active_documents,
  (SELECT COUNT(*) FROM etos.routing_event WHERE occurred_at >= CURRENT_DATE - INTERVAL '30 days') AS routing_events_last_30d,
  (SELECT ROUND(AVG(score), 4) FROM etos.routing_event WHERE score IS NOT NULL) AS avg_routing_score;

CREATE OR REPLACE VIEW etos.etos_lagebild AS
WITH axis_distribution AS (
  SELECT f.federation_id, COUNT(fa.axis_id)::NUMERIC AS axis_count
  FROM etos.federation f
  LEFT JOIN etos.federation_axis fa ON fa.federation_id = f.federation_id
  WHERE f.active = TRUE
  GROUP BY f.federation_id
)
SELECT
  (SELECT COUNT(*) FROM etos.federation WHERE active = TRUE) AS active_federations,
  (SELECT COUNT(*) FROM etos.research_axis) AS research_axes,
  (SELECT COUNT(*) FROM etos.project WHERE project_status = 'AKTIV') AS active_projects,
  (SELECT COUNT(*) FROM etos.publication WHERE publication_status = 'VEROEFFENTLICHT') AS published_publications,
  (SELECT COUNT(*) FROM etos.lecture WHERE event_date >= CURRENT_DATE) AS upcoming_lectures,
  (SELECT COALESCE(SUM(amount_eur), 0) FROM etos.funding_program WHERE funding_status IN ('BEWILLIGT', 'AUSGEZAHLT')) AS confirmed_funding_eur,
  (SELECT COUNT(*) FROM etos.document WHERE document_status IN ('IN_REVIEW', 'FREIGEGEBEN', 'VEROEFFENTLICHT')) AS active_documents,
  ROUND((SELECT AVG(axis_count) FROM axis_distribution), 2) AS average_axes_per_federation,
  ROUND(
    100.0 * (
      SELECT COUNT(*) FROM axis_distribution WHERE axis_count >= 2
    ) / NULLIF((SELECT COUNT(*) FROM axis_distribution), 0),
    2
  ) AS interdisciplinary_federation_percent;

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
GROUP BY s.module_name, t.module_name
ORDER BY event_count DESC, source_module, target_module;

CREATE OR REPLACE VIEW etos.phoenixoffice_document_pipeline AS
SELECT
  d.document_id,
  d.document_code,
  d.title,
  d.document_type,
  d.document_status,
  d.created_at,
  MAX(dv.version_number) AS latest_version_number,
  MAX(dv.created_at) AS latest_version_created_at,
  COUNT(dv.version_id) AS total_versions,
  p.title AS related_project_title
FROM etos.document d
LEFT JOIN etos.document_version dv ON dv.document_id = d.document_id
LEFT JOIN etos.project p ON p.project_id = d.project_id
GROUP BY d.document_id, d.document_code, d.title, d.document_type, d.document_status, d.created_at, p.title
ORDER BY d.created_at DESC;

CREATE OR REPLACE VIEW etos.phoenixoffice_document_status_overview AS
SELECT
  document_status,
  document_type,
  COUNT(*) AS document_count,
  ROUND(AVG(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at)) / 86400.0), 1) AS avg_age_days
FROM etos.document
GROUP BY document_status, document_type
ORDER BY document_status, document_type;

CREATE OR REPLACE VIEW etos.phoenixoffice_research_overview AS
SELECT
  a.axis_name,
  COUNT(DISTINCT p.project_id) AS project_count,
  COUNT(DISTINCT pub.publication_id) AS publication_count,
  COALESCE(SUM(f.amount_eur), 0) AS funding_total_eur
FROM etos.research_axis a
LEFT JOIN etos.federation_axis fa ON fa.axis_id = a.axis_id
LEFT JOIN etos.project_federation pf ON pf.federation_id = fa.federation_id
LEFT JOIN etos.project p ON p.project_id = pf.project_id
LEFT JOIN etos.publication pub ON pub.project_id = p.project_id
LEFT JOIN etos.funding_program f ON f.project_id = p.project_id
GROUP BY a.axis_id, a.axis_name
ORDER BY project_count DESC, publication_count DESC, a.axis_name;

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
GROUP BY s.module_id, s.module_name, t.module_id, t.module_name
ORDER BY event_count DESC, source_module, target_module;

CREATE OR REPLACE VIEW etos.api_phoenixoffice_dashboard AS
SELECT jsonb_build_object(
  'kpis', (
    SELECT jsonb_agg(to_jsonb(k))
    FROM (
      SELECT * FROM etos.phoenixoffice_dashboard_kpis
    ) k
  ),
  'lagebild', (
    SELECT jsonb_agg(to_jsonb(l))
    FROM (
      SELECT * FROM etos.etos_lagebild
    ) l
  ),
  'heatmap', (
    SELECT jsonb_agg(to_jsonb(h))
    FROM (
      SELECT * FROM etos.phoenixoffice_heatmap
    ) h
  ),
  'document_pipeline', (
    SELECT jsonb_agg(to_jsonb(d))
    FROM (
      SELECT * FROM etos.phoenixoffice_document_pipeline
    ) d
  ),
  'research_overview', (
    SELECT jsonb_agg(to_jsonb(r))
    FROM (
      SELECT * FROM etos.phoenixoffice_research_overview
    ) r
  ),
  'module_matrix', (
    SELECT jsonb_agg(to_jsonb(m))
    FROM (
      SELECT * FROM etos.phoenixoffice_module_matrix
    ) m
  ),
  'recent_activity', (
    SELECT jsonb_agg(to_jsonb(a))
    FROM (
      SELECT re.route_name, s.module_name AS source_module, t.module_name AS target_module,
             re.event_status, re.score, re.occurred_at
      FROM etos.routing_event re
      JOIN etos.module s ON s.module_id = re.source_module_id
      JOIN etos.module t ON t.module_id = re.target_module_id
      ORDER BY re.occurred_at DESC
      LIMIT 25
    ) a
  )
) AS payload;

CREATE OR REPLACE VIEW etos.api_phoenixoffice_kpis AS
SELECT jsonb_build_object(
  'active_federations', active_federations,
  'active_projects', active_projects,
  'published_publications', published_publications,
  'upcoming_lectures', upcoming_lectures,
  'confirmed_funding_eur', confirmed_funding_eur,
  'active_documents', active_documents,
  'routing_events_last_30d', routing_events_last_30d,
  'avg_routing_score', avg_routing_score
) AS payload
FROM etos.phoenixoffice_dashboard_kpis;

CREATE OR REPLACE VIEW etos.api_phoenixoffice_lagebild AS
SELECT jsonb_build_object(
  'active_federations', active_federations,
  'research_axes', research_axes,
  'active_projects', active_projects,
  'published_publications', published_publications,
  'upcoming_lectures', upcoming_lectures,
  'confirmed_funding_eur', confirmed_funding_eur,
  'active_documents', active_documents,
  'average_axes_per_federation', average_axes_per_federation,
  'interdisciplinary_federation_percent', interdisciplinary_federation_percent
) AS payload
FROM etos.etos_lagebild;

CREATE OR REPLACE VIEW etos.api_phoenixoffice_heatmap AS
SELECT jsonb_agg(to_jsonb(x)) AS payload
FROM (
  SELECT * FROM etos.phoenixoffice_heatmap
) x;

CREATE OR REPLACE VIEW etos.api_phoenixoffice_document_pipeline AS
SELECT jsonb_agg(to_jsonb(x)) AS payload
FROM (
  SELECT * FROM etos.phoenixoffice_document_pipeline
) x;

CREATE OR REPLACE VIEW etos.api_phoenixoffice_research_overview AS
SELECT jsonb_agg(to_jsonb(x)) AS payload
FROM (
  SELECT * FROM etos.phoenixoffice_research_overview
) x;

CREATE OR REPLACE VIEW etos.api_phoenixoffice_recent_activity AS
SELECT jsonb_agg(to_jsonb(x)) AS payload
FROM (
  SELECT re.route_name, s.module_name AS source_module, t.module_name AS target_module,
         re.event_status, re.score, re.occurred_at
  FROM etos.routing_event re
  JOIN etos.module s ON s.module_id = re.source_module_id
  JOIN etos.module t ON t.module_id = re.target_module_id
  ORDER BY re.occurred_at DESC
  LIMIT 25
) x;
