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
    // const image = req.files[0]
    const  profile = ""
    const  role = req.body.role
    const email_verified = false

      bcrypt.hash(user_password, salt_rounds).then(
        hashed => {
            console.log(hashed);
           pool.query('INSERT INTO users (first_name, middle_name, last_name, nida_no, email, phone, email_verified, dob, password, profile, gender, role) VALUES($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12) RETURNING *',
           [first_name, middle_name, last_name, nida_no, email, phone, email_verified, dob, hashed, profile,gender, role])
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
            bcrypt.compare(user_password, user.rows[0].password)
            .then( async doMatch => {
               if (doMatch) {
                const otp = Math.floor(Math.random() * 10000);
                console.log("------------", otp);
                const ress = await sendMail('JAMIIPASS LOGIN ONE TIME PASSWORD', `TO login enter this otp: ${otp}`, user.rows[0].email);
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
    console.log("-------------------------------------------------------------",req.body.otp);
    const user_id  = req.body.user_id;
    const otp = req.body.otp

   
    
    await pool.query('SELECT * FROM user_otps WHERE user_id=$1', [user_id])
    .then(
    async user_otp => {
        console.log("==========", user_otp);
     if (user_otp.rows[0].otp === otp) {
         await pool.query('SELECT * FROM users WHERE user_id=$1', [user_id])
         .then(
             user => {
                  //jwts
                  const tokens = jwtTokens(user.rows[0]);
                 
                  res.cookie("refresh_token", tokens.refeshToken, {httpOnly:true, sameSite:'none', secure:true});
                  res.status(200).json({
                      token:tokens.accessToken,
                      user:user.rows[0],
                      success:true,
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
     await pool.query('DELETE FROM user_otps WHERE user_id=$1', [user_id])
    )
 
 }

 const get_all_users = async (req, res, next) =>  {
  try {
      await pool.query('SELECT * FROM users')
      .then(orgs =>  {
          res.status(200).json({
              data: orgs.rows,
              success:true
          })
      })
  } catch (error) {

      res.status(401).json({error:error.message})
  }
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

const get_identification_requests = async (req, res, next) =>  {
    const user_id = req.params.id;
       const sqlQuery = `
        SELECT 
            ir.*,
            u.*,
            o.*,
            i.*
        FROM 
            identification_requests ir
        JOIN 
            users u ON ir.user_id = u.user_id
            JOIN 
            issuing_organizations o ON ir.org_id = o.org_id
        JOIN 
            identifications i ON ir.cert_id = i.cert_id
        WHERE 
            ir.user_id = $1
    `;

    try {
        await pool.query(sqlQuery, [user_id])
        .then(ids =>  {
            res.status(200).json({
                data: ids.rows,
                success:true
            })
        })
    } catch (error) {
        res.status(401).json({error:error.message})
    }

}

const update_user = async (req, res) => {
    const { user_id } = req.params;
    const { email, phone } = req.body;
    console.log("-----------------------------------------------------------------",req.body);
    try {
      const query = `
        UPDATE users
        SET
          email = COALESCE($1, email),
          phone = COALESCE($2, phone)
        WHERE user_id = $3
        RETURNING *;
      `;
  
      const values = [email, phone, user_id];
  
      const result = await pool.query(query, values);
  
      if (result.rows.length === 0) {
        return res.status(404).send('User not found');
      }
  
      res.status(200).json(result.rows[0]);
    } catch (err) {
      console.error('Error updating user:', err);
      res.status(500).send('Server error');
    }
  };
  
 
  const update_user_profile = async (req, res) => {
    const { user_id } = req.params;
    const image = req.files ? req.files[0] : null;

    console.log("----------------------------------------------------------",image);
    console.log("-------------------------------------------------------------",req.body);
     const  profile = image.path
  
    if (!profile) {
      return res.status(400).send('Profile URL is required');
    }
  
    try {
      const query = `
        UPDATE users
        SET profile = $1
        WHERE user_id = $2
        RETURNING *;
      `;
  
      const values = [profile, user_id];
  
      const result = await pool.query(query, values);
  
      if (result.rows.length === 0) {
        return res.status(404).send('User not found');
      }
  
      res.status(200).json({"user":result.rows[0], "success":true});
    } catch (err) {
      console.error('Error updating user profile:', err);
      res.status(500).send('Server error');
    }
  };
  
  const change_user_password = async (req, res) => {
    const { user_id } = req.params;
    const { old_password, new_password } = req.body;
  
    if (!old_password || !new_password) {
      return res.status(400).send('Old and new passwords are required');
    }
  
    try {
      const getPasswordQuery = 'SELECT password FROM users WHERE user_id = $1';
      const passwordResult = await pool.query(getPasswordQuery, [user_id]);
  
      if (passwordResult.rows.length === 0) {
        return res.status(404).send('User not found');
      }
  
      const currentPasswordHash = passwordResult.rows[0].password;

      const isMatch = await bcrypt.compare(old_password, currentPasswordHash);
      if (!isMatch) {
        return res.status(401).send('Old password is incorrect');
      }
  

      const newPasswordHash = await bcrypt.hash(new_password, 10);
  
      const updatePasswordQuery = `
        UPDATE users
        SET password = $1
        WHERE user_id = $2
        RETURNING *;
      `;
      const updatePasswordResult = await pool.query(updatePasswordQuery, [newPasswordHash, user_id]);
  
      res.status(200).json(updatePasswordResult.rows[0]);
    } catch (err) {
      console.error('Error changing password:', err);
      res.status(500).send('Server error');
    }
  };

//   SELECT ih.*, u.email, c.*
// FROM identification_share_history ih
// JOIN users u ON ih.user_id = u.user_id
// JOIN corporates c ON ih.corp_id = c.corp_id
// WHERE ih.user_id = '784e1f62-110b-4bfa-86e6-2e56ee982f47';


const user_identity_shares_history = async (req, res, next) => {
  const user_id = req.user.user_id;
  console.log(user_id);

  const sqlQuery = `
  SELECT 
      ih.*,
      u.email,
      c.*
  FROM  
      identification_share_history ih
  JOIN 
      users u ON ih.user_id = u.user_id
  JOIN 
      corporates c ON ih.corp_id = c.corp_id
  WHERE 
      ih.user_id = $1
`;
  try {
      await pool.query(sqlQuery, [user_id])
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


const user_home_stats = async (req, res) => {
  let user_id = req.query.user_id;
  const sqlQuery = `
  SELECT count(*) FROM identification_requests WHERE user_id=$1
  `
   
  try {

     await pool.query(sqlQuery, [user_id])
      .then(stats =>  {
          res.status(200).json({
              data: stats.rows,
              success:true
          })
      })
  } catch (error) {
    res.status(401).json({error:error.message})
  }
}



const delete_identity_share = async (req, res) => {
    let user_id = req.query.user_id;
    let delete_id = req.query.delete_id
    console.log("-----------------------------------------------------------------",req.body);
    try {
      const query = `
        DELETE FROM 
        identification_share_history
        WHERE (corp_id = $1 OR user_share = $1) AND user_id = $2 
        RETURNING *;
      `;
  
      const values = [delete_id, user_id];
  
      const result = await pool.query(query, values);
      console.log(result);
  
    //   if (result.rowCount ) {
    //     return res.status(404).send('User not found');
    //   }
  
      res.status(200).json({success:true});
    } catch (err) {
      console.error('Error updating user:', err);
      res.status(500).send('Server error');
    }
  };


 
module.exports = {delete_identity_share,get_all_users, verfy_otp,user_verify_email,register_controler,user_identity_shares_history, login_controler, logout_controler, refresh_token_controler, get_identification_requests, change_user_password, update_user, update_user_profile, user_home_stats}
