-- ETOS dashboard queries for PostgreSQL.
-- Values are computed from the civilian reference schema and should be
-- labelled as reference/demo data until connected to verified data sources.

-- 1. Main KPI summary
SELECT * FROM etos.dashboard_summary;

-- 2. Ten-state / federation matrix
SELECT country_code, country_name, organisation_name, headquarters_city, organisation_type
FROM etos.federation
WHERE active
ORDER BY country_name;

-- 3. Active projects
SELECT project_code, title, project_status, start_date, target_date
FROM etos.project
WHERE project_status = 'AKTIV'
ORDER BY target_date NULLS LAST, title;

-- 4. Projects by federation
SELECT f.organisation_name, f.country_code, COUNT(pf.project_id) AS project_count
FROM etos.federation f
LEFT JOIN etos.project_federation pf ON pf.federation_id = f.federation_id
GROUP BY f.federation_id, f.organisation_name, f.country_code
ORDER BY project_count DESC, f.organisation_name;

-- 5. Active projects by research axis
SELECT a.axis_code, a.axis_name, COUNT(DISTINCT p.project_id) AS active_projects
FROM etos.research_axis a
JOIN etos.federation_axis fa ON fa.axis_id = a.axis_id
JOIN etos.project_federation pf ON pf.federation_id = fa.federation_id
JOIN etos.project p ON p.project_id = pf.project_id
WHERE p.project_status = 'AKTIV'
GROUP BY a.axis_id, a.axis_code, a.axis_name
ORDER BY active_projects DESC, a.axis_name;

-- 6. Publication pipeline
SELECT publication_status, publication_type, COUNT(*) AS publication_count
FROM etos.publication
GROUP BY publication_status, publication_type
ORDER BY publication_status, publication_type;

-- 7. Confirmed funding by project
SELECT p.project_code, p.title, COALESCE(SUM(f.amount_eur), 0) AS confirmed_funding_eur
FROM etos.project p
LEFT JOIN etos.funding_program f
  ON f.project_id = p.project_id
 AND f.funding_status IN ('BEWILLIGT','AUSGEZAHLT')
GROUP BY p.project_id, p.project_code, p.title
ORDER BY confirmed_funding_eur DESC;

-- 8. Network cohesion: average number of research axes per federation
SELECT ROUND(AVG(axis_count), 2) AS avg_axes_per_federation
FROM (
  SELECT f.federation_id, COUNT(fa.axis_id) AS axis_count
  FROM etos.federation f
  LEFT JOIN etos.federation_axis fa ON fa.federation_id = f.federation_id
  WHERE f.active
  GROUP BY f.federation_id
) axis_totals;

-- 9. Interdisciplinarity: active projects with at least two distinct axes
SELECT ROUND(
  100.0 * COUNT(*) FILTER (WHERE axis_count >= 2) / NULLIF(COUNT(*), 0),
  2
) AS interdisciplinary_project_percent
FROM (
  SELECT p.project_id, COUNT(DISTINCT fa.axis_id) AS axis_count
  FROM etos.project p
  LEFT JOIN etos.project_federation pf ON pf.project_id = p.project_id
  LEFT JOIN etos.federation_axis fa ON fa.federation_id = pf.federation_id
  WHERE p.project_status = 'AKTIV'
  GROUP BY p.project_id
) project_axes;

-- 10. Upcoming lectures
SELECT title, city, country_code, event_date
FROM etos.lecture
WHERE event_date >= CURRENT_DATE
ORDER BY event_date;

-- 11. Latest KPI measurements, if operational data is later connected
SELECT DISTINCT ON (metric_code)
  metric_code, metric_name, metric_value, metric_unit, measured_at
FROM etos.kpi_measurement
ORDER BY metric_code, measured_at DESC;
