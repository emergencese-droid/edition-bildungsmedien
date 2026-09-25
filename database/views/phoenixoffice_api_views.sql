CREATE OR REPLACE VIEW etos.api_phoenixoffice_dashboard AS
SELECT jsonb_build_object(
  'kpis', (
    SELECT jsonb_agg(to_jsonb(k))
    FROM (
      SELECT *
      FROM etos.phoenixoffice_dashboard_kpis
    ) k
  ),
  'lagebild', (
    SELECT jsonb_agg(to_jsonb(l))
    FROM (
      SELECT *
      FROM etos.etos_lagebild
    ) l
  ),
  'heatmap', (
    SELECT jsonb_agg(to_jsonb(h))
    FROM (
      SELECT *
      FROM etos.phoenixoffice_heatmap
    ) h
  ),
  'document_pipeline', (
    SELECT jsonb_agg(to_jsonb(d))
    FROM (
      SELECT *
      FROM etos.phoenixoffice_document_pipeline
    ) d
  ),
  'research_overview', (
    SELECT jsonb_agg(to_jsonb(r))
    FROM (
      SELECT *
      FROM etos.phoenixoffice_research_overview
    ) r
  ),
  'recent_activity', (
    SELECT jsonb_agg(to_jsonb(a))
    FROM (
      SELECT
        route_name,
        source_module,
        target_module,
        event_status,
        score,
        occurred_at
      FROM (
        SELECT
          re.route_name,
          s.module_name AS source_module,
          t.module_name AS target_module,
          re.event_status,
          re.score,
          re.occurred_at
        FROM etos.routing_event re
        JOIN etos.module s ON s.module_id = re.source_module_id
        JOIN etos.module t ON t.module_id = re.target_module_id
        ORDER BY re.occurred_at DESC
        LIMIT 25
      ) x
    ) a
  ),
  'module_matrix', (
    SELECT jsonb_agg(to_jsonb(m))
    FROM (
      SELECT *
      FROM etos.phoenixoffice_module_matrix
    ) m
  ),
  'reference_network', (
    SELECT jsonb_agg(to_jsonb(n))
    FROM (
      SELECT *
      FROM (
        SELECT
          f.country_code,
          f.country_name,
          f.organisation_name,
          COUNT(DISTINCT fa.axis_id) AS axis_count,
          COUNT(DISTINCT pf.project_id) AS project_count
        FROM etos.federation f
        LEFT JOIN etos.federation_axis fa ON fa.federation_id = f.federation_id
        LEFT JOIN etos.project_federation pf ON pf.federation_id = f.federation_id
        WHERE f.active = TRUE
        GROUP BY f.federation_id, f.country_code, f.country_name, f.organisation_name
      ) n
    ) n
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
  SELECT *
  FROM etos.phoenixoffice_heatmap
) x;

CREATE OR REPLACE VIEW etos.api_phoenixoffice_document_pipeline AS
SELECT jsonb_agg(to_jsonb(x)) AS payload
FROM (
  SELECT *
  FROM etos.phoenixoffice_document_pipeline
) x;

CREATE OR REPLACE VIEW etos.api_phoenixoffice_research_overview AS
SELECT jsonb_agg(to_jsonb(x)) AS payload
FROM (
  SELECT *
  FROM etos.phoenixoffice_research_overview
) x;

CREATE OR REPLACE VIEW etos.api_phoenixoffice_recent_activity AS
SELECT jsonb_agg(to_jsonb(x)) AS payload
FROM (
  SELECT
    re.route_name,
    s.module_name AS source_module,
    t.module_name AS target_module,
    re.event_status,
    re.score,
    re.occurred_at
  FROM etos.routing_event re
  JOIN etos.module s ON s.module_id = re.source_module_id
  JOIN etos.module t ON t.module_id = re.target_module_id
  ORDER BY re.occurred_at DESC
  LIMIT 25
) x;
