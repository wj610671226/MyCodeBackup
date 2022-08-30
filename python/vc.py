import time
import requests
from lxml import etree
import random

class VcPageLogin:
    def __init__(self):
        self.headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36",
            }
        self.loginPageUrl = "https://www.cctry.com/member.php?mod=logging&action=login"
        self.loginUrl = "https://www.cctry.com/member.php?mod=logging&action=login&loginsubmit=yes&loginhash={}&inajax=1"
        self.signPageUrl = "https://www.cctry.com/plugin.php?id=dsu_paulsign:sign"
        self.signUrl = "https://www.cctry.com/plugin.php?id=dsu_paulsign:sign&operation=qiandao&infloat=1&inajax=1"
        self.session = requests.session()

    def getUrlParmFromHtml(self):
        # 获取loginhash
        response = self.session.get(self.loginPageUrl, headers=self.headers);
        login_page_html = etree.HTML(response.text)
        loginhash_array = login_page_html.xpath('//form[@name="login"]/@action')
        loginhash = loginhash_array[0].split('=')[-1]
        print("loginhash = ", loginhash)
        # formhash
        formhash = login_page_html.xpath('//input[@name="formhash"]/@value')[0]
        print("getUrlParmFromHtml = formhash = ", formhash)
        return (loginhash, formhash)

    def login(self, loginhash, formhash):
        #login 
        self.loginUrl = self.loginUrl.format(loginhash)
        print("self.loginUrl = ", self.loginUrl)
        data = {
            "formhash": formhash ,
            "referer": "https://www.cctry.com/plugin.php?id=dsu_paulsign:sign",
            "username": "wj835532411",
            "password": "6b2244ecf5881e4aa6d4235d16be7b48" ,
            "questionid": "0",
            "answer": "",
        }
        response = self.session.post(self.loginUrl, headers=self.headers, data=data)
        # print(response.text)
        # print(type(response.text))
        if "欢迎您回来" not in response.text:
            print("登录失败")
            return
        print("登录成功")

    def sign(self):
        # 签到
        response = self.session.get(self.signPageUrl, headers=self.headers)
        # print(response.text)
        sign_html = etree.HTML(response.text)
        sgin_result = sign_html.xpath("//h1[@class='mt']/text()")[0]
        print("sgin_result = ", sgin_result);
        if "您今天已经签到过了" in sgin_result:
            print("已经签到")
            coan = sign_html.xpath("//font[@color='#ff00cc']/b/text()")[0]
            print("金币总数为: ", coan)
        else:
            print("需要签到")
            formhash = sign_html.xpath('//input[@name="formhash"]/@value')[0]
            print("sign = formhash = ", formhash)
            # 获取自动签名内容
            # content = sign_html.xpath('//option/text()')
            # print("content = ", content)
            # 获取自动签到心情
            qdxq = sign_html.xpath('//input[@name="qdxq"]/@value')
            print("qdxq = ", qdxq)

            count = len(qdxq) - 1
            print("开始签到 = ", count)
            index = random.randint(0, count)
            data={
                "formhash": formhash,
                "qdxq": qdxq[index],
                "qdmode": 2,
                "todaysay": "",
                "fastreply": 2
            }
            self.session.post(self.signUrl, headers=self.headers, data=data)
            time.sleep(1)
            self.sign()

            

    def run(self):
        (loginhash, formhash) = self.getUrlParmFromHtml()
        self.login(loginhash, formhash)
        self.sign()


if __name__ == "__main__":
    loginPage = VcPageLogin()
    loginPage.run()




