# once the mongodb is running, we can try with "mongosh" CLI or with our GUI client
# you should use '//' for comments (this also works within one command struct)
# the ';' is used to terminate statements within one line, at the end of the line it is optional.

# connect to the mongoDB docker container
# Variant a) directly use mongosh with docker exec command
docker exec -it -u root mongodb mongosh mongodb://admin:my-secret-pw@mongodb:27017

# Variant b) first with bash and then mongosh
docker exec -it -u root mongodb /bin/bash
# and inside the docker container try mongosh CLI for mongodb to show, which databases there exist
mongosh --username admin --password my-secret-pw --eval "show dbs;"
# this should find the 3 databases admin, config and local

# now we will create our own database "ims"
mongosh --username admin --password my-secret-pw
   // the following displays the full connect string to use from command line
   db.getMongo()
   // TAKE CARE: do not use ';' here at the end, otherwise it will create a database named "ims;"
   use ims // switches to a new database, only when first objects are created, the "show dbs" command will find it
   db.createCollection("students");
   // if you want to remove that collection later, call
   // db.getCollection("students").drop();
   // insert 1 record
   db.students.insertOne({
     name: "John Doe",
     age: 25,
     course: "IMS",
     semester: 3,
     tags: ["interests", "marks"],
     created: Date()
   });
   // and many records
   // as you can see, fields can differ, e.g. new field "studentid" or missing field "course"
   db.students.insertMany([  
     {
        name: "Jane Moe",
        age: 23,
        // new field "studentid"
        studentid: "12345", 
        course: "ITM",
        semester: 3,
        tags: ["interests", "experience"],
        created: Date()
     },
     {
        name: "Wolfgang Amadeus Mozart",
        age: 29,
        semester: 3,
        // course is not known yet
        tags: ["music"],
        created: Date()
     }
   ]);
   
   db.students.find( {name: "John Doe" });
   // find any record, but only show columns "name" and "course" (1...show column, 0...hide column)
   db.students.find( {}, {name: 1, course: 1} );
   // now we have finally found a suitable study for Mozart ;-)
   db.students.updateOne( { name: "Wolfgang Amadeus Mozart" }, { $set: { course: "Music" } } );
   // MongoDB also knows a "Merge" operation, they call it "upsert" (as combination of update+insert)
   db.students.updateOne( 
     { name: "Potentially New Student" }, 
     {
       $set: 
         {
           age: 24,
           studentid: "99999", 
           course: "ITM",
           semester: 3,
           created: Date()
         }
     }, 
     { upsert: true }
   );
   // check, if it is correctly listed
   db.students.find({});
   // however we want to delete that student again
   // IMPORTANT: if you unintentionally have created 2 students with the same name (which is possible, as we did not define any constraints),
   //            the following will only delete the first matching one with that name!
   db.students.deleteOne({ name: "Potentially New Student" });
   // in that example we delete all ITM students
   db.students.deleteMany({ course: "ITM" });
   
   // now do some simple computation by finding the average age of students, grouped by course
   // in SQL this would be: SELECT Course, AVG(Age) AS avgAge FROM Students WHERE Age > 0 GROUP BY Course;
   db.students.aggregate([
     // Stage 1: Only find students, where the "age" is set
     {
       $match: { age: { $gt: 0 } }
     },
     // Stage 2: Group students by course and take avg age per student
     {
       $group: { _id: "$course", avgAge: { $avg: "$age" } }
     }
   ]);

// for later nosql injection tests we create some additional users
   use admin
   db.users.insertOne({"username": "admincopy", "password": "secret"});
   db.users.insertOne({"username": "normaluser", "password": "normal"});
   db.users.insertOne({"username": "readonlyuser", "password": "readonly"});