const {Pool, Client} = require("pg");

const pool = new Pool({
    user:"postgres",
    password:"post30",
    host:"localhost",
    database:"jamii_pass_db",
    port:5432
});

module.exports = pool;