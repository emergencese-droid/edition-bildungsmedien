-- =====================================================
-- ETOS 2.0
-- Migration 037
-- Leibniz Universität Hannover
-- Forschungsgruppen des ISE
-- =====================================================

BEGIN;

-- -----------------------------------------------------
-- Leibniz Universität Hannover
-- -----------------------------------------------------

INSERT INTO etos.graph_node
(
    node_type,
    title,
    description,
    external_source,
    metadata
)
VALUES
(
    'university',
    'Leibniz Universität Hannover',
    'Leibniz Universität Hannover',
    'LUH',
    jsonb_build_object(
        'website',
        'https://www.uni-hannover.de'
    )
);

-- -----------------------------------------------------
-- System- und Rechnerarchitektur
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
    'research_group',
    'System- und Rechnerarchitektur',
    'LUH-ISE',
    jsonb_build_object(
        'url',
        'https://www.ise.uni-hannover.de/sra',
        'domain',
        'Computer Architecture'
    )
);

-- -----------------------------------------------------
-- Echtzeitsysteme
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
    'research_group',
    'Echtzeitsysteme',
    'LUH-ISE',
    jsonb_build_object(
        'domain',
        'Real-Time Systems'
    )
);

-- -----------------------------------------------------
-- Verlässliche und skalierbare Softwaresysteme
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
    'research_group',
    'Verlässliche und skalierbare Softwaresysteme',
    'LUH-ISE',
    jsonb_build_object(
        'domain',
        'Reliable and Scalable Software Systems'
    )
);

-- -----------------------------------------------------
-- Didaktik der Elektrotechnik und Informatik
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
    'research_group',
    'Didaktik der Elektrotechnik und Informatik',
    'LUH-ISE',
    jsonb_build_object(
        'url',
        'https://www.ise.uni-hannover.de/fachgebiet-didaktik-der-elektrotechnik-und-informatik',
        'domain',
        'Engineering Education'
    )
);

-- -----------------------------------------------------
-- Beziehungen Universität -> Fachgebiete
-- -----------------------------------------------------

INSERT INTO etos.graph_relation
(
    source_node,
    target_node,
    relation_type
)
SELECT
    uni.node_id,
    grp.node_id,
    'contains'
FROM etos.graph_node uni
CROSS JOIN etos.graph_node grp
WHERE uni.title = 'Leibniz Universität Hannover'
AND grp.title IN (
    'System- und Rechnerarchitektur',
    'Echtzeitsysteme',
    'Verlässliche und skalierbare Softwaresysteme',
    'Didaktik der Elektrotechnik und Informatik'
);

COMMIT;
