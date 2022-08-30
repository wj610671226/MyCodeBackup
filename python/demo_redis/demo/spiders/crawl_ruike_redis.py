'''
分布式爬虫
命令行执行 scrapy crawl crawl_ruike_redis
redis 存入key lpush redis_demo url
'''
from scrapy.spiders import Rule
from scrapy.linkextractors import LinkExtractor

from scrapy_redis.spiders import RedisCrawlSpider

from demo.items import DemoItem


class CrawlRuikeSpider(RedisCrawlSpider):
    name = 'crawl_ruike_redis'
    redis_key = 'redis_demo'

    rules = (
        # 提取下一页 url 不需要callback处理，follow=True表示需要继续在返回的url继续通过定义的规则提取url
        Rule(LinkExtractor(
            allow=r'forum.php\?mod=forumdisplay&fid=\d+&orderby=dateline&.*page=\d+'), follow=True),
        # 提取详情地址 callback提取详情页面的数据
        Rule(LinkExtractor(allow=r'forum.php\?mod=viewthread&tid=\d+&extra=page%3D1%26filter%3Dauthor%26orderby%3Ddateline$'),
             callback='parse_item'),
    )

    def __init__(self, *args, **kwargs):
        # Dynamically define the allowed domains list.
        domain = kwargs.pop('domain', '')
        # 需要将对象转换成列表
        self.allowed_domains = list(filter(None, domain.split(',')))
        print("self.allowed_domains = ", self.allowed_domains)
        super(CrawlRuikeSpider, self).__init__(*args, **kwargs)

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
