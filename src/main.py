import os

from subprocess import run, PIPE
from time import strftime, localtime
from argparse import ArgumentParser as argument_parser

from selenium import webdriver
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException

from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.firefox.service import Service as FirefoxService
from selenium.webdriver.edge.service import Service as EdgeService

from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.firefox import GeckoDriverManager
from webdriver_manager.core.utils import ChromeType
from webdriver_manager.microsoft import EdgeChromiumDriverManager
from webdriver_manager.opera import OperaDriverManager



def train_checker(driver, website, name, css_element, text_element, path):
    driver.get(website)
    try:
        alwait = WebDriverWait(driver, 30).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, css_element))
        )
        els = driver.find_elements(By.XPATH, text_element)
        if len(els) > 0:
            alert = els[0].text.split("\n")
            alert_title = name + ": " + alert[0].lower()
            alert_desc = alert[1] if len(alert) > 1 else ""
            if "sciopero" in alert_title.lower() or "sciopero" in alert_desc.lower():
                filepath = str(path) + "/ferrovie/"+name+".txt"
                mode = "r+" if os.path.isfile(filepath) else "w"
                with open(filepath, mode) as txt:
                    line = txt.readlines() if mode == "r+" else []
                    text = alert_title + " " + alert_desc
                    if len(line) == 0 or line[0] != text:
                        os.system('notify-send "'+alert_title+'" "'+alert_desc+'"')
                        txt.seek(0)
                        txt.truncate()
                        txt.write(text)            
    except (NoSuchElementException, TimeoutException) as e:
        pass


def main():
    # Argument Parser
    parser = argument_parser()
    parser.add_argument('--browser', type=str, required=True)
    parser.add_argument('--path', type=str, required=True)
    parser.add_argument('--error', type=str)
    args = parser.parse_args()
    browser_input = args.browser
    path = args.path

    try:
        # Comunica che lo script è stato eseguito in un file
        with open(str(path) + "/checker.txt", "r+") as checker:
            checker.seek(0)
            checker.write("Ho controllato gli scioperi alla data " + strftime('%Y-%m-%d, %H:%M', localtime()))
            checker.truncate()

        # Verifica che il browser ci sia
        if len(run(["which", browser_input], stderr=PIPE, text=True).stderr) > 0:
            os.system(
                'notify-send "' + "Non un altro sciopero!" + '" "' + "Non è stato trovato il browser indicato quando hai installato lo script. Forse lo hai disinstallato?" + '"')
            return 1

        # Costruisci il driver
        options = FirefoxOptions() if "firefox" in browser_input or "librewolf" in browser_input else ChromeOptions()
        options.headless = True
        options.binary_location = browser_input
        driver = None
        if "google-chrome" in browser_input:
            driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()), options=options)
        elif "brave-browser" in browser_input:
            driver = webdriver.Chrome(
                service=ChromeService(ChromeDriverManager(chrome_type=ChromeType.BRAVE).install()), options=options)
        elif "firefox" in browser_input or "librewolf" in browser_input:
            driver = webdriver.Firefox(service=FirefoxService(GeckoDriverManager().install()), options=options)
        elif "edge" in browser_input:
            driver = webdriver.Edge(service=EdgeService(EdgeChromiumDriverManager().install()), options=options)
        elif "opera" in browser_input:
            if browser_input == "/usr/bin/opera":
                options.add_argument('allow-elevated-browser')
            driver = webdriver.Opera(executable_path=OperaDriverManager().install(), options=options)
        else:
            driver = webdriver.Chrome(ChromeDriverManager(chrome_type=ChromeType.CHROMIUM).install(), options=options)

        # Esegui il driver
        if os.path.isfile(str(path) + "/ferrovie/Trenord.txt"):
            train_checker(
                driver,
                "https://www.trenord.it/",
                "Trenord",
                ".container-alert .alert .text",
                "//*[contains(@class,'alert') and .//*[contains(text(), 'Sciopero')]]",
                path
            )
        if os.path.isfile(str(path) + "/ferrovie/ATM.txt"):
            train_checker(
                driver,
                # 'https://web.archive.org/web/20220626200054/https://www.atm.it/it/Pagine/default.aspx', # test url
                "https://www.atm.it/it/Pagine/default.aspx",
                "ATM",
                "#infomobilita",
                "//*[contains(@class,'news-item') and .//*[contains(text(), 'Sciopero')]]",
                path
            )

        driver.quit()

    except Exception as e:
        if args.error == "True":
            os.system(
                'notify-send "' + "Non un altro sciopero!" + '" "' + "Errore: " + str(e) + '"')

    return 0


if __name__ == '__main__':
    main()
