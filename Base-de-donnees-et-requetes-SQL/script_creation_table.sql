-- suppression des tables

DROP TABLE IF EXISTS station_service;
DROP TABLE IF EXISTS horaire;
DROP TABLE IF EXISTS service;
DROP TABLE IF EXISTS rupture;
DROP TABLE IF EXISTS prix;
DROP TABLE IF EXISTS carburant;
DROP TABLE IF EXISTS station;

-- script de création de tables 

-- table station 

CREATE TABLE station (
id_station SERIAL PRIMARY KEY,
localisation VARCHAR,
adresse VARCHAR
);

-- table carburant  

CREATE TABLE carburant (
id_carburant SERIAL PRIMARY KEY,
nom_carburant VARCHAR NOT NULL
);

-- table prix 

CREATE TABLE prix (
id_prix SERIAL,
id_station INTEGER NOT NULL REFERENCES station(id_station),
id_carburant INTEGER NOT NULL REFERENCES carburant(id_carburant),
prix NUMERIC,
date_maj VARCHAR,
PRIMARY KEY(id_prix, id_station, id_carburant)
);

-- table rupture

CREATE TABLE rupture (
id_rupture SERIAL,
id_station INTEGER NOT NULL REFERENCES station(id_station),
id_carburant INTEGER NOT NULL REFERENCES carburant(id_carburant),
date_debut VARCHAR,
date_fin VARCHAR,
PRIMARY KEY(id_rupture, id_station, id_carburant)
);

-- table service 

CREATE TABLE service (
id_service SERIAL PRIMARY KEY,
nom_service VARCHAR NOT NULL
);

-- table horaire

CREATE TABLE horaire (
id_horaire SERIAL,
id_station INTEGER NOT NULL REFERENCES station(id_station),
id_service INTEGER NOT NULL REFERENCES service(id_service),
jour VARCHAR,
heure_ouverture TIME,
heure_fermeture TIME,
PRIMARY KEY(id_horaire, id_station, id_service)
);

-- table station service 

CREATE TABLE station_service (
id_station INTEGER NOT NULL REFERENCES station(id_station),
id_service INTEGER NOT NULL REFERENCES service(id_service),
PRIMARY KEY(id_station, id_service)
);

