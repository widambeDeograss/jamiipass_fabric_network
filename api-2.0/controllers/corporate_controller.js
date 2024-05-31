const pool = require("../helper/db_connect");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const orgJwtMiddleware = require("../middleware/orgJwtMiddleware");
const corpJwtMiddleware = require("../middleware/corpJwtMiddleware");
const salt_rounds = 10;
const sendMail = require('../helper/send_email');
const addNtification = require('../helper/add_notification');


const corp_register_controler =  async (req, res, next) => {
    console.log(req.body);
    const corp_name = req.body.corp_name
    const corp_phone = req.body.corp_phone
    const corp_email = req.body.corp_email
    const corp_password = req.body.corp_password
    // const image = req?.files[0]
    // const  corp_profile = image.path
    
    await bcrypt.hash(corp_password, salt_rounds).then(
        async hashed => {
            console.log(hashed);
            await pool.query('INSERT INTO corporates (corp_name, email, password, phone, email_verified, pic) VALUES($1,$2,$3,$4,$5,$6) RETURNING *',
           [corp_name, corp_email, hashed, corp_phone, false, ""])
                        .then(async corp => {
                         
                         const emailRes = await sendMail('JAMIIPASS EMAIL VERIFICATION', `To verify your email, please click the following link: http://localhost:4000/verify/${corp.rows[0].corp_id}`, corp.rows[0].email);
                         if (emailRes) {
                            res.status(200).json({
                                save:true,
                                message:"corp created succesfully",
                                corp:{
                                    corp:corp.rows[0]
                                }
                            })
                         }

                            
                        }).catch(error => {
                            res.status(500).json({error:error.message,
                                                  data:"corporate wasnt name, email or phone already exist"})
                        })  
        }
      ).catch(error => {
        res.status(500).json({error:error.message})
      })
    }


const corp_verify_email = async (req, res, next) => {
    const verificationToken = req.param.verificationToken;
    if (verificationToken) {
    await  pool.query("UPDATE corporates SET email_verified = $1  WHERE corp_id = $2", [true, verificationToken])
        .then(verfied => {
            res.status(200).json({
                verified: true,
                message:"org email verified succesfully",
                corp:{
                    corp:verfied.rows[0]
                }
            })
        }).catch(error => {
            res.status(500).json({error:error.message,
                data:"verification failed"})
        })
    }
}



