'''
断点续爬
'''
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import CrawlSpider, Rule

from demo.items import DemoItem


class CrawlRuikeSpider(CrawlSpider):
    name = 'crawl_ruike_xu'
    allowed_domains = ['ruike1.com']
    # start_urls = ['http://ruike1.com/']
    start_urls = [
        'https://www.ruike1.com/forum.php?mod=forumdisplay&fid=47&filter=author&orderby=dateline'
    ]

    rules = (
        # 提取下一页 url 不需要callback处理，follow=True表示需要继续在返回的url继续通过定义的规则提取url
        Rule(LinkExtractor(
            allow=r'forum.php\?mod=forumdisplay&fid=\d+&orderby=dateline&.*page=\d+'), follow=True),
        # 提取详情地址 callback提取详情页面的数据
        Rule(LinkExtractor(allow=r'forum.php\?mod=viewthread&tid=\d+&extra=page%3D1%26filter%3Dauthor%26orderby%3Ddateline$'),
             callback='parse_item'),
    )

    def parse_item(self, response):
        item = DemoItem()

        #item['domain_id'] = response.xpath('//input[@id="sid"]/@value').get()
        #item['name'] = response.xpath('//div[@id="name"]').get()
        #item['description'] = response.xpath('//div[@id="description"]').get()
        title = response.xpath(
            '//*[@id="thread_subject"]/text()').extract_first()
        # print(response.url)
        print("提取数据 title = ", title)
        item["title"] = title
        return item
