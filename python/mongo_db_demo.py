import pymongo

# 创建连接对象
# client = pymongo.MongoClient(host='172.16.42.61', port=27017)
client = pymongo.MongoClient('mongodb://admin:123456@172.16.42.61:27017/')
print(client)

# 获取数据库的名称，可以判断数据库是否存在
dblist = client.list_database_names()
print("dblist = ", dblist)

# 指定数据库
db = client["demo"]
# 指定集合
collection = db.students


student = {
    'id': '20170101',
    'name': 'zhangsan',
    'age': 30,
    'gender': 'male'
}

# 插入一条数据
# result = collection.insert_one(student)
# print("result = ", result, " id = ", result.inserted_id)

# 插入多条数据
# result = collection.insert_many([student1, student2])

# 查询一条数据
# result = collection.find_one({'name': "zhangsan"})

# 查询多条数据
# result = collection.find({'gender': "male"})
# 限制只获取2条数据
# result = collection.find({'gender': "male"}).limit(2)
# for item in result:
#     print(item)

# 更新数据
# quary = {'name': "zhangsan"}
# result = collection.update_one(quary, {"$set": {"name": "lisi"}})
# print(result)

# 删除数据
quary = {'name': "zhangsan"}
result = collection.delete_one(quary)
print(result)
