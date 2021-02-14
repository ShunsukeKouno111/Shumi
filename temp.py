import time
from selenium import webdriver
website = 'https://toolmania.info/post-9708/'

# =================================================
# chromeを開く
chro = webdriver.Chrome()
chro.get(website)

if(chro.current_url == website):
    time.sleep(3)
    # テキスト入力
    input = chro.find_element_by_id('inputtext')
    input.send_keys('テスト用テキスト')
    print("テキスト入力")

    time.sleep(3)
    # ファイルの選択
    input = chro.find_element_by_id('fileselect')
    input.send_keys("c:\\")
    print("ファイルの選択")

chro.quit()
