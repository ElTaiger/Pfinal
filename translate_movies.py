import json
import time
from deep_translator import GoogleTranslator

# Titles mapping
titles_map = {
    "El Padrino": {"en": "The Godfather", "fr": "Le Parrain"},
    "Pulp Fiction": {"en": "Pulp Fiction", "fr": "Pulp Fiction"},
    "Inception": {"en": "Inception", "fr": "Inception"},
    "El Viaje de Chihiro": {"en": "Spirited Away", "fr": "Le Voyage de Chihiro"},
    "Cadena Perpetua": {"en": "The Shawshank Redemption", "fr": "Les Évadés"},
    "Parasite": {"en": "Parasite", "fr": "Parasite"},
    "Interstellar": {"en": "Interstellar", "fr": "Interstellar"},
    "The Dark Knight": {"en": "The Dark Knight", "fr": "The Dark Knight: Le Chevalier Noir"},
    "Blade Runner 2049": {"en": "Blade Runner 2049", "fr": "Blade Runner 2049"},
    "Star Wars: Una Nueva Esperanza": {"en": "Star Wars: A New Hope", "fr": "Star Wars : Un nouvel espoir"},
    "Mad Max: Fury Road": {"en": "Mad Max: Fury Road", "fr": "Mad Max: Fury Road"},
    "El Caballero Oscuro: La Leyenda Renace": {"en": "The Dark Knight Rises", "fr": "The Dark Knight Rises"},
    "Michael": {"en": "Michael", "fr": "Michael"},
    "Matrix": {"en": "The Matrix", "fr": "Matrix"},
    "Los Siete Samuráis": {"en": "Seven Samurai", "fr": "Les Sept Samouraïs"},
    "La Lista de Schindler": {"en": "Schindler's List", "fr": "La Liste de Schindler"},
    "Apocalypse Now": {"en": "Apocalypse Now", "fr": "Apocalypse Now"},
    "Forrest Gump": {"en": "Forrest Gump", "fr": "Forrest Gump"},
    "Gladiator": {"en": "Gladiator", "fr": "Gladiator"},
    "El Señor de los Anillos: La Comunidad del Anillo": {"en": "The Lord of the Rings: The Fellowship of the Ring", "fr": "Le Seigneur des Anneaux : La Communauté de l'Anneau"},
    "El Señor de los Anillos: Las Dos Torres": {"en": "The Lord of the Rings: The Two Towers", "fr": "Le Seigneur des Anneaux : Les Deux Tours"},
    "El Señor de los Anillos: El Retorno del Rey": {"en": "The Lord of the Rings: The Return of the King", "fr": "Le Seigneur des Anneaux : Le Retour du Roi"},
    "Fight Club": {"en": "Fight Club", "fr": "Fight Club"},
    "Goodfellas": {"en": "Goodfellas", "fr": "Les Affranchis"},
    "Proyecto Salvación": {"en": "Project Hail Mary", "fr": "Projet Dernière Chance"},
    "El Silencio de los Corderos": {"en": "The Silence of the Lambs", "fr": "Le Silence des Agneaux"},
    "Salvar al Soldado Ryan": {"en": "Saving Private Ryan", "fr": "Il faut sauver le soldat Ryan"},
    "La Vida es Bella": {"en": "Life Is Beautiful", "fr": "La vie est belle"},
    "La Milla Verde": {"en": "The Green Mile", "fr": "La Ligne verte"},
    "El Resplandor": {"en": "The Shining", "fr": "Shining"},
    "Whiplash": {"en": "Whiplash", "fr": "Whiplash"},
    "Super Mario Galaxy La Película": {"en": "Super Mario Galaxy The Movie", "fr": "Super Mario Galaxy Le Film"},
    "Spider-Man: Cruzando el Multiverso": {"en": "Spider-Man: Across the Spider-Verse", "fr": "Spider-Man : Seul contre tous"},
    "Ciudad de Dios": {"en": "City of God", "fr": "La Cité de Dieu"},
    "El Pianista": {"en": "The Pianist", "fr": "Le Pianiste"},
    "Infiltrados": {"en": "The Departed", "fr": "Les Infiltrés"},
    "Memento": {"en": "Memento", "fr": "Memento"},
    "Alien: El Octavo Pasajero": {"en": "Alien", "fr": "Alien, le huitième passager"},
    "El Rey León": {"en": "The Lion King", "fr": "Le Roi Lion"},
    "Toy Story": {"en": "Toy Story", "fr": "Toy Story"},
    "WALL·E": {"en": "WALL·E", "fr": "WALL-E"},
    "Up": {"en": "Up", "fr": "Là-haut"},
    "Coco": {"en": "Coco", "fr": "Coco"},
    "La Naranja Mecánica": {"en": "A Clockwork Orange", "fr": "Orange Mécanique"},
    "2001: Una Odisea del Espacio": {"en": "2001: A Space Odyssey", "fr": "2001, l'Odyssée de l'espace"},
    "Tiburón": {"en": "Jaws", "fr": "Les Dents de la mer"},
    "En busca del arca perdida": {"en": "Raiders of the Lost Ark", "fr": "Les Aventuriers de l'arche perdue"},
    "Regreso al Futuro": {"en": "Back to the Future", "fr": "Retour vers le futur"},
    "Jurassic Park": {"en": "Jurassic Park", "fr": "Jurassic Park"},
    "Terminator 2: El Juicio Final": {"en": "Terminator 2: Judgment Day", "fr": "Terminator 2 : Le Jugement dernier"},
    "No es país para viejos": {"en": "No Country for Old Men", "fr": "No Country for Old Men"},
    "Everything Everywhere All At Once": {"en": "Everything Everywhere All At Once", "fr": "Everything Everywhere All at Once"},
    "Dune: Parte Dos": {"en": "Dune: Part Two", "fr": "Dune : Deuxième Partie"},
    "Oppenheimer": {"en": "Oppenheimer", "fr": "Oppenheimer"},
    "Barbie": {"en": "Barbie", "fr": "Barbie"},
    "Heat": {"en": "Heat", "fr": "Heat"},
    "E.T. el Extraterrestre": {"en": "E.T. the Extra-Terrestrial", "fr": "E.T., l'extra-terrestre"},
    "Blade Runner": {"en": "Blade Runner", "fr": "Blade Runner"},
    "Psicosis": {"en": "Psycho", "fr": "Psychose"},
    "La La Land": {"en": "La La Land", "fr": "La La Land"}
}

