const express = require("express");
const authoiseToken = require('../middleware/authorization');
const router = express.Router();
const {change_user_password, update_user, update_user_profile, register_controler, login_controler, verfy_otp, refresh_token_controler, user_verify_email, get_identification_requests} = require("../controllers/user_auth");

router.post("/auth/register", register_controler);

router.get("/verify/:verificationToken", user_verify_email)

router.post("/auth/login", login_controler);

router.post("/auth/verify_user_otp", verfy_otp);

router.get("/all_id_requests/:id", get_identification_requests)

router.put('/update/:user_id', update_user);

router.put('/update/:user_id/profile', update_user_profile);

router.put('/update/:user_id/password', change_user_password);

module.exports = router;