import scrapy

from demo.items import DemoItem


class RuikeSpider(scrapy.Spider):
    name = 'ruike'

    allowed_domains = ['ruike1.com']
    start_urls = [
        'https://www.ruike1.com/forum.php?mod=forumdisplay&fid=47&filter=author&orderby=dateline'
    ]

    def parse(self, response):

        # print("response = ", response.body)
        # with open("ruike.html", 'wb') as f:
        #     f.write(response.body)

        tbody_list = response.xpath('//tbody[contains(@id, "normal")]')
        # pass
        print("th_tbody_listlist.count = ", len(tbody_list))
        for item in tbody_list:

            # 没有建模之前的写法
            # data = {}
            # # 提取值
            # data["title"] = item.xpath('./tr/th/a[@class="s xst"]/text()').extract_first()
            # data["author"] = item.xpath('./tr/td[2]/cite/a/text()').extract_first()
            # # print("data = ", data)
            # yield data

            # 采用建模的写法
            data = DemoItem()
            data["title"] = item.xpath(
                './tr/th/a[@class="s xst"]/text()').extract_first()
            data["author"] = item.xpath(
                './tr/td[2]/cite/a/text()').extract_first()
            yield data

        # 判断是否有下一页的数据
        curpage = response.xpath('//a[@id="autopbn"]/@curpage').extract_first()
        totalpage = response.xpath(
            '//a[@id="autopbn"]/@totalpage').extract_first()
        if (curpage == None and totalpage == None):
            return
        curpage = int(curpage)
        totalpage = int(totalpage)
        print("curpage totalpage", curpage, totalpage)
        if (curpage < totalpage):
            print("有下一页")
            next_page_url = response.xpath(
                '//a[@id="autopbn"]/@rel').extract_first()
            next_page_url = "https://www.ruike1.com/" + next_page_url
            print("next_page_url ", next_page_url)
            # 获取下一页数据
            yield scrapy.Request(next_page_url, callback=self.parse)
        else:
            print("没有下一页")
