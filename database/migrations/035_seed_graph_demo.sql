-- =====================================================
-- ETOS 2.0
-- Migration 035
-- Demo-Daten für Wissensgraph
-- Mit Duplikatschutz
-- =====================================================

BEGIN;

-- -----------------------------------------------------
-- PhoenixOffice
-- -----------------------------------------------------

INSERT INTO etos.graph_node
(
    node_type,
    title,
    external_source
)
SELECT
    'project',
    'PhoenixOffice',
    'ETOS'
WHERE NOT EXISTS (
    SELECT 1
    FROM etos.graph_node
    WHERE title = 'PhoenixOffice'
);

-- -----------------------------------------------------
-- GitHub Repository
-- -----------------------------------------------------

INSERT INTO etos.graph_node
(
    node_type,
    title,
    external_source,
    external_id
)
SELECT
    'repository',
    'edition-bildungsmedien',
    'GitHub',
    'emergencese-droid/edition-bildungsmedien'
WHERE NOT EXISTS (
    SELECT 1
    FROM etos.graph_node
    WHERE external_source = 'GitHub'
      AND external_id =
          'emergencese-droid/edition-bildungsmedien'
);

-- -----------------------------------------------------
-- ORKG
-- -----------------------------------------------------

INSERT INTO etos.graph_node
(
    node_type,
    title,
    external_source,
    external_id
)
SELECT
    'concept',
    'Knowledge Graph',
    'ORKG',
    'R123456'
WHERE NOT EXISTS (
    SELECT 1
    FROM etos.graph_node
    WHERE external_source = 'ORKG'
      AND external_id = 'R123456'
);

-- -----------------------------------------------------
-- Leibniz Universität Hannover
-- -----------------------------------------------------

INSERT INTO etos.graph_node
(
    node_type,
    title,
    external_source,
    metadata
)
SELECT
    'university',
    'Leibniz Universität Hannover',
    'LUH',
    jsonb_build_object(
        'website',
        'https://www.uni-hannover.de'
    )
WHERE NOT EXISTS (
    SELECT 1
    FROM etos.graph_node
    WHERE title =
          'Leibniz Universität Hannover'
);

COMMIT;
