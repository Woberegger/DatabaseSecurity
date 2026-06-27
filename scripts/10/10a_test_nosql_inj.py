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
 
# Setup: insert 2 new users into fresh table
users.delete_many({ "username": {"$ne": None}});
users.insert_one({"username": "testuser", "password": "whatever"})
users.insert_one({"username": "admincopy", "password": "secret"})

# Simulated user input - Injection, this should find all users
user_input = {
    "username": {"$ne": None},
    "password": {"$ne": None}
}

users = users.find(user_input)

if users:
   print("password provision bypassed! Found users:");
   for u in users:
      print(u)

else:
    print("Injection failed.")

client.close()