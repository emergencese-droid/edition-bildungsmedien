-- =====================================================
-- ETOS 2.0
-- Migration 036
-- Demo-Beziehungen
-- =====================================================
 
BEGIN;
 
INSERT INTO etos.graph_relation
(
source_node,
target_node,
relation_type
)
SELECT
p.node_id,
g.node_id,
'uses'
FROM etos.graph_node p
JOIN etos.graph_node g
ON g.title = 'edition-bildungsmedien'
WHERE p.title = 'PhoenixOffice';
 
INSERT INTO etos.graph_relation
(
source_node,
target_node,
relation_type
)
SELECT
p.node_id,
o.node_id,
'references'
FROM etos.graph_node p
JOIN etos.graph_node o
ON o.title = 'Knowledge Graph'
WHERE p.title = 'PhoenixOffice';
 
COMMIT;
