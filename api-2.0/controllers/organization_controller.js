const pool = require("../helper/db_connect");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const orgJwtMiddleware = require("../middleware/orgJwtMiddleware");
const salt_rounds = 10;
const sendMail = require('../helper/send_email');
const addNtification = require('../helper/add_notification');


const org_register_controler =  async (req, res, next) => {
    const org_name = req.body.org_name
    const org_phone = req.body.org_phone
    const org_email = req.body.org_email
    const org_password = req.body.org_password
    const image = req.files[0]
    const  org_profile = image.path
    console.log(image, org_email, org_name);
    await bcrypt.hash(org_password, salt_rounds).then(
        async hashed => {
            console.log(hashed);
            await pool.query('INSERT INTO issuing_organizations (org_name, email, password, phone, email_verified, pic) VALUES($1,$2,$3,$4,$5,$6) RETURNING *',
           [org_name, org_email, hashed, org_phone, false, org_profile])
                        .then(async org => {
                         
                         const res = await sendMail('JAMIIPASS EMAIL VERIFICATION', `To verify your email, please click the following link: http://localhost:4000/verify/${org.rows[0].org_id}`, org.rows[0].email);
                         if (res) {
                            res.status(201).json({
                                save:true,
                                message:"org created succesfully",
                                org:{
                                    user:org.rows[0]
                                }
                            })
                         }

                            
                        }).catch(error => {
                            res.status(500).json({error:error.message,
                                                  data:"organization wasnt created database problems"})
                        })  
        }
      ).catch(error => {
        res.status(500).json({error:error.message})
      })
    }


const org_verify_email = async (req, res, next) => {
    const verificationToken = req.param.verificationToken;
    if (verificationToken) {
    await  pool.query("UPDATE issuing_organizations SET email_verified = $1  WHERE org_id = $2", [true, verificationToken])
        .then(verfied => {
            res.status(200).json({
                verified: true,
                message:"org email verified succesfully",
                org:{
                    org:verfied.rows[0]
                }
            })
        }).catch(error => {
            res.status(500).json({error:error.message,
                data:"verification failed"})
        })
    }
}





