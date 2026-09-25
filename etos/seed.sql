-- ETOS 2.0 reference seed data.
-- These rows describe public organisations and a proposed reference network;
-- they do not imply partnership, mandate, endorsement, or data exchange.
BEGIN;

INSERT INTO etos.states (country_name, iso_code, capital, region) VALUES
('Deutschland','DE','Berlin','Europa'),
('Japan','JP','Tokio','Asien'),
('Vereinigte Staaten','US','Washington, D.C.','Nordamerika'),
('Norwegen','NO','Oslo','Europa'),
('Luxemburg','LU','Luxemburg','Europa'),
('Belgien','BE','Brüssel','Europa'),
('Spanien','ES','Madrid','Europa'),
('Niederlande','NL','Amsterdam','Europa'),
('Dänemark','DK','Kopenhagen','Europa'),
('Schweden','SE','Stockholm','Europa');

INSERT INTO etos.federations (state_id, federation_name, federation_type, headquarters_city, established_year, website, scientific_focus, strategic_role)
SELECT s.state_id, v.name, v.kind, v.city, v.year, v.website, v.focus, v.role
FROM etos.states s
JOIN (VALUES
 ('DE','Leibniz-Gemeinschaft','Forschungsverbund','Berlin',1990,'https://www.leibniz-gemeinschaft.de','Wissenschaft, Bildung und Forschung','Referenzknoten Deutschland'),
 ('JP','Tsukuba Science City','Forschungsstandort','Tsukuba',1963,'https://www.tsukuba.ac.jp','Naturwissenschaften, Technik und Bildung','Referenzknoten Japan'),
 ('US','NASA','Raumfahrtorganisation','Washington, D.C.',1958,'https://www.nasa.gov','Raumfahrt, Erdbeobachtung und Wissenschaft','Referenzknoten USA'),
 ('NO','SINTEF','Forschungsinstitut','Trondheim',1950,'https://www.sintef.no','Technologie, Energie und Nachhaltigkeit','Referenzknoten Norwegen'),
 ('LU','LIST','Forschungsinstitut','Esch-sur-Alzette',2015,'https://www.list.lu','Materialien, Umwelt und Digitalisierung','Referenzknoten Luxemburg'),
 ('BE','imec','Technologie-Forschungszentrum','Leuven',1984,'https://www.imec-int.com','Mikroelektronik und digitale Technologien','Referenzknoten Belgien'),
 ('ES','CSIC','Nationaler Forschungsrat','Madrid',1939,'https://www.csic.es','Naturwissenschaften, Technik und Gesellschaft','Referenzknoten Spanien'),
 ('NL','TNO','Forschungsorganisation','Den Haag',1932,'https://www.tno.nl','Angewandte Forschung und Innovation','Referenzknoten Niederlande'),
 ('DK','DTU','Technische Universität','Kongens Lyngby',1829,'https://www.dtu.dk','Ingenieurwesen, Technik und Nachhaltigkeit','Referenzknoten Dänemark'),
 ('SE','KTH','Technische Universität','Stockholm',1827,'https://www.kth.se','Technik, Architektur und Digitalisierung','Referenzknoten Schweden')
) AS v(iso,name,kind,city,year,website,focus,role) ON s.iso_code = v.iso;

INSERT INTO etos.council_seats (federation_id, seat_name)
SELECT federation_id, federation_name || ' – Referenzsitz' FROM etos.federations;

INSERT INTO etos.research_axes (axis_code, axis_name, description) VALUES
('AI','Künstliche Intelligenz','Methoden, Modelle und verantwortungsvolle Anwendungen künstlicher Intelligenz.'),
('ROBOTICS','Robotik','Robotische Systeme, Assistenz und sichere Automatisierung.'),
('SPACE','Raumfahrt','Raumfahrt, Erdbeobachtung und wissenschaftliche Missionen.'),
('PHOTONICS','Photonik','Lichtbasierte Technologien und optische Informationsverarbeitung.'),
('METROLOGY','Messtechnik','Messmethoden, Standards und wissenschaftliche Instrumentierung.'),
('EDUCATION','Bildung','Lernsysteme, Wissensvermittlung und Bildungsinnovation.'),
('KNOWLEDGE','Wissenssysteme','Wissensorganisation, Datenmodelle und wissenschaftliche Kommunikation.'),
('SUSTAINABILITY','Nachhaltigkeit','Ressourceneffizienz, Klima, Energie und resiliente Systeme.'),
('HEALTH','Gesundheit','Gesundheitsforschung, Prävention und Medizintechnik.'),
('DATA','Datenwissenschaft','Datenanalyse, Statistik, Visualisierung und Reproduzierbarkeit.');

