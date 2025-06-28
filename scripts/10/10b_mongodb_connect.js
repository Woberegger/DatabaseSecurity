#!/usr/bin/node
const { MongoClient } = require('mongodb');

// Replace these with your values
const username = encodeURIComponent('admin');
const password = encodeURIComponent('my-secret-pw');
const host = 'localhost';
const port = 27017;
const dbName = 'mongodb';
 
const uri = `mongodb://${username}:${password}@${host}:${port}/${dbName}?authSource=admin`;
const client = new MongoClient(uri);

async function run() {
  try {
    await client.connect();
    console.log('Connected to MongoDB with authentication');
 
    const db = client.db('ims');
    const collection = db.collection('students'); // what we have generated in previous lesson
 
    // Example: insert a user
    await collection.insertOne({ name: 'Alice', age: 29, course: 'IMS', email: 'alice@example.com' });
 
    // Example: find all students
    const students = await collection.find().toArray();
    console.log(students);
  } catch (err) {
    console.error(err);
  } finally {
    await client.close();
  }
}
 
run();
