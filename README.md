# Non un altro sciopero!
## Script per Linux e macOS che ti avvisa quando Trenord e ATM vanno in sciopero. 🇮🇹🚉😡

Ho scritto questo script spinto dalla necessità, data l'altissima frequenza degli scioperi dei trasporti pubblici in Lombardia. Nello spirito del software libero, ho voluto condividere la mia soluzione, sperando che possa tornare utile a tanti altri che abitano a Milano o nei dintorni. Invito chiunque abbia le capacità a suggerire miglioramenti per irrobustirlo.

Per installarlo, scaricate la repo e avviate da terminale lo script "install.sh". Partirà l'installazione guidata.
Lo script controlla il contenuto dei siti di Trenord e ATM per vedere se hanno pubblicato avvisi di nuovi scioperi. Ciò avviene ogni ora e quando viene acceso il computer. Se trova un avviso di sciopero, lancerà una notifica di sistema con i dettagli essenziali.

Lo script è basato su Python e Selenium.

I browser attualmente supportati sono:
- Google Chrome
- Firefox
- Microsoft Edge
- Chromium
- Brave
- Vivaldi
- Opera
- Librewolf

Se hai un browser basato su Chromium che non è incluso nella lista, puoi provare a dire allo script che hai Chromium installato.

**NON SONO SUPPORTATI BROWSER BASATI SU WEBKIT COME SAFARI E GNOME WEB**

**NON SONO SUPPORTATI BROWSER INSTALLATI TRAMITE SNAP E FLATPAK. SE USI UBUNTU 22.04 E SUCCESSIVI, FAI ATTENZIONE CON LA VERSIONE DI FIREFOX PREINSTALLATA, CHE É BASATA SU SNAP**


## Testing
Ho testato lo script su Fedora 36. Ho fatto in modo che lo script funzioni allo stesso modo su tutte le distro Linux. Non possiedo un sistema macOS, dunque non ho modo di vedere se funziona là.

## Futuro
I miei prossimi obiettivi sono fare in modo che possa funzionare anche su Windows, probabilmente sfruttando WSL, e vedere se posso aggiungere il supporto a Webkit.
