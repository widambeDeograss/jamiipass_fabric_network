const jwt = require("jsonwebtoken");

const orgJwtMiddleware = ({org_id, org_name, email}) => {
        const org = {org_id, org_name, email};

        const accessToken = jwt.sign(org, process.env.ACCESS_TOKEN_SECTRET, {expiresIn:"12000m"})
        const refeshToken = jwt.sign(org, process.env.REFRESH_TOKEN_SECRET, {expiresIn:"120m"})

        return ({accessToken, refeshToken})

}

module.exports = orgJwtMiddleware;