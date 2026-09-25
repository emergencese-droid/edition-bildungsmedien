-- ETOS reference seed data.
-- Public reference nodes and scenario data only; not confirmed partnerships.
INSERT INTO etos.federation
(country_code, country_name, organisation_name, headquarters_city, organisation_type, website, founded_year)
VALUES
('DE','Deutschland','Leibniz-Gemeinschaft','Berlin','Forschungsverbund','https://www.leibniz-gemeinschaft.de/',1990),
('JP','Japan','Tsukuba Science Network','Tsukuba','Forschungsnetzwerk',NULL,NULL),
('US','USA','NASA','Washington','Raumfahrtorganisation','https://www.nasa.gov/',1958),
('NO','Norwegen','SINTEF','Trondheim','Forschungsinstitut','https://www.sintef.no/en/',1950),
('LU','Luxemburg','LIST','Esch-sur-Alzette','Forschungsinstitut','https://www.list.lu/',2015),
('BE','Belgien','imec','Leuven','Technologiezentrum','https://www.imec-int.com/',1984),
('ES','Spanien','CSIC','Madrid','Nationaler Forschungsrat','https://www.csic.es/en',1939),
('NL','Niederlande','TNO','Den Haag','Innovationsorganisation','https://www.tno.nl/en/',1932),
('DK','Dänemark','DTU','Kongens Lyngby','Technische Universität','https://www.dtu.dk/english',1829),
('SE','Schweden','KTH','Stockholm','Technische Universität','https://www.kth.se/en',1827)
ON CONFLICT (country_code) DO NOTHING;

INSERT INTO etos.research_axis (axis_code, axis_name, description)
VALUES
('AI','Künstliche Intelligenz','Maschinelles Lernen, Analyse und verantwortungsvolle KI.'),
('ROBOTICS','Robotik','Autonome, assistive und industrielle Robotik.'),
('SPACE','Raumfahrt','Weltraumforschung, Erdbeobachtung und Raumfahrtsysteme.'),
('PHOTONICS','Photonik','Lichtbasierte Informations- und Sensortechnologien.'),
('METROLOGY','Messtechnik','Messverfahren, Kalibrierung und wissenschaftliche Datengüte.'),
('KNOWLEDGE','Wissenssysteme','Wissensmodelle und Informationsarchitekturen.'),
('EDUCATION','Bildung','Lernsysteme und wissenschaftliche Kommunikation.'),
('SUSTAINABILITY','Nachhaltigkeit','Ressourceneffizienz, Klima und resiliente Infrastruktur.'),
('HEALTH','Gesundheit','Gesundheitsforschung und technologiegestützte Versorgung.'),
('DATA','Datenwissenschaft','Datenqualität, Statistik, Visualisierung und Governance.')
ON CONFLICT (axis_code) DO NOTHING;

INSERT INTO etos.project (project_code, title, project_status, start_date, target_date, description)
VALUES
('ETOS-REF-001','Civilian Research Network Model','KONZEPT','2026-01-15',NULL,'Referenzmodell für ein ziviles internationales Forschungsnetzwerk.'),
('ETOS-REF-002','Knowledge Systems and Education','PLANUNG','2026-04-01','2027-03-31','Konzeption von Wissenssystemen für Wissenschaft und Bildung.'),
('ETOS-REF-003','Photonics and Metrology Exchange','AKTIV','2026-02-01','2026-12-31','Referenzprojekt für Photonik und Messtechnik.'),
('ETOS-REF-004','Sustainable Research Infrastructure','AKTIV','2026-03-15','2027-06-30','Modellierung nachhaltiger Forschungsinfrastrukturen.')
ON CONFLICT (project_code) DO NOTHING;

