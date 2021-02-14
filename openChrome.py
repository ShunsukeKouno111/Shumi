# seleniumのwebdriverをインポート
from selenium import webdriver

# chromeを開く
# chromeいじるのに下記からバージョンに合ったドライバーのダウンロードが必須。後方互換性なし。
# https://sites.google.com/a/chromium.org/chromedriver/downloads
chro = webdriver.Chrome()

# urlを指定する
chro.get("https://toolmania.info/")

# # chrome閉じる
# chro.quit()