def translate_text(text, target):
    try:
        return GoogleTranslator(source='es', target=target).translate(text)
    except Exception as e:
        print(f"Failed to translate: {e}")
        return text

with open("Data/peliculas.json", "r") as f:
    data = json.load(f)

for idx, m in enumerate(data):
    title_es = m["titulo"]
    if isinstance(title_es, dict):
        title_es = title_es.get("es", "")
    else:
        m["titulo"] = {"es": title_es}
    
    if title_es in titles_map:
        m["titulo"]["en"] = titles_map[title_es]["en"]
        m["titulo"]["fr"] = titles_map[title_es]["fr"]
    else:
        m["titulo"]["en"] = title_es
        m["titulo"]["fr"] = title_es
        
    syn_es = m["sinopsis"]
    if isinstance(syn_es, dict):
        syn_es = syn_es.get("es", "")
    else:
        m["sinopsis"] = {"es": syn_es}
        
    if "en" not in m["sinopsis"]:
        m["sinopsis"]["en"] = translate_text(syn_es, "en")
    if "fr" not in m["sinopsis"]:
        m["sinopsis"]["fr"] = translate_text(syn_es, "fr")
        
    print(f"Translated {idx+1}/{len(data)}: {title_es}")

with open("Data/peliculas.json", "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4, ensure_ascii=False)

print("Done")
