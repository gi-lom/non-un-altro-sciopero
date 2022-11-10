#!/bin/bash

# Messaggio di benvenuto
echo ""
echo "**************************"
echo "* NON UN ALTRO SCIOPERO! *"
echo "**************************"
echo ""
echo "Script che ti avvisa di nuovi scioperi di Trenord e ATM ogni volta che accendi il tuo sistema Linux."
echo "IMPORTANTE: lo script NON funzionerà con browser installati tramite Flatpak e Snap."
echo ""

USRN=$(id -u -n)
SYSTM="home"
if [ $OSTYPE = 'darwin'* ]; then
    SYSTM="Users"
fi
USRPATH="/$SYSTM/$USRN/.local/share"

# Controllo se è root
if [ "$(id -u)" -eq 0 ]; then
    USRPATH="/usr/share"
    echo "!!! ATTENZIONE !!!"
    echo "Stai eseguendo questo script come root, questo può portare a effetti indesiderati. Scrivi 'ok' per continuare, o qualunque altra cosa per fermare lo script."
    read decision
    if [[ "$decision" != "ok" ]]; then
        exit 1
    fi
fi

# Opzione di disinstallazione
if [ -d "$USRPATH/non-un-altro-sciopero" ]; then
    echo "Lo script è stato installato in precedenza. Premi d per disinstallarlo, qualunque altro tasto per reinstallarlo."
    read sel
    if [ "$sel" = "d" ] || [ "$sel" = "D" ]; then
        echo ""
        echo "Disinstallando lo script in $USRPATH/non-un-altro-sciopero..."
        rm -rf "$USRPATH/non-un-altro-sciopero"
        cr=$(crontab -l)
        a=($cr)
        for ((i = 0; i < ${#a[@]}; i++)); do
            if [[ "${a[i]}" == "$USRPATH/non-un-altro-sciopero/main.py" ]]; then
                eval "crontab" "-l" "|" "grep" "-v" "@reboot" "sleep" "120" "&&" "python" "$USRPATH/non-un-altro-sciopero/main.py" "--browser" "${a[i + 2]}" "--path" "$USRPATH/non-un-altro-sciopero" "--error" "True" "|" "crontab" "-" >/dev/null 2>&1
                eval "crontab" "-l" "|" "grep" "-v" "@hourly" "python" "$USRPATH/non-un-altro-sciopero/main.py" "--browser" "${a[i + 2]}" "--path" "$USRPATH/non-un-altro-sciopero" "|" "crontab" "-" >/dev/null 2>&1
            fi
        done

        echo ""
        echo "Disinstallato!"
        echo ""
        exit 0
    fi
fi

# Controllo se Python è installato
pyt_installed=""
if [[ $(which python) == *"no python in"* ]]; then
    if [[ $(which python3) == *"no python3 in"* ]]; then
        echo "Python non è presente nel tuo sistema. Installalo prima di far girare questo script."
        exit 1
    else
        pyt_installed="pip3"
        if [[ $(which pip) == *"no pip in"* ]]; then
            echo "Pip non è presente nel tuo sistema. Installalo prima di far girare questo script."
            exit 1
        fi
    fi
else
    pyt_installed="pip"
    if [[ $(which pip) == *"no pip in"* ]]; then
        echo "Pip non è presente nel tuo sistema. Installalo prima di far girare questo script."
        exit 1
    fi
fi

# Controllo se il modulo Selenium è installato
python -c "import selenium" >/dev/null 2>&1
if [[ $? == 1 ]]; then
    echo "Installando Selenium..."
    eval "$pyt_installed" "install" "selenium"
    if [[ $? == 1 ]]; then
        echo ""
        echo "Non è stato possibile installare Selenium. Si suggerisce di avvisare il problema sulla repo: github.com/gi-lom/non-un-altro-sciopero"
        exit 1
    fi
fi

# Controllo se il modulo webdriver-manager è installato
python -c "import webdriver_manager" >/dev/null 2>&1
if [[ $? == 1 ]]; then
    echo "Installando Webdriver Manager..."
    eval "$pyt_installed" "install" "webdriver_manager"
    if [[ $? == 1 ]]; then
        echo ""
        echo "Non è stato possibile installare Webdriver Manager. Si suggerisce di avvisare il problema sulla repo: github.com/gi-lom/non-un-altro-sciopero"
        exit 1
    fi
fi

# Chiedo quale browser utilizzare
browser=""
echo "Quale browser usi? 1) Firefox 2) Chrome 3) Chromium 4) Edge 5) Brave 6) Vivaldi 7) Opera 8) Ungoogled Chromium 9) LibreWolf "
while [[ "$browser" == "" ]]; do
    browser_list=()
    read browser_decision
    if [[ "$browser_decision" == "1" ]]; then
        declare -a browser_list=("firefox" "firefox-nightly")
    elif [[ "$browser_decision" == "2" ]]; then
        declare -a browser_list=("google-chrome" "google-chrome-beta" "google-chrome-unstable")
    elif [[ "$browser_decision" == "3" ]]; then
        declare -a browser_list=("chromium-browser")
    elif [[ "$browser_decision" == "4" ]]; then
        declare -a browser_list=("microsoft-edge-stable" "microsoft-edge-beta")
    elif [[ "$browser_decision" == "5" ]]; then
        declare -a browser_list=("brave-browser" "brave-browser-beta" "brave-browser-nightly")
    elif [[ "$browser_decision" == "6" ]]; then
        declare -a browser_list=("vivaldi-stable vivaldi-snapshot")
    elif [[ "$browser_decision" == "7" ]]; then
        declare -a browser_list=("opera-stable" "opera-beta")
    elif [[ "$browser_decision" == "8" ]]; then
        declare -a browser_list=("ungoogled-chromium" "ungoogled-chromium-bin")
    elif [[ "$browser_decision" == "9" ]]; then
        declare -a browser_list=("librewolf")
    else
        echo "Invia un numero da 1 a 9."
    fi
    for b in "${browser_list[@]}"; do
        res=$(eval "which" "$b")
        if [[ "$res" != *"no $b in"* ]]; then
            browser="$res"
            break
        fi
    done
    if [ "$browser" == "" ]; then
        echo "Non e' stato trovato il browser selezionato. Selezionane un altro: "
    else
        echo "Browser trovato!"
    fi
done

# Chiedo di quali treni ricevere le notifiche
cont="s"
trenord=""
atm=""
while [ "$cont" = "s" ]; do
    echo ""
    echo "Vuoi ricevere le notifiche per Trenord? [s/n]"
    while [ "$trenord" = "" ]; do
        read conft
        if [ "$conft" = "s" ]; then
            trenord="s"
        elif [ "$conft" = "n" ]; then
            trenord="n"
        else
            echo "Premi s o n."
        fi
    done
    echo ""
    echo "Vuoi ricevere le notifiche per ATM? [s/n]"
    while [ "$atm" = "" ]; do
        read confa
        if [ "$confa" = "s" ]; then
            atm="s"
        elif [ "$confa" = "n" ]; then
            atm="n"
        else
            echo "Premi s o n."
        fi
    done

    if [[ "$trenord" == "n" && "$atm" == "n" ]]; then
        echo "Hai detto no a tutte le opzioni. Premi n per fermare l'installazione, qualunque altro tasto per riselezionare le opzioni."
        read stp
        if [ "$stp" = "n" ]; then
            echo ""
            echo "Ciao!"
            exit 0
        else
            trenord=""
            atm=""
        fi
    else
        cont="n"
    fi
done

# Configuro i file
echo ""
echo "Configurando le cartelle su $USRPATH/non-un-altro-sciopero..."
if [ ! -d "$USRPATH/non-un-altro-sciopero" ]; then
    mkdir "$USRPATH/non-un-altro-sciopero" >/dev/null 2>&1
    if [ ! -d "$USRPATH/non-un-altro-sciopero" ]; then
        echo "Non è stato possibile creare la cartella $USRPATH/non-un-altro-sciopero. Si suggerisce di avvisare il problema sulla repo: github.com/gi-lom/non-un-altro-sciopero"
        exit 1
    fi
    cp -R -v -T src "$USRPATH/non-un-altro-sciopero" >/dev/null 2>&1
else
    cp src/main.py "$USRPATH/non-un-altro-sciopero" >/dev/null 2>&1
fi
if [ ! -f "$USRPATH/non-un-altro-sciopero/main.py" ]; then
    echo "Non è stato possibile creare uno o più file nella cartella $USRPATH/non-un-altro-sciopero. Si suggerisce di avvisare il problema sulla repo: github.com/gi-lom/non-un-altro-sciopero"
    exit 1
fi
chmod +x "$USRPATH/non-un-altro-sciopero/main.py" >/dev/null 2>&1
chmod +x "$USRPATH/non-un-altro-sciopero/checker.txt" >/dev/null 2>&1
if [ "$trenord" = "s" ]; then
    if [ ! -f "$USRPATH/non-un-altro-sciopero/ferrovie/Trenord.txt" ]; then
        echo "" >"$USRPATH/non-un-altro-sciopero/ferrovie/Trenord.txt"
    fi
else
    if [ -f "$USRPATH/non-un-altro-sciopero/ferrovie/Trenord.txt" ]; then
        rm "$USRPATH/non-un-altro-sciopero/ferrovie/Trenord.txt"
    fi
fi
if [ "$atm" = "s" ]; then
    if [ ! -f "$USRPATH/non-un-altro-sciopero/ferrovie/ATM.txt" ]; then
        echo "" >"$USRPATH/non-un-altro-sciopero/ferrovie/ATM.txt"
    fi
else
    if [ -f "$USRPATH/non-un-altro-sciopero/ferrovie/ATM.txt" ]; then
        rm "$USRPATH/non-un-altro-sciopero/ferrovie/ATM.txt"
    fi
fi

# Cancello i crontab precedenti
echo ""
echo "Cancellando l'eventuale crontab precedente..."
cr=$(crontab -l)
a=($cr)
for ((i = 0; i < ${#a[@]}; i++)); do
    if [[ "${a[i]}" == "$USRPATH/non-un-altro-sciopero/main.py" ]]; then
        eval "crontab" "-l" "|" "grep" "-v" "@reboot" "sleep" "120" "&&" "python" "$USRPATH/non-un-altro-sciopero/main.py" "--browser" "${a[i + 2]}" "--path" "$USRPATH/non-un-altro-sciopero" "--error" "True" "|" "crontab" "-" >/dev/null 2>&1
        eval "crontab" "-l" "|" "grep" "-v" "@hourly" "python" "$USRPATH/non-un-altro-sciopero/main.py" "--browser" "${a[i + 2]}" "--path" "$USRPATH/non-un-altro-sciopero" "|" "crontab" "-" >/dev/null 2>&1
    fi
done

# Creo l'autostart
echo ""
echo "Creando il crontab..."
crontab -l >mycron >/dev/null 2>&1
echo "@reboot sleep 120 && python $USRPATH/non-un-altro-sciopero/main.py --browser $browser --path $USRPATH/non-un-altro-sciopero --error True" >>mycron
echo "@hourly python $USRPATH/non-un-altro-sciopero/main.py --browser $browser --path $USRPATH/non-un-altro-sciopero" >>mycron
crontab mycron >/dev/null 2>&1
if [[ $? == 1 ]]; then
    echo ""
    echo "Non è stato possibile creare il crontab. Si suggerisce di avvisare il problema sulla repo: github.com/gi-lom/non-un-altro-sciopero"
    exit 1
fi
rm mycron

# Fine
echo ""
echo "Fatto!"
echo "Se devi cambiare browser, basta far girare di nuovo questo script."
echo ""
