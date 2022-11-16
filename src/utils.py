import os
import subprocess
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException, TimeoutException


def check_len(els):
    alert_title = ""
    if len(els) > 0:
        alert = [ els[0].get_attribute("innerHTML") ]
        alert_title = name + ": " + alert[0].lower()
    return alert_title


def train_checker(driver, website, name, css_element, text_element, path):
    driver.get(website)
    try:
        alwait = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, css_element))
        )
        els = driver.find_elements(By.CSS_SELECTOR, text_element)
        alert_title = check_len(els)
        if "sciopero" in alert_title.lower():
            filepath = str(path) + "/ferrovie/"+name+".txt"
            mode = "r+" if os.path.isfile(filepath) else "w"
            with open(filepath, mode) as txt:
                line = txt.readlines() if mode == "r+" else []
                if len(line) == 0 or line[0] != alert_title:
                    subprocess.Popen(['notify-send', "Non un altro sciopero!", alert_title])
                    txt.seek(0)
                    txt.truncate()
                    txt.write(alert_title)
    except (NoSuchElementException, TimeoutException) as e:
        pass
