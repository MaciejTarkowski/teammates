# TeamMates - Product Requirements Document

## 1. Przegląd produktu

### 1.1 Nazwa produktu
**TeamMates**

### 1.2 Opis produktu
TeamMates to nowoczesna aplikacja webowa i mobilna umożliwiająca organizowanie i dołączanie do wydarzeń sportowych. Platforma łączy osoby zainteresowane wspólną aktywnością sportową w czterech kategoriach: piłka nożna, koszykówka, tenis oraz wyprawy motocyklowe.

### 1.3 Cel biznesowy
Stworzenie centralnej platformy do organizowania lokalnych wydarzeń sportowych, zwiększając aktywność fizyczną społeczności i budując lokalne społeczności sportowe.

### 1.4 Grupa docelowa
- Osoby aktywne fizycznie w wieku 18-65 lat
- Mieszkańcy obszarów miejskich i podmiejskich
- Entuzjaści sportu szukający partnerów do gry
- Organizatorzy wydarzeń sportowych

## 2. Architektura techniczna

### 2.1 Stack technologiczny
- **Frontend:** Flutter
- **Deployment:** Vercel
- **Backend:** Supabase
- **Design:** Nowoczesna minimalistyczna aplikacja. 

### 2.2 Wymagania SEO
- Schema markup dla każdego wydarzenia
- Dynamiczne generowanie sitemap
- Optymalizacja meta tagów
- Robots.txt
- Strukturalne dane JSON-LD

## 3. Funkcjonalności

### 3.1 Zarządzanie wydarzeniami

#### 3.1.1 Tworzenie wydarzenia
**Jako** użytkownik  
**Chcę** utworzyć wydarzenie sportowe  
**Aby** zorganizować spotkanie z innymi entuzjastami sportu  

**Kryteria akceptacji:**
- Wybór jednej z 4 kategorii: piłka nożna, koszykówka, tenis, wyprawa motocyklowa
- Formularz zawierający:
  - Nazwę wydarzenia (max 100 znaków)
  - Opis (max 500 znaków)
  - Lokalizację (integracja z darmowym rozwiązaniem map)
  - Datę i godzinę
  - Maksymalną liczbę uczestników (1-50)
  - Opcję wydarzenia cyklicznego (co tydzień, co miesiąc, niestandardowe)
- Walidacja wszystkich pól
- Automatyczna moderacja treści (filtrowanie wulgaryzmów i nieodpowiednich treści)
- Automatyczne generowanie unikalnego URL dla wydarzenia

#### 3.1.2 Wyszukiwanie wydarzeń
**Jako** użytkownik  
**Chcę** znaleźć wydarzenia w mojej okolicy  
**Aby** dołączyć do interesującej mnie aktywności  

**Kryteria akceptacji:**
- Filtrowanie po typie wydarzenia
- Wyszukiwanie w określonym promieniu od lokalizacji użytkownika
- Sortowanie po: dacie, odległości, liczbie wolnych miejsc
- Mapa z pinami wydarzeń
- Lista wyników z podstawowymi informacjami

#### 3.1.3 Szczegóły i zapisywanie się
**Jako** użytkownik  
**Chcę** zobaczyć szczegóły wydarzenia i się na nie zapisać  
**Aby** uczestniczyć w wydarzeniu  

**Kryteria akceptacji:**
- Pełne informacje o wydarzeniu
- Lista zapisanych uczestników
- Przycisk zapisywania się (jeśli są wolne miejsca)
- Możliwość wypisania się
- Informacja o organizatorze
**Jako** użytkownik  
**Chcę** utworzyć wydarzenia powtarzające się regularnie  
**Aby** nie musieć tworzyć każdego wydarzenia osobno  

**Kryteria akceptacji:**
- Opcja wyboru częstotliwości: co tydzień, co dwa tygodnie, co miesiąc
- Możliwość określenia daty zakończenia cyklu
- Automatyczne tworzenie kolejnych instancji wydarzenia
- Możliwość anulowania pojedynczej instancji bez wpływu na cały cykl
- Możliwość modyfikacji przyszłych instancji w cyklu

### 3.1.5 Moderacja treści
**Jako** system  
**Chcę** automatycznie moderować treści  
**Aby** zapewnić bezpieczne środowisko dla użytkowników  

