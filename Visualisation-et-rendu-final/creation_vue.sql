-- Vue qui donne les détails sur les prix

CREATE VIEW prix_detail AS
SELECT s.id_station, s.localisation, s.adresse, c.id_carburant, c.nom_carburant, p.prix, p.id_prix, p.date_maj
FROM station s JOIN prix p USING(id_station) JOIN carburant c USING(id_carburant);

-- Vue qui donne des détails sur les ruptures

CREATE VIEW rupture_detail AS
SELECT s.id_station, s.localisation, s.adresse, c.id_carburant, c.nom_carburant, r.id_rupture, r.date_debut, r.date_fin
FROM station s LEFT JOIN rupture r USING(id_station) LEFT JOIN carburant c USING(id_carburant);

-- Vue qui suit l'évolution des prix moyens des carburants

 CREATE VIEW evolution_prix AS ( SELECT    c.nom_carburant,
    p.date_maj,c.id_carburant,                                                                                      
    AVG(p.prix) AS prix_moyen
FROM prix p
JOIN carburant c USING (id_carburant)
GROUP BY c.nom_carburant, p.date_maj,c.id_carburant
ORDER BY c.nom_carburant, p.date_maj
);

-- Vue qui donne pour chaque carburant, les stations où il est le moins cher
CREATE VIEW stations_avantageux AS (SELECT p.*
FROM prix_detail p
JOIN (
    SELECT id_carburant, MIN(prix) AS prix_min
    FROM prix_detail
    GROUP BY id_carburant
) m
ON p.id_carburant = m.id_carburant
AND p.prix = m.prix_min
ORDER BY p.nom_carburant);
-- Introduire longitude et latitude dans stations

ALTER TABLE station ADD COLUMN latitude NUMERIC, ADD cOLUMN longitude NUMERIC;
UPDATE station SET latitude= split_part(import_carburants.geom,',',1):: NUMERIC, longitude = TRIM(split_part(import_carburants.geom,',',2)):: NUMERIC FROM import_carburants WHERE station.id_station = import_carburants.id;

-- Recursion comparaison prix du Gazole

WITH PrixMoyenCarburant AS (
    -- 1. On calcule d'abord la moyenne nationale pour situer le contexte
    SELECT AVG(prix) AS moyenne_nationale
    FROM prix_detail
    WHERE nom_carburant='Gazole'
)
-- 2. On sélectionne et compare les stations
SELECT 
    s.id_station,
    s.localisation,
    p.prix AS prix_station,
    ROUND(p.prix - pm.moyenne_nationale, 3) AS ecart_a_la_moyenne,
    -- Optionnel : calcul du pourcentage d'économie pour l'entreprise
    ROUND(((pm.moyenne_nationale - p.prix) / pm.moyenne_nationale) * 100, 1) AS pourcentage_economie
FROM 
    Station s
JOIN 
    prix_detail p ON s.id_station = p.id_station
CROSS JOIN 
    PrixMoyenCarburant pm
WHERE 
    p.nom_carburant = 'Gazole'
ORDER BY 
    p.prix ASC
LIMIT 20; -- On extrait le Top 20 des stations les moins chères
