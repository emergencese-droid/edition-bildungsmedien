-- Idempotent ETOS core indexes used by dashboard views.
CREATE INDEX IF NOT EXISTS idx_federation_active ON etos.federation(active);
CREATE INDEX IF NOT EXISTS idx_project_status ON etos.project(project_status);
CREATE INDEX IF NOT EXISTS idx_publication_status ON etos.publication(publication_status);
CREATE INDEX IF NOT EXISTS idx_funding_project ON etos.funding_program(project_id);
CREATE INDEX IF NOT EXISTS idx_federation_axis_federation ON etos.federation_axis(federation_id);
CREATE INDEX IF NOT EXISTS idx_federation_axis_axis ON etos.federation_axis(axis_id);
CREATE INDEX IF NOT EXISTS idx_project_federation_fed ON etos.project_federation(federation_id);
CREATE INDEX IF NOT EXISTS idx_project_federation_project ON etos.project_federation(project_id);
CREATE INDEX IF NOT EXISTS idx_publication_project ON etos.publication(project_id);

CREATE OR REPLACE VIEW etos.phoenixoffice_research_overview AS
WITH axis_projects AS (
  SELECT DISTINCT fa.axis_id, pf.project_id
  FROM etos.federation_axis fa
  JOIN etos.project_federation pf ON pf.federation_id = fa.federation_id
), project_funding AS (
  SELECT project_id, SUM(amount_eur) AS funding_total
  FROM etos.funding_program
  WHERE funding_status IN ('BEWILLIGT','AUSGEZAHLT')
  GROUP BY project_id
), axis_project_totals AS (
  SELECT ap.axis_id,
         COUNT(DISTINCT ap.project_id) AS project_count,
         COUNT(DISTINCT pub.publication_id) AS publication_count,
         COALESCE(SUM(pf.funding_total), 0) AS funding_total_eur
  FROM axis_projects ap
  LEFT JOIN etos.publication pub ON pub.project_id = ap.project_id
  LEFT JOIN project_funding pf ON pf.project_id = ap.project_id
  GROUP BY ap.axis_id
)
SELECT ra.axis_name,
       COALESCE(apt.project_count, 0) AS project_count,
       COALESCE(apt.publication_count, 0) AS publication_count,
       COALESCE(apt.funding_total_eur, 0) AS funding_total_eur
FROM etos.research_axis ra
LEFT JOIN axis_project_totals apt ON apt.axis_id = ra.axis_id
ORDER BY project_count DESC, publication_count DESC, ra.axis_name;