const login_controler = (req, res, next) => {
    const corp_email = req.body.corp_email
    const corp_password = req.body.corp_password
    

    pool.query('SELECT * FROM corporates WHERE email = $1', [corp_email])
    .then(async corp => {
        if (corp.rows.length === 0) {
            res.status(401).json({data:"the was no match for the email"}) 
        }else{
           await bcrypt.compare(corp_password, corp.rows[0].password)
            .then(async doMatch => {
               if (doMatch) {
                const otp = Math.floor(Math.random() * 10000);
                console.log("----------------corpOtp", otp);
                // const ress = await sendMail('JAMIIPASS LOGIN ONE TIME PASSWORD', `TO login enter this otp: ${otp}`, corp.rows[0].email);
                if (otp) {
                    await pool.query('INSERT INTO corp_otps (corp_id, otp) VALUES($1,$2) RETURNING *',
                    [corp.rows[0].corp_id, otp])
                    .then(dat => {
                        res.status(200).json({
                            success:true,
                            message:"succesfully",
                         corp:corp.rows[0]
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

const verfy_otp =async (req, res, next) => {
   const corp_id  = req.body.corp_id;
   const otp = req.body.otp;
   console.log(otp);
   
   await pool.query('SELECT * FROM corp_otps WHERE corp_id=$1', [corp_id])
   .then(
   async corp_otp => {
    if (corp_otp.rows[0]?.otp === otp) {
        await pool.query('SELECT * FROM corporates WHERE corp_id=$1', [corp_id])
        .then(
            corp => {
                 //jwts
                 const tokens = corpJwtMiddleware(corp.rows[0]);
                
                 res.cookie("refresh_token", tokens.refeshToken, {httpOnly:true, sameSite:'none', secure:true});
                 res.status(200).json({
                    success:true,
                     token:tokens.accessToken,
                     corp:corp.rows[0]
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
    console.log(error);
    res.status(500).json({error:"server error"})
   })
   .finally(
    await pool.query('DELETE FROM corp_otps WHERE corp_id=$1', [corp_id])
   )

}

const refresh_token_controler = (req, res) => {

      try {
        const refreshToken = req.cookies.refresh_token;
        if (!refreshToken) {
            res.status(401).json({error:"null no refresh token provided"})
        } else {
            jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET, (error, corp) => {
                const tokens = corpJwtMiddleware(corp);
                res.cookie("refresh_token", tokens.refeshToken, {httpOnly:true});
                res.status(200).json({
                    token:tokens.accessToken,
                    corp:corp.rows[0]
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

const get_all_corporatess = async (req, res, next) =>  {
    try {
        await pool.query('SELECT * FROM corporates')
        .then(corps =>  {
            res.status(200).json({
                data: corps.rows,
                success:true
            })
        })
    } catch (error) {

        res.status(401).json({error:error.message})
    }
}

const get_corp_info = async (req, res, next) => {
    const corp_id = req.user.corp_id;
    try {
        await pool.query('SELECT * FROM corporates WHERE corp_id=$1', [corp_id])
        .then(corp =>  {
            res.status(200).json({
                data: corp.rows[0],
                success:true
            })
        })
    } catch (error) {
        res.status(401).json({error:error.message})

    }
}

const update_corporate = async (req, res) => {
    const { corp_id } = req.params;
    const { corp_name, email, phone } = req.body;
  
    try {
      const query = `
        UPDATE corporates
        SET
          corp_name = COALESCE($1, corp_name),
          email = COALESCE($2, email),
          phone = COALESCE($3, phone),
        WHERE corp_id = $6
        RETURNING *;
      `;
  
      const values = [corp_name, email, phone, corp_id];
  
      const result = await pool.query(query, values);
  
      if (result.rows.length === 0) {
        return res.status(404).send('Corporate not found');
      }
  
      res.status(200).json(result.rows[0]);
    } catch (err) {
      console.error('Error updating corporate:', err);
      res.status(500).send('Server error');
    }
  };

const change_corporate_password = async (req, res) => {
    const { corp_id } = req.params;
    const { old_password, new_password } = req.body;
  
    if (!old_password || !new_password) {
      return res.status(400).send('Old and new passwords are required');
    }
  
    try {
      const getPasswordQuery = 'SELECT password FROM corporates WHERE corp_id = $1';
      const passwordResult = await pool.query(getPasswordQuery, [corp_id]);
  
      if (passwordResult.rows.length === 0) {
        return res.status(404).send('Corporate not found');
      }
  
      const currentPasswordHash = passwordResult.rows[0].password;
  
      const isMatch = await bcrypt.compare(old_password, currentPasswordHash);
      if (!isMatch) {
        return res.status(401).send('Old password is incorrect');
      }
  
      const newPasswordHash = await bcrypt.hash(new_password, 10);
  
      const updatePasswordQuery = `
        UPDATE corporates
        SET password = $1
        WHERE corp_id = $2
        RETURNING *;
      `;
      const updatePasswordResult = await pool.query(updatePasswordQuery, [newPasswordHash, corp_id]);
  
      res.status(200).json(updatePasswordResult.rows[0]);
    } catch (err) {
      console.error('Error changing password:', err);
      res.status(500).send('Server error');
    }
  };

  const update_corporate_pic = async (req, res) => {
    const { corp_id } = req.params;
    const image = req.files[0]
     const  pic = image.path
  
    if (!pic) {
      return res.status(400).send('Picture URL is required');
    }
  
    try {
      const query = `
        UPDATE corporates
        SET pic = $1
        WHERE corp_id = $2
        RETURNING *;
      `;
  
      const values = [pic, corp_id];
  
      const result = await pool.query(query, values);
  
      if (result.rows.length === 0) {
        return res.status(404).send('Corporate not found');
      }
  
      res.status(200).json(result.rows[0]);
    } catch (err) {
      console.error('Error updating corporate picture:', err);
      res.status(500).send('Server error');
    }
  };

const create_identity_share = async (req, res, next) =>{
    const user_id = req.body.user_id
    const corp_id = req.body.corp_id
    const shared_hash = req.body.shared_hash
    const cards = req.body.cards
    const time_before_corrupt = req.body.time_before_corrupt

    await pool.query('INSERT INTO identification_share_history (user_id, corp_id, shared_hash, cards, time_before_corrupt ) VALUES($1,$2, $3, $4, $5) RETURNING *',
    [user_id, corp_id, shared_hash,cards, time_before_corrupt])
    .then(
      async request => {
        await addNtification("corporate", {corp_id:corp_id, notification:"New Identity shared"});
        res.status(200).json({
            data: request.rows[0],
            success:true
        })
       } 
    ).catch(
        error => {
            res.status(401).json({error:error.message})

        }
    )

}

const corp_identity_shares_history = async (req, res, next) => {
    const corp_id = req.user.corp_id;

    const sqlQuery = `
    SELECT 
        ih.*,
        u.*
    FROM  
        identification_share_history ih
    JOIN 
        users u ON ih.user_id = u.user_id
    WHERE 
        ih.corp_id = $1
`;
    try {
        await pool.query(sqlQuery, [corp_id])
        .then(corp =>  {
            res.status(200).json({
                data: corp.rows,
                success:true
            })
        })
    } catch (error) {
        res.status(401).json({error:error.message})

    }
    
}

const corp_identity_share = async (req, res, next) => {
    const share_id = req.params.id;
    console.log("--------------", req.params.id);
    const sqlQuery = `
    SELECT 
        ih.*,
        u.*
    FROM  
        identification_share_history ih
    JOIN 
        users u ON ih.user_id = u.user_id
    WHERE 
        ih.id = $1
`;
    try {
        await pool.query(sqlQuery, [share_id])
        .then(dat =>  {
            res.status(200).json({
                data: dat.rows[0],
                success:true
            })
        })
    } catch (error) {
        res.status(401).json({error:error.message})

    }
    
}


const get_corporate_notification = async (req, res, next) => {
    const corp_id = req.user.corp_id;
    try {
        await pool.query('SELECT * FROM corporate_notification WHERE corp_id=$1', [corp_id])
        .then(corp =>  {
            res.status(200).json({
                data: corp.rows,
                success:true
            })
        })
    } catch (error) {
        res.status(401).json({error:error.message})

    }
}
module.exports = {corp_identity_shares_history, corp_identity_share, create_identity_share, get_all_corporatess, corp_register_controler, login_controler, logout_controler, refresh_token_controler, verfy_otp, corp_verify_email, get_corp_info, get_corporate_notification, update_corporate, update_corporate_pic,change_corporate_password}