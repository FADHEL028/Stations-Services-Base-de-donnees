-- Création tables temp
DROP TABLE tmp_carburants;
DROP TABLE tmp_horaire;

CREATE TEMP TABLE tmp_carburants (
    id_station BIGINT,

    code_postal VARCHAR,
    pop VARCHAR,

    adresse VARCHAR,
    ville VARCHAR,

    fermeture VARCHAR,

    geom VARCHAR,

    date_maj_prix TIMESTAMPTZ,

    prix_id INTEGER,
    prix NUMERIC(6,3),

    carburant VARCHAR,

    com_arm_code VARCHAR,
    code_region INTEGER,
    region VARCHAR,

    num_departement VARCHAR,
    departement VARCHAR,

    code_epci BIGINT,
    nom_epci TEXT,

    commune VARCHAR,

    services_proposes TEXT,

    carburant_rupture VARCHAR,
    debut_rupture TIMESTAMPTZ,
    fin_rupture TIMESTAMPTZ,

    automate_24_24 VARCHAR,

    horaires TEXT,
    rupture TEXT
);

CREATE TEMP TABLE tmp_horaire (
    id_station BIGINT,
    jour VARCHAR,
    heure_ouverture TIME,
    heure_fermeture TIME
);
-- Remplissage tables temp
\copy tmp_carburants FROM '/home/kingmft028/prix-carburants-quotidien.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');

\copy tmp_horaire FROM '/home/kingmft028/horaire_import.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');

-- Remplissage station
INSERT INTO station (
    id_station,
    localisation,
    adresse
)
SELECT DISTINCT
    id_station,
    ville,
    adresse
FROM tmp_carburants;

-- Remplissage carburant
INSERT INTO carburant (nom_carburant)
SELECT DISTINCT TRIM(carburant)
FROM tmp_carburants
WHERE carburant IS NOT NULL
  AND carburant <> '';
  
-- Remplissage service

DROP TABLE import_carburants;
CREATE TABLE import_carburants (
    id NUMERIC,
    code_postal VARCHAR,
    pop VARCHAR,
    adresse VARCHAR,
    ville VARCHAR,
    fermeture VARCHAR,
    geom VARCHAR,

    mise_a_jour_prix VARCHAR,
    prix_id NUMERIC,
    prix NUMERIC,

    carburant VARCHAR,

    com_arm_code VARCHAR,

    code_region VARCHAR,
    region VARCHAR,

    numero_departement VARCHAR,
    departement VARCHAR,

    code_epci VARCHAR,
    nom_epci VARCHAR,

    commune VARCHAR,

    services_proposes TEXT,

    carburant_en_rupture VARCHAR,
    debut_rupture VARCHAR,
    fin_rupture VARCHAR,

    automate_24_24 VARCHAR,

    horaires TEXT,
    rupture TEXT
);
COPY import_carburants
FROM '/home/kingmft028/prix-carburants-quotidien.csv'
DELIMITER ';'
CSV HEADER
ENCODING 'UTF8';
INSERT INTO service (nom_service)

SELECT DISTINCT
       TRIM(service_nom)

FROM (
    SELECT
        UNNEST(
            string_to_array(
                services_proposes,
                ','
            )
        ) AS service_nom

    FROM import_carburants
) 

WHERE TRIM(service_nom) <> '';


-- Remplissage prix
INSERT INTO prix (
    id_station,
    id_carburant,
    prix,
    date_maj
)
SELECT
    t.id_station,
    c.id_carburant,
    t.prix,
    t.date_maj_prix
FROM tmp_carburants t
JOIN carburant c
    ON c.nom_carburant = t.carburant;
    
-- Remplissage rupture
INSERT INTO rupture (
    id_station,
    id_carburant,
    date_debut,
    date_fin
)
SELECT
    t.id_station,
    c.id_carburant,
    t.debut_rupture,
    t.fin_rupture
FROM tmp_carburants t
JOIN carburant c
    ON c.nom_carburant = t.carburant_rupture
WHERE t.carburant_rupture IS NOT NULL;

-- Remplissage station_service
INSERT INTO station_service (
    id_station,
    id_service
)
SELECT DISTINCT
       t.id_station,
       s.id_service
FROM tmp_carburants t
CROSS JOIN LATERAL (
    SELECT TRIM(regexp_split_to_table(t.services_proposes, ',')) AS nom_service
) srv
JOIN service s
     ON s.nom_service = srv.nom_service
WHERE t.services_proposes IS NOT NULL
  AND t.services_proposes <> '';

-- Remplissage horaire





INSERT INTO horaire (
    id_station,
    id_service,
    jour,
    heure_ouverture,
    heure_fermeture
)
SELECT
    t.id_station,
    s.id_service,
    t.jour,
    t.heure_ouverture,
    t.heure_fermeture
FROM tmp_horaire t
JOIN station_service s
USING (id_station) ;

