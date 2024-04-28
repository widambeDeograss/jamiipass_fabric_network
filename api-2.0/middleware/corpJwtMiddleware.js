const jwt = require("jsonwebtoken");

const corpJwtMiddleware = ({corp_id, corp_name, email}) => {
        const corp = {corp_id, corp_name, email};

        const accessToken = jwt.sign(corp, process.env.ACCESS_TOKEN_SECTRET, {expiresIn:"12000m"})
        const refeshToken = jwt.sign(corp, process.env.REFRESH_TOKEN_SECRET, {expiresIn:"120m"})

        return ({accessToken, refeshToken})

}

module.exports = corpJwtMiddleware;