**Kryteria akceptacji:**
- Filtrowanie wulgaryzmów i nieodpowiednich słów w tytułach i opisach
- Blokowanie podejrzanych treści (spam, linki zewnętrzne)
- Flagowanie wydarzeń do manualnej weryfikacji przez admina
- Lista zabronionych słów kluczowych
- Możliwość aktualizacji reguł moderacji przez admina
**Jako** użytkownik  
**Chcę** zobaczyć szczegóły wydarzenia i się na nie zapisać  
**Aby** uczestniczyć w wydarzeniu  

**Kryteria akceptacji:**
- Pełne informacje o wydarzeniu
- Lista zapisanych uczestników
- Przycisk zapisywania się (jeśli są wolne miejsca)
- Możliwość wypisania się
- Informacja o organizatorze

### 3.2 System powiadomień

#### 3.2.1 Powiadomienia dla organizatora
**Jako** organizator wydarzenia  
**Chcę** otrzymać powiadomienie o nowych zapisach  
**Aby** być na bieżąco z liczbą uczestników  

**Kryteria akceptacji:**
- Email wysyłany natychmiast po zapisaniu się użytkownika
- Szablon emaila z informacjami o uczestnikach
- Możliwość wyłączenia powiadomień w ustawieniach

#### 3.2.2 Powiadomienia o anulowaniu
**Jako** uczestnik wydarzenia  
**Chcę** otrzymać powiadomienie o anulowaniu  
**Aby** wiedzieć, że wydarzenie nie odbędzie się  

**Kryteria akceptacji:**
- Email wysyłany do wszystkich zapisanych uczestników
- Powód anulowania (opcjonalnie)
- Automatyczne wypisanie z wydarzenia

### 3.3 System reputacji

#### 3.3.1 Ocena uczestnictwa
**Jako** organizator wydarzenia  
**Chcę** oznaczyć, którzy uczestnicy przyszli  
**Aby** prowadzić system reputacji  

**Kryteria akceptacji:**
- Panel dostępny 24h po czasie wydarzenia
- Opcje: pojawił się, nie pojawił się (nieuzasadnione), nie pojawił się (uzasadnione)
- Automatyczne naliczanie punktów:
  - Pojawił się: +1 punkt
  - Nie pojawił się (nieuzasadnione): -1 punkt
  - Nie pojawił się (uzasadnione): 0 punktów
- Minimalny poziom: 1

### 3.4 Kalendarz wydarzeń

#### 3.4.1 Ekran główny z kalendarzem
**Jako** użytkownik  
**Chcę** zobaczyć moje wydarzenia w formie kalendarza  
**Aby** łatwo zarządzać swoim harmonogramem  

**Kryteria akceptacji:**
- Design inspirowany kalendarzem z NBA 2K24
- Przewijalna lista kafelków z numerem dnia
- Wyświetlanie wydarzeń, które organizuję i na które jestem zapisany
- Różne kolory dla różnych typów wydarzeń
- Szybki podgląd szczegółów wydarzenia

### 3.5 System autentykacji

#### 3.5.1 Logowanie użytkowników
**Jako** użytkownik  
**Chcę** zalogować się do aplikacji  
**Aby** korzystać z wszystkich funkcjonalności  

**Kryteria akceptacji:**
- Logowanie przez Google OAuth
- Logowanie przez Facebook
- Logowanie przez email/hasło
- Rejestracja nowego konta
- Reset hasła

### 3.6 Panel administratora

#### 3.6.1 Zarządzanie wydarzeniami
**Jako** administrator  
**Chcę** zarządzać wszystkimi wydarzeniami  
**Aby** moderować platformę  

**Kryteria akceptacji:**
- Lista wszystkich wydarzeń
- Możliwość usunięcia/edycji/anulowania wydarzenia
- Filtrowanie i wyszukiwanie
- Szczegóły organizatora i uczestników

#### 3.6.2 Zarządzanie użytkownikami
**Jako** administrator  
**Chcę** zarządzać użytkownikami  
**Aby** moderować społeczność  

**Kryteria akceptacji:**
- Lista wszystkich użytkowników
- Możliwość blokowania/odblokowywania konta
- Podgląd statystyk użytkownika
- Historia aktywności

#### 3.6.3 Statystyki aplikacji
**Jako** administrator  
**Chcę** widzieć statystyki aplikacji  
**Aby** monitorować rozwój platformy  

