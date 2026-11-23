const pool = require("../config/db");
const bcrypt = require("bcryptjs");
const generateOTP = require("../utils/otpGenerator");

// Forgot Password
const forgotPassword = async (req, res) => {
    try {
        const { phone } = req.body;

        if (typeof phone !== "string" ||
            !/^[0-9]{10}$/.test(phone)) {
            return res.status(400).json({
                message: "Valid mobile number is required"
            });
        }

        const user = await pool.query(
            "SELECT id FROM users WHERE phone = $1",
            [phone]
        );

        if (user.rows.length > 0) {
            const otp = generateOTP();

            const otpHash = await bcrypt.hash(otp, 10);

            await pool.query(
                `INSERT INTO otp_verifications
                 (phone, otp_hash, expires_at, purpose)
                 VALUES ($1, $2,
                 NOW() + INTERVAL '5 minutes',
                 'password_reset')`,
                [phone, otpHash]
            );

            // Local development only
            console.log("Password Reset OTP:", otp);
        }

        res.status(200).json({
            message: "If the mobile number is registered, an OTP will be generated"
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            message: "Internal server error"
        });
    }
};

// Reset Password
const resetPassword = async (req, res) => {
    let client;

    try {
        const {
            phone,
            otp,
            newPassword,
            confirmPassword
        } = req.body;

        if (typeof phone !== "string" ||
            !/^[0-9]{10}$/.test(phone) ||
            typeof otp !== "string" ||
            !/^[0-9]{6}$/.test(otp) ||
            typeof newPassword !== "string") {

            return res.status(400).json({
                message: "Valid phone, OTP and password are required"
            });
        }

        if (newPassword !== confirmPassword) {
            return res.status(400).json({
                message: "Passwords do not match"
            });
        }

        if (newPassword.length < 8 ||
            Buffer.byteLength(newPassword, "utf8") > 72) {
            return res.status(400).json({
                message: "Password must be at least 8 characters and at most 72 bytes"
            });
        }

        client = await pool.connect();

        await client.query("BEGIN");

        const result = await client.query(
            `SELECT * FROM otp_verifications
             WHERE phone = $1
             AND purpose = 'password_reset'
             ORDER BY id DESC
             LIMIT 1 FOR UPDATE`,
            [phone]
        );

        const record = result.rows[0];

        if (!record ||
            record.is_verified ||
            record.attempts >= 5 ||
            new Date(record.expires_at) <= new Date()) {

            await client.query("ROLLBACK");

            return res.status(400).json({
                message: "OTP invalid or expired"
            });
        }

        const isMatch = await bcrypt.compare(
            otp,
            record.otp_hash
        );

        if (!isMatch) {
            await client.query(
                `UPDATE otp_verifications
                 SET attempts = attempts + 1
                 WHERE id = $1`,
                [record.id]
            );

            await client.query("COMMIT");

            return res.status(400).json({
                message: "Invalid OTP"
            });
        }

        const passwordHash = await bcrypt.hash(
            newPassword, 12
        );

        const updatedUser = await client.query(
            `UPDATE users
             SET password_hash = $1
             WHERE phone = $2`,
            [passwordHash, phone]
        );

        if (updatedUser.rowCount === 0) {
            await client.query("ROLLBACK");

            return res.status(400).json({
                message: "Password reset failed"
            });
        }

        await client.query(
            `UPDATE otp_verifications
             SET is_verified = TRUE
             WHERE phone = $1
             AND purpose = 'password_reset'`,
            [phone]
        );

        await client.query("COMMIT");

        res.status(200).json({
            message: "Password reset successfully"
        });

    } catch (error) {
        if (client) {
            await client.query("ROLLBACK");
        }

        console.error(error);

        res.status(500).json({
            message: "Internal server error"
        });

    } finally {
        if (client) {
            client.release();
        }
    }
};

module.exports = {
    forgotPassword,
    resetPassword
};