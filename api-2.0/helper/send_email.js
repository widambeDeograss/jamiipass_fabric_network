const nodemailer = require('nodemailer');

require('dotenv').config();

const sendMail = async (subject,message, email) => {
    try {
        console.log(subject, message, email);
    
        // Create a Nodemailer transporter using SMTP
        const transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
              user: process.env.EMAIL_USER,
              pass: process.env.EMAIL_PASSWORD
            }
          });
    
        // Define email options
        const mailOptions = {
          from: process.env.EMAIL_USER,
          to: email,
          subject: subject,
          text: message
        };
    
        // Send email
        await transporter.sendMail(mailOptions);
    
        return true;
      } catch (error) {
         return false;
        
      }

}

module.exports = sendMail;