-- =====================================================
-- ETOS 2.0
-- Migration 035
-- Demo-Daten für Wissensgraph
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
VALUES
(
    'project',
    'PhoenixOffice',
    'ETOS'
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
VALUES
(
    'repository',
    'edition-bildungsmedien',
    'GitHub',
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
VALUES
(
    'concept',
    'Knowledge Graph',
    'ORKG',
    'R123456'
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
VALUES
(
    'university',
    'Leibniz Universität Hannover',
    'LUH',
    jsonb_build_object(
        'website',
        'https://www.uni-hannover.de'
    )
);

COMMIT;
