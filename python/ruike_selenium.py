from asyncio import sleep
from itertools import count
from re import S
from threading import Thread
from selenium import webdriver
from selenium.webdriver.common.by import By
import time
import random


class RuiKe:
    def __init__(self):
        self.homeUrl = "https://www.ruike1.com/"
        self.loginUrl = "https://www.ruike1.com/member.php?mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1"
        self.signUrl = "https://www.ruike1.com/forum.php?mod=forumdisplay&fid=47&filter=author&orderby=dateline"
        self.repayUrl = "https://www.ruike1.com/forum.php?mod=post&action=reply&fid={}&tid={}&extra=page=1&filter=author&orderby=dateline&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1"
        self.replyCount = 0
        # 金币数量
        self.gold = "0"

        # 无界面模式配置
        options = webdriver.ChromeOptions()
        options.add_argument("--headless")
        self.driver = webdriver.Chrome(options=options)
        # self.driver = webdriver.Chrome()

        # 设置等待时间
        self.driver.implicitly_wait(10)

    def login(self):
        self.driver.get(self.homeUrl)
        self.driver.find_element(
            by=By.XPATH, value='//*[@id="ls_username"]').send_keys("account")
        self.driver.find_element(
            by=By.XPATH, value='//*[@id="ls_password"]').send_keys("password")
        self.driver.find_element(
            by=By.XPATH, value='//*[@id="lsform"]/div/div[1]/table/tbody/tr[2]/td[3]/button').click()
        time.sleep(1)
        self.driver.get(self.homeUrl)
        # 检查是否签到
        signMessage = self.driver.find_element(
            by=By.XPATH, value='//*[@id="fx_checkin_b"]')
        signMessageAlt = signMessage.get_attribute("alt")
        print("signMessageAlt = ", signMessageAlt)
        if (signMessageAlt != "今日已签"):
            self.driver.find_element(
                by=By.XPATH, value='//*[@id="k_misign_topb"]/a').click()
        else:
            print("今天已经签到")
        account = self.driver.find_element(
            by=By.XPATH, value='//*[@id="um"]/p[1]/strong/a').text
        print("account = ", account)
        if account == "wj835532411":
            print("登录成功")
            # 判断是否签到
            alt = self.driver.find_element(
                by=By.XPATH, value='//*[@id="fx_checkin_b"]').get_attribute('alt')
            print("alt = ", alt)
            if alt == "今日已签":
                print("今日已经签到")
            else:
                # 签到
                self.driver.find_element(
                    by=By.XPATH, value='//*[@id="k_misign_topb"]/a').click()
            return True
        else:
            print("登录失败")
            return False

    def get_reply_lists(self):
        print("获取it教程列表")
        # it教程
        self.driver.find_element(
            by=By.XPATH, value='//*[@id="category_"]/table/tbody/tr[1]/td[3]/a').click()
        self.switchWindow()
        articles = self.driver.find_elements(
            by=By.XPATH, value='//a[@class="s xst"]')
        print("articles =", articles)
        for item in articles:
            self.reply(item)
            if self.replyCount >= 2:
                break

    def reply(self, item):
        item.click()
        self.switchWindow()
        print("reply url = ", self.driver.current_url)
        message = self.driver.find_element(
            by=By.XPATH, value="//div[@class='locked']")
        if message == None:
            return
        message = message.text
        print("message = ", message)
        # 判断是否需要回复
        if "请回复" not in message:
            print("本帖不需要回复")
        else:
            print("需要回复")
            contents = self.driver.find_elements(
                by=By.XPATH, value="//span[@class='button_7ree']")
            count = len(contents) - 1 - 1
            index = random.randint(0, count)
            print("contents = ", contents)
            print("count = ", count)
            print("index = ", index)
            # 选择回复内容
            # contents[index].click()
            self.driver.execute_script("arguments[0].click()", contents[index])
            # 回复
            self.driver.find_element(
                by=By.XPATH, value='//*[@id="fastpostsubmit"]').click()
            self.replyCount += 1
            print("回复成功")
            time.sleep(random.randint(16, 25))

        time.sleep(1)
        self.driver.close()
        self.switchWindow()

    def switchWindow(self):
        windows = self.driver.window_handles
        window_count = len(windows)
        print("windows = ", windows)
        target_index = window_count - 1
        if target_index >= 0:
            self.driver.switch_to.window(windows[target_index])

    def get_gold(self):
        # 进入个人信息页面
        self.driver.find_element(
            by=By.XPATH, value='//*[@id="um"]/p[1]/strong/a').click()
        self.switchWindow()
        print("before gold = ", self.gold)
        gold = self.driver.find_element(
            by=By.XPATH, value='//*[@id="psts"]/ul/li[4]').text
        self.gold = gold
        print("end gold = ", self.gold)
        self.driver.close()
        self.switchWindow()

    def run(self):
        isLogin = self.login()
        if isLogin:
            self.get_gold()
            self.get_reply_lists()
            self.get_gold()


if __name__ == "__main__":
    ruiKe = RuiKe()
    ruiKe.run()
    print("quit end")
    # 退出模拟浏览器
    ruiKe.driver.quit()
