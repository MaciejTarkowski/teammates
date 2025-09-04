#!/bin/bash

# Klonujemy repozytorium Fluttera

git clone https://github.com/flutter/flutter.git --depth 1 --branch stable

# Dodajemy Fluttera do ścieżki PATH

export PATH="$PATH:`pwd`/flutter/bin"

# Pobieramy potrzebne narzędzia

flutter precache

# Włączamy obsługę web

flutter config --enable-web

# Przechodzimy do folderu z aplikacją

cd teammates

# Budujemy aplikację webową

flutter build web --release
