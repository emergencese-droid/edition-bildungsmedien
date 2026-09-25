-- Explain plans for ETOS dashboard views.
-- Run with a populated test database; timing thresholds should be evaluated
-- in CI with representative data, not on an empty fixture database.
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.dashboard_summary;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.etos_lagebild;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.phoenixoffice_research_overview;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.phoenixoffice_dashboard_kpis;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.phoenixoffice_heatmap;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.phoenixoffice_document_pipeline;
