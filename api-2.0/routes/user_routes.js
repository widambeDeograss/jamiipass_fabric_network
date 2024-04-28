const express = require("express");
const router = express.Router();
const {register_controler, login_controler, verfy_otp, refresh_token_controler, user_verify_email} = require("../controllers/user_auth");

router.post("/auth/register", register_controler);

router.get("/verify/:verificationToken", user_verify_email)

router.post("/auth/login", login_controler);

router.post("/auth/verify_org_otp", verfy_otp);

module.exports = router;