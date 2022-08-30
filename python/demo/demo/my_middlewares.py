import random

from demo.settings import USER_AGENTS


class RandomUserAgentMiddleware:
    def process_request(self, request, spider):
        # 利用下载中间件实现随机的USER_AGENTS
        user_agent = random.choice(USER_AGENTS)
        # print("user_agent = ", user_agent)
        request.headers.setdefault("User-Agent", user_agent)
        return None


class ProxyMiddleware:

    def process_request(self, request, spider):
        # 免费代理ip设置
        request.meta['proxy'] = "https://1.71.188.37:3128"
