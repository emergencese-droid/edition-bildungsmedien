-- ETOS 2.0 dashboard queries
-- Run after schema.sql and seed.sql.

-- 1. Overview KPIs
SELECT * FROM etos.dashboard_summary;

-- 2. Ten-state federation matrix
SELECT s.country_name, s.iso_code, f.federation_name, f.federation_type,
       f.headquarters_city, f.website
FROM etos.states s
JOIN etos.federations f ON f.state_id = s.state_id
WHERE s.active AND f.active
ORDER BY s.country_name;

-- 3. Active projects
SELECT p.project_code, p.title, p.status, p.start_date, p.target_date,
       count(pf.federation_id) AS participating_federations
FROM etos.projects p
LEFT JOIN etos.project_federations pf ON pf.project_id = p.project_id
WHERE p.status = 'AKTIV'
GROUP BY p.project_id
ORDER BY p.start_date;

-- 4. Projects by federation
SELECT f.federation_name, s.country_name,
       count(pf.project_id) AS project_count,
       count(*) FILTER (WHERE p.status = 'AKTIV') AS active_project_count
FROM etos.federations f
JOIN etos.states s ON s.state_id = f.state_id
LEFT JOIN etos.project_federations pf ON pf.federation_id = f.federation_id
LEFT JOIN etos.projects p ON p.project_id = pf.project_id
GROUP BY f.federation_id, s.country_name
ORDER BY active_project_count DESC, project_count DESC, f.federation_name;

-- 5. Research-axis coverage
SELECT a.axis_code, a.axis_name,
       count(DISTINCT pa.project_id) AS project_count,
       count(DISTINCT fa.federation_id) AS federation_count
FROM etos.research_axes a
LEFT JOIN etos.project_axes pa ON pa.axis_id = a.axis_id
LEFT JOIN etos.federation_axes fa ON fa.axis_id = a.axis_id
GROUP BY a.axis_id
ORDER BY project_count DESC, a.axis_name;

-- 6. Published publications by year
SELECT COALESCE(EXTRACT(YEAR FROM publication_date)::INTEGER, 0) AS publication_year,
       count(*) AS publication_count
FROM etos.publications
WHERE publication_status = 'VEROEFFENTLICHT'
GROUP BY publication_year
ORDER BY publication_year;

-- 7. Lecture programme by year
SELECT EXTRACT(YEAR FROM event_date)::INTEGER AS event_year,
       count(*) AS lecture_count
FROM etos.lectures
GROUP BY event_year
ORDER BY event_year;

-- 8. Awarded/planned funding
SELECT funding_status, count(*) AS programmes,
       COALESCE(sum(amount_eur), 0) AS amount_eur
FROM etos.funding_programs
GROUP BY funding_status
ORDER BY funding_status;

-- 9. Latest metric measurements
SELECT m.metric_code, d.metric_name, m.metric_value, d.unit,
       m.recorded_at, m.source_note
FROM etos.metric_measurements m
JOIN etos.metric_definitions d ON d.metric_code = m.metric_code
ORDER BY m.recorded_at DESC
LIMIT 100;

-- 10. Data-quality checks
SELECT 'federations_without_state' AS check_name, count(*) AS failures
FROM etos.federations WHERE state_id IS NULL
UNION ALL
SELECT 'projects_without_axis', count(*)
FROM etos.projects p
WHERE NOT EXISTS (SELECT 1 FROM etos.project_axes pa WHERE pa.project_id = p.project_id)
UNION ALL
SELECT 'invalid_target_dates', count(*)
FROM etos.projects WHERE target_date IS NOT NULL AND start_date IS NOT NULL AND target_date < start_date;

-- 11. Derived network-coherence approximation.
-- Replace with an approved methodology before using it as a real KPI.
WITH project_axis_counts AS (
  SELECT p.project_id, count(pa.axis_id) AS axes
  FROM etos.projects p LEFT JOIN etos.project_axes pa ON pa.project_id = p.project_id
  GROUP BY p.project_id
)
SELECT round(100.0 * count(*) FILTER (WHERE axes >= 2) / NULLIF(count(*), 0), 2) AS interdisciplinarity_percent
FROM project_axis_counts;
