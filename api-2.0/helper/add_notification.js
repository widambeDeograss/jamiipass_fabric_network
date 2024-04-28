const pool = require("./db_connect");

const addNtification = async (type,  data) => {
    if (type === "organization") {
        const {notification, org_id} = data;
        await pool.query('INSERT INTO organization_notification (org_id, notification) VALUES($1,$2) RETURNING *',
           [notification, org_id]).then(
            not => {
                return true
            }
           ).catch(
            error => {
                throw error;
            }
           )
    } else if (type === "corporate") {
        const {notification, corp_id} = data;
        await pool.query('INSERT INTO corporate_notification (corp_id, notification) VALUES($1,$2) RETURNING *',
           [notification, corp_id]).then(
            not => {
                return true
            }
           ).catch(
            error => {
                throw error;
            }
           )
    }else{
        const {notification, user_id} = data;
        await pool.query('INSERT INTO user_notifications (user_id, notification) VALUES($1,$2) RETURNING *',
           [notification, corp_id]).then(
            not => {
                return true
            }
           ).catch(
            error => {
                throw error;
            }
           )
    }
}

module.exports = addNtification;