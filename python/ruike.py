import time
import requests
from lxml import etree
import time


class RuiKe:
    def __init__(self):
        self.homeUrl = "https://www.ruike1.com/"
        self.loginUrl = "https://www.ruike1.com/member.php?mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1"
        self.signUrl = "https://www.ruike1.com/forum.php?mod=forumdisplay&fid=47&filter=author&orderby=dateline"
        self.headers = {
            "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.99 Safari/537.36"
        }
        self.repayUrl = "https://www.ruike1.com/forum.php?mod=post&action=reply&fid={}&tid={}&extra=page=1&filter=author&orderby=dateline&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1"
        self.session = requests.session()

    def login(self):
        data = {
            "fastloginfield": "username",
            "username": "",
            "password": "",
            "quickforward": "yes",
            "handlekey": "ls"
        }
        response = self.session.post(
            self.loginUrl, headers=self.headers, data=data)
        response = self.session.get(self.homeUrl, headers=self.headers)
        html = etree.HTML(response.text)
        account = html.xpath('//a[@title="访问我的空间"]/text()')
        if len(account) > 0:
            print("登录成功")
        else:
            print("登录失败")
        # print(response.text)
        # with open("ruike.html", "wb") as f:
        #     f.write(response.content)

    def getSignList(self):
        response = self.session.get(self.signUrl, headers=self.headers)
        html = etree.HTML(response.text)
        '''
        //a[@title="新窗口打开"]/@href
        获取链接和名字
        //a[@class="s xst"]/text()
        //a[@class="s xst"]/@href
        '''
        href_list = html.xpath('//a[@class="s xst"]/@href')
        a_text_list = html.xpath('//a[@class="s xst"]/text()')

        data = []
        for index, text in enumerate(a_text_list):
            dic = {}
            dic["name"] = text
            dic["url"] = href_list[index]
            data.append(dic)
        # print(data)

        return data

    def signHandle(self, data):
        count = 0
        for item in data:
            if count > 5:
                print("回复完成 count =", count)
                return
            signUrl = self.homeUrl + item["url"]
            # signUrl = self.homeUrl + data[12]["url"]
            print(signUrl)
            response = self.session.get(signUrl, headers=self.headers)
            # 判断是否需要回复
            html = etree.HTML(response.text)
            repay_text = html.xpath("//div[@class='locked']/text()")
            if (len(repay_text) == 0):
                return
            print(repay_text)
            if "需要支付" in repay_text[0]:
                print("本帖不需要回复")
            else:
                print("需要回复")
                # fid
                fid_xpath = html.xpath("//div[@class='locked']/a/@href")
                print(fid_xpath)
                # tid_text=""
                # fid_text=""
                if len(fid_xpath) > 0:
                    tid_text = fid_xpath[0].split('=')[-1]
                    print(tid_text)
                    fid_text = fid_xpath[0].split('=')[-2].split("&")[0]
                    print(fid_text)

                # formhash
                formhash_xpath = html.xpath('//input[@name="formhash"]/@value')
                if len(formhash_xpath) > 0:
                    formhash_text = formhash_xpath[0]
                    print(formhash_text)

                self.repayUrl = self.repayUrl.format(fid_text, tid_text)
                print(self.repayUrl)

                data = {
                    "file": "",
                    # "message": "\u771f\u7684\u592a\u68d2\u4e86\u54c8\u{}".format(signUrl),
                    "message": signUrl,
                    "posttime": int(time.time()),
                    "formhash": formhash_text,
                    "usesig": 1,
                    "subject": ""
                }
                response = self.session.post(
                    self.repayUrl, headers=self.headers, data=data)
                print(response.text)
                count += 1
                print("回帖等待中需要间隔15秒")
                time.sleep(20)

    def run(self):
        self.login()
        data = self.getSignList()
        self.signHandle(data)


if __name__ == "__main__":
    ruiKe = RuiKe()
    ruiKe.run()
