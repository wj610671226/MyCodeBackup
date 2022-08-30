# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
import json
from itemadapter import ItemAdapter


class DemoPipeline:

    # def __init__(self):
    #     self.file = open('ruike.json', 'w+')

    def open_spider(self, spider):
        if spider.name == "ruike":
            print("DemoPipeline open_spider")
            self.file = open('ruike.json', 'w+')

    def process_item(self, item, spider):
        if spider.name == "ruike":
            # 管道中处理item数据(parse函数处理后yield返回的数据)
            print("process_item = ", item)
            # 把采集的数据保存到json文件中
            data = json.dumps(dict(item), ensure_ascii=False) + ',\n'
            self.file.write(data)
        return item

    def close_spider(self, spider):
        if spider.name == "ruike":
            self.file.close()


class DemoPipeline_other:
    def open_spider(self, spider):
        if spider.name == "crawl_ruike":
            print("DemoPipeline_other open_spider")
            # 如果有多个爬虫，可以根据name来判断不同爬虫做相应的处理
            # print("name = ", spider.name)
            self.file = open('crawl_ruike.json', 'w+')

    def process_item(self, item, spider):
        if spider.name == "crawl_ruike":
            print("process_item = ", item)
            data = json.dumps(dict(item), ensure_ascii=False) + ',\n'
            self.file.write(data)
        return item

    def close_spider(self, spider):
        if spider.name == "crawl_ruike":
            self.file.close()
