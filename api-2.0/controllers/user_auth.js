const pool = require("../helper/db_connect");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const jwtTokens = require("../middleware/jwtMIddleware");
const sendMail = require("../helper/send_email");
const salt_rounds = 10;


const register_controler =  async (req, res, next) => {
    const first_name = req.body.first_name
    const middle_name = req.body.middle_name
    const last_name = req.body.last_name
    const user_password = req.body.user_password
    const email = req.body.email
    const phone = req.body.phone
    const dob = req.body.dob
    const gender = req.body.gender
    const nida_no = req.body.nida_no
    const image = req.files[0]
    const  profile = image.path
    const  role = req.body.role
    const email_verified = false

      bcrypt.hash(user_password, salt_rounds).then(
        hashed => {
            console.log(hashed);
           pool.query('INSERT INTO users (first_name, middle_name, last_name, nida_no, email, phone, email_verified, dob, password, profile, gender, role) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12) RETURNING *',
           [first_name, middle_name, last_name, nida_no, email, phone, email_verified, dob, user_password, profile,gender, role])
                        .then(user => {
                            res.status(200).json({
                                message:"user created succesfully",
                                user:{
                                    user_password:hashed,
                                    user:user.rows[0]
                                }
                            })

                            
                        }).catch(error => {
                            console.log(error);
                            res.status(500).json({error:error.message,
                                data:"user wasnt created database problems"})
                        })  
        }
      ).catch(error => {
        
        res.status(500).json({error:error.message})
      })
    }

const login_controler = (req, res, next) => {
    const user_phone= req.body.user_phone
    const user_password = req.body.user_password

    pool.query('SELECT * FROM users WHERE phone = $1', [user_phone])
    .then(user => {
        if (user.rows.length === 0) {
            res.status(401).json({data:"the was no match for the email"}) 
        }else{
            bcrypt.compare(user_password, user.rows[0].user_password)
            .then( async doMatch => {
               if (doMatch) {
                const otp = Math.floor(Math.random() * 10000);

                const ress = await sendMail('JAMIIPASS LOGIN ONE TIME PASSWORD', `TO login enter this otp: ${otp}`, org.rows[0].email);
                if (ress) {
                    await pool.query('INSERT INTO user_otps (user_id, otp) VALUES($1,$2) RETURNING *',
                    [user.rows[0].user_id, otp])
                    .then(dat => {

                        res.status(200).json({
                            save:true,
                            message:"succesfully",
                            user:user.rows[0]
                        })
                    })
                   
                }
                
               } else {
                res.status(401).json({error:"incorreact password login failed"});
               }
            })
            .catch(error => console.log(error));
        }
       
    }).catch(
        error => {
            res.status(500).json({error:"server error"})
        }
    )
    
}


const user_verify_email = async (req, res, next) => {
    const verificationToken = req.param.verificationToken;
    if (verificationToken) {
    await  pool.query("UPDATE users SET email_verified = $1  WHERE user_id = $2", [true, verificationToken])
        .then(verfied => {
            res.status(200).json({
                verified: true,
                message:"user email verified succesfully",
                user:{
                    user:verfied.rows[0]
                }
            })
        }).catch(error => {
            res.status(500).json({error:error.message,
                data:"verification failed"})
        })
    }
}

const verfy_otp =async (req, res, next) => {
    const user_id  = req.body.user_id;
    const otp = req.body.otp
    
    await pool.query('SELECT * FROM user_otps WHERE user_id=$1', [user_id])
    .then(
    async user_otp => {
     if (user_otp.rows[0].otp === otp) {
         await pool.query('SELECT * FROM users WHERE user_id=$1', [user_id])
         .then(
             user => {
                  //jwts
                  const tokens = jwtTokens(user.rows[0]);
                 
                  res.cookie("refresh_token", tokens.refeshToken, {httpOnly:true, sameSite:'none', secure:true});
                  res.status(200).json({
                      token:tokens.accessToken,
                      user:user.rows[0]
                  })
             }
         )
     } else {
         res.status(400).json({
             success:false,
             message:"otp doest match",
             
         })
     }
    }
    ).catch(error => {
     res.status(500).json({error:"server error"})
    })
    .finally(
     await pool.query('DELETE FROM org_otps WHERE org_id=$1', [org_id])
    )
 
 }

const refresh_token_controler = (req, res) => {

      try {
        const refreshToken = req.cookies.refresh_token;
        if (!refreshToken) {
            res.status(401).json({error:"null no refresh token provided"})
        } else {
            jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET, (error, user) => {
                const tokens = jwtTokens(user);
                res.cookie("refresh_token", tokens.refeshToken, {httpOnly:true});
                res.status(200).json({
                    token:tokens.accessToken,
                    user:user.rows[0]
                })
            })    
        }  
      } catch (error) {
        res.status(401).json({error:error.message})
        
      }
      

}

const logout_controler = (req, res, next) => {

    try {
        res.clearCookie("refresh_token");
        res.status(200).json({message:"the refresh token deleted succesfully"})
    } catch (error) {
        res.status(401).json({error:error.message})
    }
}
module.exports = {verfy_otp,user_verify_email,register_controler, login_controler, logout_controler, refresh_token_controler}
