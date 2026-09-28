-- =====================================================
-- ETOS 2.0
-- Migration 036
-- Demo-Beziehungen
-- =====================================================
 
BEGIN;
 
-- -----------------------------------------------------
-- PhoenixOffice -> GitHub Repository
-- -----------------------------------------------------
 
INSERT INTO etos.graph_relation
(
source_node,
target_node,
relation_type,
weight,
confidence
)
SELECT
p.node_id,
g.node_id,
'uses',
1.0,
1.0
FROM etos.graph_node p
JOIN etos.graph_node g
ON g.title = 'edition-bildungsmedien'
WHERE p.title = 'PhoenixOffice';
 
-- -----------------------------------------------------
-- PhoenixOffice -> ORKG
-- -----------------------------------------------------
 
INSERT INTO etos.graph_relation
(
source_node,
target_node,
relation_type,
weight,
confidence
)
SELECT
p.node_id,
o.node_id,
'references',
1.0,
1.0
FROM etos.graph_node p
JOIN etos.graph_node o
ON o.title = 'Knowledge Graph'
WHERE p.title = 'PhoenixOffice';
 
COMMIT;
