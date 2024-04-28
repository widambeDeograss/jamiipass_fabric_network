const express = require("express");
const router = express.Router();
const authoiseToken = require('../middleware/authorization');
const {org_register_controler, login_controler, 
    logout_controler, refresh_token_controler, 
    get_all_organizations, get_org_info, get_organization_notification,
    verfy_otp, org_verify_email, get_all_identifications, create_identification,get_identification_request, get_all_identification_requests, create_identification_request  } = require("../controllers/organization_controller");

router.post("/auth/register", org_register_controler);

router.get("/verify/:verificationToken", org_verify_email)

router.post("/auth/login", login_controler);

router.post("/auth/verify_org_otp", verfy_otp)

router.get("/auth/refresh_log",  refresh_token_controler);

router.delete("/auth/logout", logout_controler);

router.get("/all_orgs", get_all_organizations );

router.get("/org_info",authoiseToken, get_org_info );

router.post("/create_identification", authoiseToken, create_identification);

router.post("/create_identification_request", create_identification_request);

router.get("/all_identifications", authoiseToken, get_all_identifications);

router.get("/all_identification_requests", authoiseToken, get_all_identification_requests);

router.get("/identification_request/:id", get_identification_request);

router.get("/all_notications/",authoiseToken, get_organization_notification );


module.exports = router;