**Kryteria akceptacji:**
- Liczba aktywnych wydarzeń
- Liczba zarejestrowanych użytkowników
- Liczba wydarzeń w każdej kategorii
- Wykresy aktywności w czasie
- Najpopularniejsze lokalizacje

## 4. Wymagania niefunkcjonalne

### 4.1 Wydajność
- Czas ładowania strony < 3 sekundy
- Responsywność na urządzeniach mobilnych
- Optymalizacja obrazów
- Lazy loading dla list wydarzeń

### 4.2 Bezpieczeństwo
- Szyfrowanie danych w bazie
- Walidacja danych po stronie serwera
- Ochrona przed atakami CSRF
- Rate limiting dla API

### 4.3 Dostępność
- Zgodność z WCAG 2.1 Level AA
- Wsparcie dla czytników ekranu
- Nawigacja klawiaturą
- Kontrast kolorów zgodny z wytycznymi

### 4.4 SEO
- Server-side rendering (SSR)
- Semantic HTML
- Optymalizacja Core Web Vitals
- Schema.org markup
- Sitemap XML

## 5. Design i UX

### 5.1 Wygląd
- **Motyw:** w palecie kolorów #D91B24 #761F21 #1C1C1C #050505
- **Czcionka:** Serif (Georgia, Times New Roman, serif)
- **Styl:** Nowoczesny, minimalistyczny
- **Komponenty:** Material 3

### 5.2 Responsywność
- Mobile-first approach
- Breakpoints: 320px, 768px, 1024px, 1280px
- Touch-friendly elementy (min 44px)

## 6. Integracje

### 6.1 Mapy
- OpenStreetMap 
- Geolokalizacja użytkownika
- Wyświetlanie wydarzeń w okolicy na liście posortowanej od najbliższych
- Geocoding dla konwersji adresów na współrzędne

### 6.2 Email
- Supabase Email dla powiadomień
- Szablony HTML dla różnych typów emaili
- Obsługa odbijanych emaili

### 6.3 Społecznościowe
- Google OAuth 2.0
- Facebook Login
- Open Graph meta tags
- Google Analytics 4 dla analizy ruchu
- Własny dashboard w panelu admina
- Tracking kluczowych metryk (konwersje, retention)
- Anonimowe dane o użytkowaniu aplikacji

### 6.5 Moderacja treści
- Biblioteka do filtrowania wulgaryzmów
- Regex patterns dla wykrywania spamu
- API do wykrywania nieodpowiednich treści
- System punktowy dla podejrzanych treści
- Google OAuth 2.0
- Facebook Login
- Open Graph meta tags

## 7. Zarządzanie danymi

### 7.1 Backup
- Automatyczne backup codziennie
- Przechowywanie przez 30 dni
- Możliwość przywracania

### 7.2 GDPR
- Zgodność z RODO
- Możliwość usunięcia danych
- Eksport danych użytkownika
- Polityka prywatności

## 8. Testowanie

### 8.1 Testy jednostkowe
- Pokrycie kodu > 80%
- Testy komponentów Astro
- Testy funkcji utility

### 8.2 Testy integracyjne
- Testy API endpoints
- Testy przepływów użytkownika
- Testy autentykacji

### 8.3 Testy E2E
- Tworzenie i wyszukiwanie wydarzeń
- Proces rejestracji i logowania
- Zarządzanie profilem użytkownika

## 9. Deployment i monitoring

### 9.1 CI/CD
- GitHub Actions
- Automatyczne testy przed deploy
- Preview deployments dla PR

### 9.2 Monitoring
- Vercel Analytics
- Error tracking
- Performance monitoring
- Uptime monitoring

## 10. Roadmap

### 10.1 Faza 1 (MVP)
- Podstawowe funkcjonalności wydarzeń
- System autentykacji
- Wyszukiwanie i filtrowanie
- Automatyczna moderacja treści

### 10.2 Faza 2
- Panel administratora
- System powiadomień
- Kalendarz wydarzeń
- Wydarzenia cykliczne

### 10.3 Faza 3
- System reputacji
- Zaawansowane statystyki
- Optymalizacje SEO
- Własny dashboard analityki

### 10.4 Przyszłość
- Powiadomienia push
- Chat między uczestnikami
- Integracja z kalendarzami zewnętrznymi