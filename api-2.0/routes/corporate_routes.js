const express = require("express");
const router = express.Router();
const authoiseToken = require('../middleware/authorization');
const {corp_identity_shares_history, corp_identity_share, create_identity_share, get_all_corporatess, corp_register_controler, login_controler, logout_controler, refresh_token_controler, verfy_otp, corp_verify_email, get_corp_info, get_corporate_notification} = require("../controllers/corporate_controller");

router.post("/auth/register", corp_register_controler);

router.get("/verify/:verificationToken", corp_verify_email)

router.post("/auth/login", login_controler);

router.post("/auth/verify_corp_otp", verfy_otp)

router.get("/auth/refresh_log",  refresh_token_controler);

router.delete("/auth/logout", logout_controler);

router.get("/all_corporates", authoiseToken, get_all_corporatess);

router.get("/corp_info",authoiseToken, get_corp_info );

router.post("/share_id", create_identity_share );

router.get("/share_history",authoiseToken, corp_identity_shares_history );

router.get("/get_shared_ids/:id",authoiseToken, corp_identity_share );

router.get("/all_notications/",authoiseToken, get_corporate_notification );



module.exports = router;