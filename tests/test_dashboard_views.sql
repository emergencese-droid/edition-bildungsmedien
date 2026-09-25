-- Dashboard views used for EXPLAIN and CI smoke tests.
\set ON_ERROR_STOP on

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.etos_lagebild;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.phoenixoffice_dashboard;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.phoenixoffice_research_overview;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.phoenixoffice_module_matrix;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM etos.phoenixoffice_document_pipeline;
