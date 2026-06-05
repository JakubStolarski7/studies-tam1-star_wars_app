# Star Wars Datapad

Mobilny terminal danych z uniwersum Gwiezdnych Wojen zbudowany we Flutterze. Aplikacja pobiera i procesuje dane z zewnętrznego API (SWAPI), archiwizuje ulubione wpisy offline w lokalnej bazie NoSQL oraz śledzi aktywność użytkownika za pomocą zdarzeń analitycznych.

Projekt został zrealizowany w ramach zaliczenia przedmiotu. Architektura koncentruje się na asynchronicznym przetwarzaniu danych, stabilności i responsywności. 
## Realizacja wymagań zaliczeniowych

Projekt pokrywa 100% wymagań na ocenę bardzo dobrą (5.0). Poniżej zestawienie wdrożonych funkcjonalności:

### Wymagania podstawowe (4.0)
* [x] **Minimum dwa ekrany:** Wdrożono złożoną nawigację obejmującą 9 ekranów (w tym oddzielne widoki list i detali dla 3 różnych kolekcji danych).
* [x] **Dwa zapytania REST:** Pobieranie pełnych list obiektów (`/api/people`, `/api/planets`, `/api/starships`) oraz fetchowanie szczegółów na podstawie UID.
* [x] **Tryb Offline:** Implementacja bazy `Hive`. Ekran "Tajne Archiwa" pozwala na przeglądanie, usuwanie i zarządzanie ulubionymi wpisami bez dostępu do sieci.
* [x] **Stan ładowania:** Pełna obsługa asynchroniczna z użyciem widżetu `FutureBuilder` (systemowe wskaźniki ładowania podczas komunikacji z serwerem).
* [x] **Obsługa błędów:** Przechwytywanie wyjątków (np. brak sieci, błędy CORS) z dedykowanymi ekranami błędów i funkcją ręcznego ponowienia zapytania.
* [x] **Interfejs UI (Figma):** Opracowano system projektowy (Design System) z podziałem na kolory kategorii, asymetryczne kształty i niestandardową typografię.
* [x] **System kontroli wersji:** Przejrzysta historia Git z logicznie podzielonymi commitami.

### Wymagania rozszerzone (5.0)
* [x] **Dodatkowe ekrany:** Zrealizowano łącznie 9 w pełni funkcjonalnych widoków.
* [x] **Dwie dodatkowe funkcjonalności:**
  1. Zaawansowany, sekwencyjny `Splash Screen` z obsługą dźwięku i animacjami typografii.
  2. Moduł "Archiwum" z globalnym zarządzaniem stanem ulubionych elementów w bazie.
* [x] **Manualne odświeżanie API:** Implementacja `RefreshIndicator`, pozwalająca użytkownikowi na przeładowanie list poprzez gest "pull-to-refresh".
* [x] **Firebase (2 usługi):** Pełna integracja `firebase_analytics` oraz podpięcie `firebase_crashlytics` z obsługą wyjątków niekrytycznych w konsoli. Inicjalizacja odbywa się bezpośrednio przez opcje platformy.
* [x] **Analityka zdarzeń:** Rejestracja 3 niestandardowych eventów w Firebase:
  * `view_category` (wejście na konkretny ekran zbiorczy),
  * `toggle_favorite` (interakcja z bazą lokalną - dodanie lub usunięcie rekordu),
  * `manual_refresh` (wymuszenie ponownego pobrania danych z serwera SWAPI).

## 🛠 Tech Stack
* **Framework:** Flutter (Dart)
* **HTTP Client:** Pakiet `http` (przetwarzanie i mapowanie JSON z endpointów).
* **Local Storage:** `hive_flutter` (szybka lokalna baza klucz-wartość).
* **Backend (BaaS):** Firebase (Core, Analytics, Crashlytics).
* **API:** [The Star Wars API (SWAPI)](https://swapi.tech/)

## 🚀 Uruchomienie projektu

W celu przetestowania aplikacji (w tym działania analityki) w środowisku deweloperskim, zalecane jest uruchomienie jej bezpośrednio na platformie Web:

```bash
# Pobranie zależności
flutter pub get

# Uruchomienie aplikacji w przeglądarce
flutter run -d chrome
