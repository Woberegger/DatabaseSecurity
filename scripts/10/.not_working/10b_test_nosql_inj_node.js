#!/usr/bin/env node
const { MongoClient } = require('mongodb');

const username = encodeURIComponent('admin');
const password = encodeURIComponent('my-secret-pw');
const host     = 'localhost';
const port     = 27017;
const dbName   = 'ims';
const uri      = `mongodb://${username}:${password}@${host}:${port}/${dbName}?authSource=admin`;

const client = new MongoClient(uri);

async function findStudents(nameFilter) {
    const db = client.db();
    const collection = db.collection('students');
    return await collection.find(nameFilter).toArray();
}

async function run() {
    try {
        await client.connect();
        console.log('Connected to MongoDB');

        const injectionFilter = { name: { $ne: null } };

        const students = await findStudents(injectionFilter);
        console.log('Found students:', students);
    } catch (err) {
        console.error(err);
    } finally {
        await client.close();
    }
}

run();
