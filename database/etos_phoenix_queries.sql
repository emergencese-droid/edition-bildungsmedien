-- Additional PhoenixOffice/PhoenixWrite dashboard queries.

-- Routing volume by source and target module.
SELECT
  source.module_name AS source_module,
  target.module_name AS target_module,
  COUNT(*) AS routing_events,
  ROUND(AVG(re.score), 4) AS average_score
FROM etos.routing_event re
JOIN etos.module source ON source.module_id = re.source_module_id
JOIN etos.module target ON target.module_id = re.target_module_id
WHERE re.occurred_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY source.module_name, target.module_name
ORDER BY routing_events DESC;

-- Document pipeline by type and status.
SELECT document_type, document_status, COUNT(*) AS document_count
FROM etos.document
GROUP BY document_type, document_status
ORDER BY document_type, document_status;

-- Latest document version per document.
SELECT DISTINCT ON (d.document_id)
  d.document_code, d.title, d.document_status,
  dv.version_number, dv.created_at AS version_created_at
FROM etos.document d
JOIN etos.document_version dv ON dv.document_id = d.document_id
ORDER BY d.document_id, dv.version_number DESC;

-- Module activity in the routing matrix.
SELECT m.module_code, m.module_name,
  COUNT(re.event_id) FILTER (WHERE re.source_module_id = m.module_id) AS events_sent,
  COUNT(re.event_id) FILTER (WHERE re.target_module_id = m.module_id) AS events_received
FROM etos.module m
LEFT JOIN etos.routing_event re
  ON re.source_module_id = m.module_id OR re.target_module_id = m.module_id
GROUP BY m.module_id, m.module_code, m.module_name
ORDER BY m.module_name;
