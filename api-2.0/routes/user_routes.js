const express = require("express");
const authoiseToken = require('../middleware/authorization');
const router = express.Router();
const {get_all_users,delete_identity_share, change_user_password, 
    update_user, update_user_profile, register_controler, login_controler, 
    verfy_otp, user_identity_shares_history, user_verify_email, 
    get_identification_requests, user_home_stats} = require("../controllers/user_auth");

router.post("/auth/register", register_controler);

router.get("/verify/:verificationToken", user_verify_email)

router.post("/auth/login", login_controler);

router.post("/auth/verify_user_otp", verfy_otp);

router.get("/all_users", get_all_users);

router.get("/all_id_requests/:id", get_identification_requests);

router.get("/share_history", authoiseToken,user_identity_shares_history);

router.post('/update/:user_id', update_user);

router.get('/delete_share_his', delete_identity_share);

router.post('/update/:user_id/profile', update_user_profile);

router.post('/update/:user_id/password', change_user_password);

router.get('/stats/:user_id', user_home_stats);

module.exports = router;