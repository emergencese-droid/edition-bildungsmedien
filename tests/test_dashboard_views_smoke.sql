-- Run after the core schema, reference seed, 020 extension migration,
-- and dashboard view files have been applied.
\set ON_ERROR_STOP on

DO $$
BEGIN
  ASSERT to_regclass('etos.module') IS NOT NULL, 'etos.module is missing';
  ASSERT to_regclass('etos.routing_event') IS NOT NULL, 'etos.routing_event is missing';
  ASSERT to_regclass('etos.document') IS NOT NULL, 'etos.document is missing';
  ASSERT to_regclass('etos.document_version') IS NOT NULL, 'etos.document_version is missing';
  ASSERT to_regclass('etos.phoenixoffice_dashboard') IS NOT NULL, 'etos.phoenixoffice_dashboard is missing';
  ASSERT to_regclass('etos.phoenixoffice_heatmap') IS NOT NULL, 'etos.phoenixoffice_heatmap is missing';
  ASSERT to_regclass('etos.phoenixoffice_document_pipeline') IS NOT NULL, 'etos.phoenixoffice_document_pipeline is missing';
  ASSERT to_regclass('etos.phoenixoffice_document_status_overview') IS NOT NULL, 'etos.phoenixoffice_document_status_overview is missing';
  ASSERT to_regclass('etos.phoenixoffice_research_overview') IS NOT NULL, 'etos.phoenixoffice_research_overview is missing';
END $$;

SELECT * FROM etos.etos_lagebild;
SELECT * FROM etos.phoenixoffice_dashboard;
SELECT * FROM etos.phoenixoffice_research_overview;
SELECT * FROM etos.phoenixoffice_module_matrix;
SELECT * FROM etos.phoenixoffice_document_pipeline;