const login_controler = (req, res, next) => {
    const org_email = req.body.org_email
    const org_password = req.body.org_password
     
    pool.query('SELECT * FROM issuing_organizations WHERE email = $1', [org_email])
    .then(async org => {
      
        if (org.rows.length === 0) {
            res.status(200).json({data:"the was no match for the email"}) 
        }else{
           await bcrypt.compare(org_password, org.rows[0].password)
            .then(async doMatch => {
               if (doMatch) {
                const otp = Math.floor(Math.random() * 10000);
                console.log(".............", otp);
                const ress = await sendMail('JAMIIPASS LOGIN ONE TIME PASSWORD', `TO login enter this otp: ${otp}`, org.rows[0].email);
                if (ress) {
                    await pool.query('INSERT INTO org_otps (org_id, otp) VALUES($1,$2) RETURNING *',
                    [org.rows[0].org_id, otp])
                    .then(dat => {

                        res.status(200).json({
                            success:true,
                            message:"succesfully",
                         org:org.rows[0]
                        })
                    })
                   
                }
               } else {
                res.status(200).json({error:"incorreact password login failed"});
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
   const org_id  = req.body.org_id;
   const otp = req.body.otp
   console.log("-------------------", req.body);
   
   await pool.query('SELECT * FROM org_otps WHERE org_id=$1', [org_id])
   .then(
   async org_otp => {
    if (org_otp.rows[0].otp === otp) {
        await pool.query('SELECT * FROM issuing_organizations WHERE org_id=$1', [org_id])
        .then(
            org => {
                 //jwts
                 const tokens = orgJwtMiddleware(org.rows[0]);
                
                 res.cookie("refresh_token", tokens.refeshToken, {httpOnly:true, sameSite:'none', secure:true});
                 res.status(200).json({
                    success:true,
                     token:tokens.accessToken,
                     org:org.rows[0]
                 })
            }
        )
    } else {
        res.status(200).json({
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

const get_all_organizations = async (req, res, next) =>  {
    try {
        await pool.query('SELECT * FROM issuing_organizations')
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

const get_org_info = async (req, res, next) => {
    const org_id = req.user.org_id;
    
    try {
        await pool.query('SELECT * FROM issuing_organizations WHERE org_id=$1', [org_id])
        .then(org =>  {
            res.status(200).json({
                data: org.rows[0],
                success:true
            })
        })
    } catch (error) {
        res.status(401).json({error:error.message})

    }
}

const update_organization = async (req, res) => {
    const { org_id } = req.params;
    const { org_name, email, phone, } = req.body;
  
    try {
      const query = `
        UPDATE issuing_organizations
        SET
          org_name = COALESCE($1, org_name),
          email = COALESCE($2, email),
          phone = COALESCE($4, phone),
        WHERE org_id = $7
        RETURNING *;
      `;
  
      const values = [org_name, email, phone, org_id];
  
      const result = await pool.query(query, values);
  
      if (result.rows.length === 0) {
        return res.status(404).send('Organization not found');
      }
  
      res.status(200).json(result.rows[0]);
    } catch (err) {
      console.error('Error updating organization:', err);
      res.status(500).send('Server error');
    }
  };

const updat_organization_pic = async (req, res) => {
    const { org_id } = req.params;
     const image = req.files[0]
     const  pic = image.path

  
    if (!pic) {
      return res.status(400).send('Picture URL is required');
    }
  
    try {
      const query = `
        UPDATE issuing_organizations
        SET pic = $1
        WHERE org_id = $2
        RETURNING *;
      `;
  
      const values = [pic, org_id];
  
      const result = await pool.query(query, values);
  
      if (result.rows.length === 0) {
        return res.status(404).send('Organization not found');
      }
  
      res.status(200).json(result.rows[0]);
    } catch (err) {
      console.error('Error updating organization picture:', err);
      res.status(500).send('Server error');
    }
  };

  const changeOrganizationPassword = async (req, res) => {
    const { org_id } = req.params;
    const { old_password, new_password } = req.body;
  
    if (!old_password || !new_password) {
      return res.status(400).send('Old and new passwords are required');
    }
  
    try {
     
      const getPasswordQuery = 'SELECT password FROM issuing_organizations WHERE org_id = $1';
      const passwordResult = await pool.query(getPasswordQuery, [org_id]);
  
      if (passwordResult.rows.length === 0) {
        return res.status(404).send('Organization not found');
      }
  
      const currentPasswordHash = passwordResult.rows[0].password;
  
      const isMatch = await bcrypt.compare(old_password, currentPasswordHash);
      if (!isMatch) {
        return res.status(401).send('Old password is incorrect');
      }
  
      const newPasswordHash = await bcrypt.hash(new_password, 10);
  
      const updatePasswordQuery = `
        UPDATE issuing_organizations
        SET password = $1
        WHERE org_id = $2
        RETURNING *;
      `;
      const updatePasswordResult = await pool.query(updatePasswordQuery, [newPasswordHash, org_id]);
  
      res.status(200).json(updatePasswordResult.rows[0]);
    } catch (err) {
      console.error('Error changing password:', err);
      res.status(500).send('Server error');
    }
  };


const create_identification = async (req, res, next) => {
    const org_id = req.user.org_id;
    const cert_name = req.body.cert_name;
    console.log("-----------------", req.body);
   
        await pool.query('INSERT INTO identifications (cert_name, org_id) VALUES($1,$2) RETURNING *',
        [cert_name, org_id])
        .then(
          async id => {
            // await addNtification("organization", {org_id:org_id, notification:"New Identitification created"});
            res.status(200).json({
                data: id.rows[0],
                success:true
            })
           }
        ).catch (error  =>{
            res.status(401).json({error:error.message})
    })
    

}


const get_all_identifications = async (req, res, next) =>  {
    try {
        await pool.query('SELECT * FROM identifications')
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

const create_identification_request = async (req, res, next) => {
    const org_id = req.body.org_id;
    const cert_id = req.body.cert_id;
    const card_no = req.body.card_no;
    const user_id = req.body.user_id;
    const request_state = "Requested"
     
    try {
        await pool.query('INSERT INTO identification_requests (user_id, org_id,card_no, cert_id, request_state ) VALUES($1,$2, $3, $4, $5) RETURNING *',
        [user_id, org_id, card_no, cert_id, request_state])
        .then(
          async request => {
            // await addNtification("organization", {org_id:org_id, notification:"New Identity Request"});
            res.status(200).json({
                data: request.rows,
                success:true
            })
           } 
        )
    } catch (error) {
        res.status(401).json({error:error.message})
    }
}



const get_all_identification_requests = async (req, res, next) =>  {
    const org_id = req.user.org_id;
       const sqlQuery = `
        SELECT 
            ir.*,
            u.*,
            i.*
        FROM 
            identification_requests ir
        JOIN 
            users u ON ir.user_id = u.user_id
        JOIN 
            identifications i ON ir.cert_id = i.cert_id
        WHERE 
            ir.org_id = $1
    `;

    try {
        await pool.query(sqlQuery, [org_id])
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


const get_identification_request = async (req, res, next) =>  {
    console.log("------------------------------");
    const request_id = req.params.id;
    console.log(request_id);
       const sqlQuery = `
        SELECT 
            ir.*,
            u.*,
            i.*
        FROM 
            identification_requests ir
        JOIN 
            users u ON ir.user_id = u.user_id
        JOIN 
            identifications i ON ir.cert_id = i.cert_id
        WHERE 
            ir.id = $1
    `;

    try {
        await pool.query(sqlQuery, [request_id])
        .then(ids =>  {
            console.log(ids);
            res.status(200).json({
                data: ids.rows,
                success:true
            })
        })
    } catch (error) {
        res.status(401).json({error:error.message})
    }

}




const get_organization_notification = async (req, res, next) => {
    const org_id = req.user.org_id;
    try {
        await pool.query('SELECT * FROM organization_notification WHERE org_id=$1', [org_id])
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

const get_organization_identifications = async (req, res, next) => {
    console.log("------------------------------");
    const org_id = req.params.id;
    console.log(org_id);
    try {
        await pool.query('SELECT * FROM identifications WHERE org_id=$1', [org_id])
        .then(corp =>  {
            console.log(corp);
            res.status(200).json({
                data: corp.rows,
                success:true
            })
        })
    } catch (error) {
        res.status(401).json({error:error.message})

    }
}

const update_user_card_request = async (req, res, next) => {
    const id = req.body.id;
    const status= req.body.status;

    const  sqlQuery = ` 
     UPDATE  identification_requests
     SET request_state = $1
     WHERE id = $2
    `
    try {
        await pool.query(sqlQuery, [status,id])
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

const identity_requests_per_mont = async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT 
              EXTRACT(MONTH FROM created_at) AS month, 
              COUNT(*) AS total_requests 
            FROM 
              identification_requests 
            GROUP BY 
              month 
            ORDER BY 
              month;
          `);
      
          // Initialize data array with zeros for all 12 months
          const data = new Array(12).fill(0);
      
          // Populate data array with the results from the query
          result.rows.forEach(row => {
            const month = row.month;
            data[month - 1] = parseInt(row.total_requests);
          });
      
          res.json({ series: [{ name: "Total", data }] });

    } catch (err) {
      console.error(err);
      res.status(500).send('Server error');
    }
  }


const identification_requests_percentage =  async (req, res) => {
    try {
      const orgId = req.params.org_id;
      const result = await pool.query(`
        SELECT 
          identifications.cert_name,
          EXTRACT(MONTH FROM identification_requests.created_at) AS month,
          COUNT(*) AS total_requests
        FROM 
          identification_requests
        JOIN
          identifications
        ON 
          identification_requests.cert_id = identifications.cert_id
        WHERE 
          identification_requests.org_id = $1
        GROUP BY 
          identifications.cert_name, month
        ORDER BY 
          month;
      `, [orgId]);
  
      // Initialize data structure with zeros for all 12 months
      const data = {};
      const totalRequestsPerMonth = new Array(12).fill(0);
  
      result.rows.forEach(row => {
        const month = row.month;
        const cert_name = row.cert_name;
        const total_requests = parseInt(row.total_requests);
  
        if (!data[cert_name]) {
          data[cert_name] = new Array(12).fill(0); // Initialize array for each certificate
        }
  
        data[cert_name][month - 1] = total_requests;
        totalRequestsPerMonth[month - 1] += total_requests;
      });
  
      // Convert counts to percentages
      const series = Object.keys(data).map(cert_name => ({
        name: cert_name,
        data: data[cert_name].map((count, index) => {
          const total = totalRequestsPerMonth[index];
          return total > 0 ? (count / total) * 100 : 0;
        }),
        offsetY: 0,
      }));
  
      res.json({ series });
    } catch (err) {
      console.error(err);
      res.status(500).send('Server error');
    }
  }


  const organization_stats = async (req, res) => {
    try {
      const totalIdentities = await pool.query('SELECT COUNT(*) FROM identifications');
      const totalUsers = await pool.query('SELECT COUNT(*) FROM users');
      const todayShared = await pool.query("SELECT COUNT(*) FROM identification_share_history");
      const inactiveIdentities = await pool.query("SELECT COUNT(*) FROM identification_share_history WHERE active = false");
  
      res.json({
        totalIdentities: totalIdentities.rows[0].count,
        totalUsers: totalUsers.rows[0].count,
        todayShared: todayShared.rows[0].count,
        inactiveIdentities: inactiveIdentities.rows[0].count,
      });
    } catch (err) {
      console.error(err.message);
      res.status(500).send('Server error');
    }
  }


module.exports = {update_user_card_request, get_organization_identifications,
    get_identification_request, get_organization_notification,get_all_identification_requests, 
    get_all_identifications, create_identification_request ,create_identification, get_all_organizations, 
    org_register_controler, login_controler, logout_controler, refresh_token_controler, 
    verfy_otp, org_verify_email, get_org_info, changeOrganizationPassword, 
    updat_organization_pic, update_organization, identity_requests_per_mont, 
    identification_requests_percentage, organization_stats}