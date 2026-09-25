-- Civilian ETOS dashboard queries.
SELECT * FROM etos.dashboard_summary;
SELECT country_code,country_name,organisation_name,headquarters_city,organisation_type FROM etos.federation WHERE active ORDER BY country_name;
SELECT project_code,title,project_status,start_date,target_date FROM etos.project WHERE project_status='AKTIV' ORDER BY target_date NULLS LAST;
SELECT f.organisation_name,COUNT(pf.project_id) AS project_count FROM etos.federation f LEFT JOIN etos.project_federation pf ON pf.federation_id=f.federation_id GROUP BY f.federation_id,f.organisation_name ORDER BY project_count DESC;
SELECT publication_status,publication_type,COUNT(*) AS publication_count FROM etos.publication GROUP BY publication_status,publication_type;
SELECT p.project_code,p.title,COALESCE(SUM(f.amount_eur),0) AS confirmed_funding_eur FROM etos.project p LEFT JOIN etos.funding_program f ON f.project_id=p.project_id AND f.funding_status IN ('BEWILLIGT','AUSGEZAHLT') GROUP BY p.project_id,p.project_code,p.title ORDER BY confirmed_funding_eur DESC;
SELECT ROUND(AVG(axis_count),2) AS avg_axes_per_federation FROM (SELECT f.federation_id,COUNT(fa.axis_id) axis_count FROM etos.federation f LEFT JOIN etos.federation_axis fa ON fa.federation_id=f.federation_id WHERE f.active GROUP BY f.federation_id) x;
SELECT title,city,country_code,event_date FROM etos.lecture WHERE event_date>=CURRENT_DATE ORDER BY event_date;
SELECT DISTINCT ON (metric_code) metric_code,metric_name,metric_value,metric_unit,measured_at FROM etos.kpi_measurement ORDER BY metric_code,measured_at DESC;