INSERT INTO etos.projects (project_code, title, description, status, start_date, target_date) VALUES
('ETOS-REF-001','Civic Knowledge Graph','Konzeption eines offenen Wissensmodells für wissenschaftliche Publikationen und Bildungsinhalte.','KONZEPT','2026-04-01','2027-03-31'),
('ETOS-REF-002','Responsible Research Dashboard','Referenzdashboard für transparente Forschungs- und Publikationskennzahlen.','PLANUNG','2026-06-01','2027-05-31'),
('ETOS-REF-003','Photonics and Metrology Study','Literatur- und Datenstudie zu Photonik und Messtechnik.','AKTIV','2026-01-15','2026-12-31'),
('ETOS-REF-004','Learning Systems Observatory','Konzept für Bildungs- und Wissenssysteme mit überprüfbaren Indikatoren.','AKTIV','2026-02-01','2027-01-31');

INSERT INTO etos.project_federations (project_id, federation_id, role_name)
SELECT p.project_id, f.federation_id, x.role_name
FROM (VALUES
 ('ETOS-REF-001','Leibniz-Gemeinschaft','Referenzknoten'),
 ('ETOS-REF-001','CSIC','Fachlicher Vergleich'),
 ('ETOS-REF-002','TNO','Methodische Referenz'),
 ('ETOS-REF-002','KTH','Technische Referenz'),
 ('ETOS-REF-003','imec','Technologie-Referenz'),
 ('ETOS-REF-003','SINTEF','Anwendungs-Referenz'),
 ('ETOS-REF-004','Tsukuba Science City','Bildungs-Referenz'),
 ('ETOS-REF-004','DTU','Forschungs-Referenz')
) x(project_code, federation_name, role_name)
JOIN etos.projects p ON p.project_code = x.project_code
JOIN etos.federations f ON f.federation_name = x.federation_name;

INSERT INTO etos.project_axes (project_id, axis_id)
SELECT p.project_id, a.axis_id FROM (VALUES
 ('ETOS-REF-001','KNOWLEDGE'), ('ETOS-REF-001','DATA'),
 ('ETOS-REF-002','DATA'), ('ETOS-REF-002','AI'),
 ('ETOS-REF-003','PHOTONICS'), ('ETOS-REF-003','METROLOGY'),
 ('ETOS-REF-004','EDUCATION'), ('ETOS-REF-004','KNOWLEDGE')
) x(project_code, axis_code)
JOIN etos.projects p ON p.project_code = x.project_code
JOIN etos.research_axes a ON a.axis_code = x.axis_code;

INSERT INTO etos.publications (project_id, title, publication_type, publication_status, publication_date) VALUES
((SELECT project_id FROM etos.projects WHERE project_code='ETOS-REF-003'),'Photonics and Metrology: A Reference Study','BERICHT','REVIEW',NULL),
((SELECT project_id FROM etos.projects WHERE project_code='ETOS-REF-001'),'Knowledge Graphs for Scientific Communication','PAPER','ENTWURF',NULL),
(NULL,'Der Urknall','BUCH','VEROEFFENTLICHT','2026-01-15'),
(NULL,'Dynamicum Specimen','BUCH','VEROEFFENTLICHT','2026-02-15');

INSERT INTO etos.lectures (project_id, title, city, country, event_date, delivery_mode) VALUES
((SELECT project_id FROM etos.projects WHERE project_code='ETOS-REF-003'),'Photonics and Measurement Systems','Leuven','Belgien','2026-09-15','HYBRID'),
((SELECT project_id FROM etos.projects WHERE project_code='ETOS-REF-004'),'Learning Systems and Knowledge Architecture','Bochum','Deutschland','2026-10-08','ONLINE'),
((SELECT project_id FROM etos.projects WHERE project_code='ETOS-REF-001'),'Open Scientific Knowledge Models','Tsukuba','Japan','2026-11-12','HYBRID');

INSERT INTO etos.funding_programs (project_id, title, sponsor, amount_eur, funding_status) VALUES
((SELECT project_id FROM etos.projects WHERE project_code='ETOS-REF-003'),'Interne Forschungsplanung 2026','Beispielbudget – nicht zugesagt',25000,'PLANUNG'),
((SELECT project_id FROM etos.projects WHERE project_code='ETOS-REF-004'),'Bildungsmedien-Entwicklung','Beispielbudget – nicht zugesagt',18000,'PLANUNG');

INSERT INTO etos.metric_definitions (metric_code, metric_name, unit, description) VALUES
('INNOVATION_INDEX','Innovationsindex','index','Intern definierte, später zu validierende Kennzahl.'),
('NETWORK_COHERENCE','Netzwerkkohärenz','percent','Anteil dokumentierter Schnittstellen zwischen Projekten und Achsen.'),
('INTERDISCIPLINARITY','Interdisziplinaritätsgrad','percent','Anteil von Projekten mit mindestens zwei Forschungsachsen.');

COMMIT;
