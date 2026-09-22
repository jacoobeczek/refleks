# 🎮 REFLEKS — minigierka na iPhone

Gra na refleks: 5 rund, ekran robi się czerwony, po losowym czasie (1,5–4 s) zielony — kto dotknie najszybciej, ten wygrywa. Wynik w milisekundach, rekord zapisuje się na stałe.

## Co jest w tym folderze

```
refleks/
├── web/index.html                  ← wersja HTML — gra od razu w Safari
├── ios/
│   ├── project.yml                 ← definicja projektu Xcode (XcodeGen)
│   └── Sources/
│       ├── RefleksApp.swift        ← punkt startowy aplikacji iOS
│       └── ContentView.swift       ← cała gra (SwiftUI)
├── .github/workflows/build-ipa.yml ← automat: zbuduje .ipa w chmurze Apple
├── .gitignore
└── README.md                       ← ten poradnik
```

---

## Sposób 0 — zagraj od razu (bez żadnego konta)

1. Otwórz `web/index.html` w Safari na iPhonie (albo wejdź na podgląd strony).
2. Safari → ikona **Udostępnij** → **Dodaj do ekranu głównego** — gra będzie wyglądać jak normalna aplikacja.

To najszybsza opcja, ale to nadal strona w Safari, nie prawdziwy `.ipa`.

---

## Sposób 1 — zbuduj prawdziwy plik `.ipa`

Plik `.ipa` da się zbudować tylko na Macu (Xcode). Nie masz Maca? Wykorzystamy **GitHub Actions** — darmowe komputery Apple w chmurze zbudują go za Ciebie (darmowe konto wystarczy; publiczne repo = nielimitowane minuty).

### Kroki

