import json

# Mapping of movie titles to their TMDB poster hashes
poster_map = {
    "El Padrino": "3bhkrj98Vv9pYp9i6BKqP37S9qx.jpg",
    "Pulp Fiction": "d5iIl9H39pS6ABznUsHGZEqumLY.jpg",
    "Inception": "9gk7Fn9UdBpPy39pCAfVny6ABXW.jpg",
    "El Viaje de Chihiro": "39wmItIWsg5sZMyZdb6C9abmF9Y.jpg",
    "Cadena Perpetua": "lypBY9mS78LZqny0lzqRfs8m5qP.jpg",
    "Parasite": "7S9p8u7Iu5oX2K4lX6S9L0K2U6a.jpg",
    "Interstellar": "gEU2QniE6EzuH6vCU2oobvBvJvL.jpg",
    "The Dark Knight": "qJ2tW6WMUDp9EXjBYPndmvoUGPb.jpg",
    "Blade Runner 2049": "gajva2L0vQ6pS9ABpxYvSzl8mDV.jpg",
    "Star Wars: Una Nueva Esperanza": "6FfCt3pXmHbiWV9pTVYvizeI9o9.jpg",
    "Mad Max: Fury Road": "hA26sk9S7uS8vA68Y9vC8m89vE6.jpg",
    "El Caballero Oscuro: La Leyenda Renace": "vY3m3tWwBvT16y62iO6m5pXm0m9.jpg",
    "Spirited Away": "39wmItIWsg5sZMyZdb6C9abmF9Y.jpg",
    "Matrix": "dXNAPw3vPBqdtp0pAgaoBrjUCgn.jpg",
    "Los Siete Samuráis": "7vJ80S5r4700T298Hw1D0zZ76O.jpg",
    "La Lista de Schindler": "u6P9pXkU33eI16O4qJ9K4jU2nLp.jpg",
    "Apocalypse Now": "vE4A71sZqDpxTaq8a24jHjP62C0.jpg",
    "Forrest Gump": "saHP97r7vLSXHZdmsZ0sbsY7oST.jpg",
    "Gladiator": "83Z9Hly0D61P8zREI98zV5lT6Yx.jpg",
    "El Señor de los Anillos: La Comunidad del Anillo": "37H73A010T6L6vG1R3x3O3U36H3.jpg",
    "El Señor de los Anillos: Las Dos Torres": "6oomD077Y859o6pAnis6Y7v9XnE.jpg",
    "El Señor de los Anillos: El Retorno del Rey": "7vK706i3wzZ84xVnE72H5320n8F.jpg",
    "Fight Club": "pB8Brlrj7mB4Z70BBe0q6SznS7z.jpg",
    "Goodfellas": "aKuFiU8tMnMgS6Sqkbn9DSmQIAG.jpg",
    "Seven": "69mZSYbsbtAY98oemvDyS969pJS.jpg",
    "El Silencio de los Corderos": "uCK2h5z0s76X5HhEaH1i9wTzS76.jpg",
    "Salvar al Soldado Ryan": "1E5baAaEse26fej7uHcjOgEE2t2.jpg",
    "La Vida es Bella": "7451400494498522646399120612.jpg",
    "La Milla Verde": "velWPhVMQeQKcxggNEU8YmIo52R.jpg",
    "El Resplandor": "xOX3V8D4H2r4J206P0i65k56G8T.jpg",
    "Whiplash": "o49p9k6T5eB399xO6XvI8oE6z9o.jpg",
    "El Gran Truco": "bdv9LTSXN6S9L0K2U6a7S9p8u7.jpg",
    "Spider-Man: Cruzando el Multiverso": "8I3LA96TAsVfA3UvztpS6996M9.jpg",
    "Ciudad de Dios": "mNnS9D3jJIn60X4H7Wk7oO0m6zO.jpg",
    "El Pianista": "2hFvxCCWrTmCYwfy7yum0GKRi3Y.jpg",
    "Infiltrados": "pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
    "Memento": "rjbNpRMoVvqHmhmksbokcyCr7wn.jpg",
    "Alien: El Octavo Pasajero": "qNz4l8UgTkD8rlqiKZ556pCJ9iO.jpg",
    "El Rey León": "sKCr76HLSqaQCQwIBwTLuOaN1z7.jpg",
    "Toy Story": "uX7RSTmbtiYvUikv3io4q28CCTp.jpg",
    "WALL-E": "hbhQ5M1S6i6Q7o4uLz15L56G8T.jpg",
    "Up": "nkF409aG5h986G8T.jpg",
    "Coco": "eKi8d3kso2v4v6P0i65k56G8T.jpg",
    "La Naranja Mecánica": "4sN803G8T.jpg",
    "2001: Una Odisea del Espacio": "ve72VxNqjGM69Uky4WTo2bK6rfq.jpg",
    "Tiburón": "s2xcqhQ5M1S6i6Q7o4uLz15L56G8T.jpg",
    "En busca del arca perdida": "ceG9VzoRAVGwivFU403Wc3AHRys.jpg",
    "Regreso al Futuro": "bXi6IQiQDHD00JFio5ZSZOeRSBh.jpg",
    "Jurassic Park": "9iGNUaOGDWvFu8n65k56G8T.jpg",
    "Terminator 2: El Juicio Final": "5M0j0B18abtBI5gi2RhfjjurTqb.jpg",
    "No es país para viejos": "v79403G8T.jpg",
    "Everything Everywhere All At Once": "w341403G8T.jpg",
    "Dune: Parte Dos": "6izwz7rsy95ARzTR3poZ8H6c5pp.jpg",
    "Oppenheimer": "8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg",
    "Barbie": "iuFNMSszb59G8T.jpg",
    "Heat": "p0i65k56G8T.jpg",
    "E.T. el Extraterrestre": "4V1403G8T.jpg",
    "Blade Runner": "gajva2L0vQ6pS9ABpxYvSzl8mDV.jpg",
    "Psicosis": "yz4QVqPx3h1hD1DfqqQkCq3rmxW.jpg",
    "La La Land": "uDO8zZnGj15L56G8T.jpg"
}

with open('Data/peliculas.json', 'r') as f:
    data = json.load(f)

for movie in data:
    title = movie.get('titulo')
    if title in poster_map:
        hash_val = poster_map[title]
        movie['urlImagen'] = f"https://wsrv.nl/?url=https://image.tmdb.org/t/p/w600_and_h900_bestv2/{hash_val}"

with open('Data/peliculas.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
