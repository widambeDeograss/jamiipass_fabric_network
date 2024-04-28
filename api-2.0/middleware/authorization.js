const jwt = require("jsonwebtoken");

const authoiseToken = (req, res, next) => {
    const authHeader = req.headers["authorization"]; // Bearer TOKEN
    const token = authHeader && authHeader.split(" ")[1];
    if (!token) {
        res.status(401).json({error:"no token provided"})
    } else {
        jwt.verify(token, process.env.ACCESS_TOKEN_SECTRET, (error, user) => {
            if (error) {
                res.status(403).json({error:error.message})
            } else {
                req.user = user;
                next();
            }
        })
    }

}

module.exports = authoiseToken;