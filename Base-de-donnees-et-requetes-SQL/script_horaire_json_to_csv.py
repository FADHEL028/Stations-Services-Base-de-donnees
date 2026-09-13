import pandas as pd
import json

df = pd.read_csv(
    "prix-carburants-quotidien.csv",
    sep=";"
)

resultats = []

for _, row in df.iterrows():

    if pd.isna(row["horaires"]):
        continue

    try:
        horaires = json.loads(row["horaires"])
    except Exception:
        continue

    id_station = row["id"]

    for jour in horaires.get("jour", []):

        nom_jour = jour.get("@nom")

        if "horaire" not in jour:
            continue

        plages = jour["horaire"]

        # une seule plage horaire
        if isinstance(plages, dict):
            plages = [plages]

        for plage in plages:

            ouverture = plage.get("@ouverture")
            fermeture = plage.get("@fermeture")

            if not ouverture or not fermeture:
                continue

            ouverture = ouverture.replace(".", ":")
            fermeture = fermeture.replace(".", ":")

            resultats.append({
                "id_station": id_station,
                "jour": nom_jour,
                "heure_ouverture": ouverture,
                "heure_fermeture": fermeture
            })

horaire_df = pd.DataFrame(resultats)

print("Horaires extraits :", len(horaire_df))

horaire_df.to_csv(
    "horaire_import.csv",
    sep=";",
    index=False
)

print("Fichier créé : horaire_import.csv")


