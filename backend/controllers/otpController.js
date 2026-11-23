const pool = require("../config/db");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const verifyOtp = async (req, res) => {
    let client;

    try {
        const { phone, otp } = req.body;

        // Validate mobile number and OTP
        if (typeof phone !== "string" ||
            !/^[0-9]{10}$/.test(phone) ||
            typeof otp !== "string" ||
            !/^[0-9]{6}$/.test(otp)) {

            return res.status(400).json({
                message: "Enter a valid mobile number and OTP"
            });
        }

        client = await pool.connect();

        await client.query("BEGIN");

        // Retrieve OTP record
        const result = await client.query(
            `SELECT *,
                expires_at <= CURRENT_TIMESTAMP AS expired
             FROM otp_verifications
             WHERE phone = $1
             AND purpose = 'login'
             FOR UPDATE`,
            [phone]
        );

        if (result.rows.length === 0) {
            await client.query("ROLLBACK");

            return res.status(404).json({
                message: "OTP not found"
            });
        }

        const otpRecord = result.rows[0];

        // Check whether OTP is already used
        if (otpRecord.is_verified) {
            await client.query("ROLLBACK");

            return res.status(400).json({
                message: "OTP already used"
            });
        }

        // Check OTP expiration
        if (otpRecord.expired) {
            await client.query("ROLLBACK");

            return res.status(400).json({
                message: "OTP expired"
            });
        }

        // Check verification attempts
        if (otpRecord.attempts >= 5) {
            await client.query("ROLLBACK");

            return res.status(429).json({
                message: "Maximum attempts exceeded. Request a new OTP"
            });
        }

        // Compare entered OTP with hashed OTP
        const isMatch = await bcrypt.compare(
            otp,
            otpRecord.otp_hash
        );

        if (!isMatch) {

            await client.query(
                `UPDATE otp_verifications
                 SET attempts = attempts + 1
                 WHERE id = $1`,
                [otpRecord.id]
            );

            await client.query("COMMIT");

            return res.status(400).json({
                message: "Invalid OTP"
            });
        }

        // Retrieve user details
        const userResult = await client.query(
            `SELECT id, full_name, username, email, phone
             FROM users WHERE phone = $1`,
            [phone]
        );

        if (userResult.rows.length === 0) {
            await client.query("ROLLBACK");

            return res.status(404).json({
                message: "User not found"
            });
        }

        const user = userResult.rows[0];

        // Generate JWT token
        const token = jwt.sign(
            {
                id: user.id,
                username: user.username
            },
            process.env.JWT_SECRET,
            { expiresIn: "1h" }
        );

        // Mark OTP as verified
        await client.query(
            `UPDATE otp_verifications
             SET is_verified = TRUE
             WHERE id = $1`,
            [otpRecord.id]
        );

        await client.query("COMMIT");

        return res.status(200).json({
            message: "OTP verified successfully",
            token: token,
            user: user
        });

    } catch (error) {

        if (client) {
            await client.query("ROLLBACK");
        }

        console.error(error);

        return res.status(500).json({
            message: "Internal server error"
        });

    } finally {

        if (client) {
            client.release();
        }
    }
};
module.exports = { verifyOtp };