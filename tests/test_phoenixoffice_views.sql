-- Validate the actual PhoenixOffice tables and dashboard views after migrations.
BEGIN;

DO $$
BEGIN
  ASSERT to_regclass('etos.module') IS NOT NULL, 'etos.module is missing';
  ASSERT to_regclass('etos.routing_event') IS NOT NULL, 'etos.routing_event is missing';
  ASSERT to_regclass('etos.document') IS NOT NULL, 'etos.document is missing';
  ASSERT to_regclass('etos.document_version') IS NOT NULL, 'etos.document_version is missing';
  ASSERT to_regclass('etos.phoenixoffice_dashboard') IS NOT NULL, 'dashboard view is missing';
  ASSERT to_regclass('etos.phoenixoffice_heatmap') IS NOT NULL, 'heatmap view is missing';
  ASSERT to_regclass('etos.phoenixoffice_document_pipeline') IS NOT NULL, 'document pipeline view is missing';
  ASSERT to_regclass('etos.phoenixoffice_document_status_overview') IS NOT NULL, 'document status view is missing';
  ASSERT to_regclass('etos.phoenixoffice_research_overview') IS NOT NULL, 'research overview view is missing';
END $$;

SELECT * FROM etos.dashboard_summary;
SELECT * FROM etos.etos_lagebild;
SELECT * FROM etos.phoenixoffice_dashboard;
SELECT * FROM etos.phoenixoffice_research_overview;

ROLLBACK;