INSERT INTO etos.publication (title, publication_type, publication_status, publication_date, project_id)
SELECT 'ETOS 2.0 Civilian Network Model','WHITEPAPER','PLANUNG',NULL,project_id FROM etos.project WHERE project_code = 'ETOS-REF-001'
UNION ALL SELECT 'Wissenssysteme und Bildungsarchitektur','FORSCHUNGSBERICHT','REVIEW',NULL,project_id FROM etos.project WHERE project_code = 'ETOS-REF-002'
UNION ALL SELECT 'Grundlagen der Photonik-Messtechnik','ARTIKEL','VEROEFFENTLICHT','2026-05-20',project_id FROM etos.project WHERE project_code = 'ETOS-REF-003';

INSERT INTO etos.lecture (title, city, country_code, event_date, project_id)
SELECT 'Forschungsnetzwerke und Wissenssysteme','Berlin','DE','2026-06-18',project_id FROM etos.project WHERE project_code = 'ETOS-REF-002'
UNION ALL SELECT 'Photonics and Metrology Exchange','Leuven','BE','2026-09-10',project_id FROM etos.project WHERE project_code = 'ETOS-REF-003'
UNION ALL SELECT 'Sustainable Research Infrastructure','Stockholm','SE','2026-11-05',project_id FROM etos.project WHERE project_code = 'ETOS-REF-004';

INSERT INTO etos.funding_program (title, sponsor, amount_eur, funding_status, project_id)
SELECT 'Concept Development Grant','Internal planning allocation',25000,'BEWILLIGT',project_id FROM etos.project WHERE project_code = 'ETOS-REF-001'
UNION ALL SELECT 'Education Systems Pilot','Reference funding scenario',85000,'BEANTRAGT',project_id FROM etos.project WHERE project_code = 'ETOS-REF-002'
UNION ALL SELECT 'Photonics Methods Programme','Reference funding scenario',140000,'BEWILLIGT',project_id FROM etos.project WHERE project_code = 'ETOS-REF-003';

INSERT INTO etos.federation_axis (federation_id, axis_id, relevance)
SELECT f.federation_id, a.axis_id, x.relevance
FROM (VALUES
('DE','KNOWLEDGE',5),('DE','EDUCATION',5),('DE','DATA',4),('JP','ROBOTICS',4),('JP','PHOTONICS',4),('JP','EDUCATION',3),
('US','SPACE',5),('US','AI',4),('US','DATA',4),('NO','SUSTAINABILITY',5),('NO','METROLOGY',4),('NO','DATA',3),
('LU','DATA',4),('LU','SUSTAINABILITY',4),('LU','HEALTH',3),('BE','PHOTONICS',5),('BE','AI',4),('BE','METROLOGY',4),
('ES','HEALTH',4),('ES','AI',4),('ES','SUSTAINABILITY',3),('NL','SUSTAINABILITY',4),('NL','DATA',4),('NL','AI',3),
('DK','HEALTH',4),('DK','ROBOTICS',4),('DK','SUSTAINABILITY',3),('SE','ROBOTICS',4),('SE','SUSTAINABILITY',4),('SE','PHOTONICS',3)
) AS x(country_code, axis_code, relevance)
JOIN etos.federation f ON f.country_code = x.country_code
JOIN etos.research_axis a ON a.axis_code = x.axis_code
ON CONFLICT (federation_id, axis_id) DO NOTHING;

INSERT INTO etos.project_federation (project_id, federation_id, role_name)
SELECT p.project_id, f.federation_id, x.role_name
FROM (VALUES
('ETOS-REF-001','DE','Reference model lead'),('ETOS-REF-001','JP','Network reference node'),('ETOS-REF-001','US','Space research reference'),
('ETOS-REF-002','DE','Education systems reference'),('ETOS-REF-002','DK','Learning technology reference'),('ETOS-REF-003','BE','Photonics methods reference'),
('ETOS-REF-003','JP','Measurement reference'),('ETOS-REF-004','NO','Sustainability reference'),('ETOS-REF-004','SE','Infrastructure reference')
) AS x(project_code, country_code, role_name)
JOIN etos.project p ON p.project_code = x.project_code
JOIN etos.federation f ON f.country_code = x.country_code
ON CONFLICT (project_id, federation_id) DO NOTHING;
