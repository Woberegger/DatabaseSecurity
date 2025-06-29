from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, OperationFailure

uri = "mongodb://admin:my-secret-pw@localhost:27017/admin"  # default auth DB is 'admin'

try:
    client = MongoClient(uri, serverSelectionTimeoutMS=10000)
    client.admin.command('ping')
    print("✅ Connected successfully to MongoDB.")
except ConnectionFailure as cf:
    print("❌ Connection failed:", cf)
except OperationFailure as of:
    print("❌ Authentication failed:", of)
finally:
    client.close()