1. **Konto GitHub** — jeśli nie masz: [github.com](https://github.com) → Sign up (za darmo).

2. **Nowe repozytorium** — po zalogowaniu: `+` → *New repository* → nazwa np. `refleks`, zaznacz **Public**, *Create repository*.

3. **Wgraj pliki** na swój komputer i opublikuj je — najprościej graficznie przez **GitHub Desktop** ([desktop.github.com](https://desktop.github.com)):
   - zainstaluj, zaloguj się kontem GitHub,
   - **File → Add Local Repository** → wskaż folder `refleks` (jeśli proszi o `git init`, kliknij *Create a repository* i ułóż go w tym folderze),
   - wpisz krótki opis, odhacz *Keep this repository private* (ma być Public), **Publish repository**.

   Alternatywnie z wiersza poleceń (wymaga zainstalowanego [git](https://git-scm.com/download/win)):

   ```bash
   cd refleks
   git init
   git add .
   git commit -m "Refleks – minigierka"
   git branch -M main
   git remote add origin https://github.com/USERNAME/refleks.git
   git push -u origin main
   ```

4. **Budowanie startuje samo** — na stronie repozytorium zakładka **Actions** → bieg *Build .ipa* → poczekaj na zielone ✓ (zajmuje zwykle 2–5 minut).

5. **Pobierz `.ipa`** — kliknij zakończony bieg → na samym dole sekcja **Artifacts** → **Refleks-ipa** → pobierz ZIP → w środku jest **`Refleks.ipa`**. (Pobieranie artifactów wymaga zalogowania na GitHubie.)

> Chcesz zmienić grę? Edytuj `ios/Sources/ContentView.swift` (lub `web/index.html`), zrób commit/push — Actions zbuduje nowy `.ipa` automatycznie.

---

## Sposób 2 — zainstaluj `.ipa` na iPhonie z Windowsa (za darmo)

Apple nie pozwala „kliknąć i zainstalować" dowolnego `.ipa` — plik trzeba **podpisać swoim Apple ID**. Na Windowsie robi to za Ciebie narzędzie do sideloadingu. To normalna procedura (tak samo działa Xcode), nie jailbreak.

**Wymagania:** Windows 10/11 · kabel USB do iPhone'a · **darmowe Apple ID** · iPhone z iOS 15 lub nowszym.

### Metoda A — Sideloadly (najprostsza, rekomendowana)

1. **iTunes** — wersja do pobrania ze strony Apple ([apple.com/itunes](https://www.apple.com/itunes/)), **NIE ze Sklepu Microsoft** (to osobna, „sklepowa" wersja i nie działa z tymi narzędziami).
2. **Sideloadly** — pobierz ze oficjalnej strony [sideloadly.io](https://sideloadly.io/) i zainstaluj.
3. Podłącz iPhone kablem USB → na telefonie kliknij **Ufaj** (Trust), gdy zapyta o komputer.
4. Otwórz Sideloadly → **przeciągnij plik `Refleks.ipa`** w okno → wpisz swoje **Apple ID** (i kod dwuskładnikowy, jeśli pyta) → **Start**.
5. Na iPhonie: **Ustawienia → Ogólne → Zarządzanie VPN i urządzeniem** → dotknij profil z Twoim Apple ID → **Zaufaj**.
6. **iOS 16 lub nowszy:** **Ustawienia → Prywatność i bezpieczeństwo → Tryb deweloperski** → Włącz → telefon poprosi o restart.
7. Gotowe — ikona **Refleks** jest na ekranie głównym. 🎉

### Metoda B — AltStore (alternatywa)

[altstore.io](https://altstore.io/) → AltServer na Windowsie (wymaga iTunes **i** iCloud ze strony Apple). Instaluje gry przez Wi-Fi i sama odświeża podpis co tydzień, o ile telefon i komputer są w tej samej sieci.

---

## ⚠️ Limity darmowego Apple ID (uczciwie)

| | Darmowe Apple ID | Płatne ($99/rok) |
|---|---|---|
| Ważność aplikacji | **7 dni** | 1 rok |
| Liczba aplikacji równocześnie | **3** | bez limitu |
| Co tydzień | podłącz iPhone do PC i podpisz ponownie (Sideloadly: wrzuć ten sam `.ipa` i kliknij Start) | nie trzeba |

Po 7 dniach iOS zablokuje otwieranie gry — to normalne, nie zepsułeś niczego. Ponowne podpisanie zajmuje 30 sekund i gra działa dalej (dane/rekordy zostają).

**Bezpieczeństwo:** wpisujesz Apple ID w programie na komputerze. Jeśli wolisz spokój głowy, zrób osobne, zapasowe konto Apple ID używane wyłącznie do podpisywania.

---

## 🔧 Rozwiązywanie problemów

| Objaw | Co zrobić |
|---|---|
| Nie ma zakładki Actions / „Actions is disabled" | Konto bardzo nowe — GitHub czasem prosi o weryfikację poczty/karty. Spróbuj ponownie za kilka minut. |
| Bieg jest czerwony (✗) | Wejdź w bieg → kliknij czerwony krok → skopiuj logi i prześlij mi je, poprawię kod. |
| „Nie można otworzyć Refleks" | Włącz **Tryb deweloperski** (iOS 16+) i **Zaufaj profilowi** — kroki 5–6 wyżej. |
| Aplikacja przestała się otwierać po tygodniu | Wygasł podpis (7 dni) — ponowne podpisanie w Sideloadly. |
| Nie da się zainstalować „z pliku" | Plik `.ipa` instaluje się tylko przez Sideloadly/AltStore — to normalne. |
| Sideloadly nie widzi telefonu | Zmień kabel (musi przesyłać dane), zainstaluj iTunes ze strony Apple, odblokuj telefon i kliknij „Ufaj". |

---

## Jak zmienić grę

- **Teksty / kolory / czas czekania:** `ios/Sources/ContentView.swift` (odpowiednik w HTML: `web/index.html`)
- **Liczba rund:** `totalRounds = 5`
- **Zakres losowania:** `Double.random(in: 1.5...4.0)` — np. `0.8...2.5` dla hardcore'u

Po zmianie: zrób push do GitHuba → Actions zbuduje nowy `.ipa` → zainstaluj ponownie (ta sama nazwa bundle ID nadpisze starą wersję).
