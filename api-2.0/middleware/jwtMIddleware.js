const jwt = require("jsonwebtoken");

const jwtTokens = ({user_id, user_fname, user_email}) => {
        const user = {user_id, user_fname, user_email};

        const accessToken = jwt.sign(user, process.env.ACCESS_TOKEN_SECTRET, {expiresIn:"12000m"})
        const refeshToken = jwt.sign(user, process.env.REFRESH_TOKEN_SECRET, {expiresIn:"120m"})

        return ({accessToken, refeshToken})

}

module.exports = jwtTokens