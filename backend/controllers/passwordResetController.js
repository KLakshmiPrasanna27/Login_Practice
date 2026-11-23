const pool = require("../config/db");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");

// Forgot Password - Generate OTP

const forgotPassword = async (req, res) => {
    try {

        console.log("\nForgot Password API called");

        const { phone } = req.body;

        // Validate mobile number
        if (typeof phone !== "string" || !/^\d{10}$/.test(phone)) {

            console.log("Invalid mobile number format");

            return res.status(400).json({
                message: "Enter a valid mobile number"
            });
        }

        console.log("Mobile number validation successful");

        // Check whether user exists
        const result = await pool.query(
            "SELECT id FROM users WHERE phone = $1",
            [phone]
        );

        console.log("Users found:", result.rows.length);

        const successMessage =
            "If the mobile number is registered, an OTP will be sent";

        if (result.rows.length === 0) {

            console.log("Mobile number not registered");

            return res.status(200).json({
                message: successMessage
            });
        }

        const userId = result.rows[0].id;

        console.log("User ID:", userId);

        // Generate 6-digit OTP
        const otp = crypto.randomInt(100000, 1000000).toString();

        console.log("OTP generation successful");

        // Hash the OTP
        const otpHash = await bcrypt.hash(otp, 10);

        // Set expiration time to 5 minutes
        const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

        // Store OTP with a 60-second resend cooldown
        const saved = await pool.query(
            `INSERT INTO password_reset_otps
            (user_id, otp_hash, expires_at)
            VALUES ($1, $2, $3)

            ON CONFLICT (user_id)

            DO UPDATE SET
                otp_hash = EXCLUDED.otp_hash,
                expires_at = EXCLUDED.expires_at,
                is_verified = FALSE,
                attempts = 0,
                reset_token_hash = NULL,
                reset_token_expires_at = NULL,
                created_at = CURRENT_TIMESTAMP

            WHERE password_reset_otps.created_at
                <= CURRENT_TIMESTAMP - INTERVAL '60 seconds'

            RETURNING id`,

            [userId, otpHash, expiresAt]
        );

        console.log("OTP rows affected:", saved.rowCount);

        // Display OTP for local development only
        if (saved.rowCount > 0) {

            console.log("OTP stored successfully");
            console.log("Password Reset OTP:", otp);
            console.log("OTP expires at:", expiresAt);

        } else {

            console.log("OTP not stored");
            console.log("Please wait 60 seconds before requesting another OTP");

        }

        return res.status(200).json({
            message: successMessage
        });

    } catch (error) {

        console.error("Forgot Password Error:", error);

        return res.status(500).json({
            message: "Internal server error"
        });

    }
};


// Verify Password Reset OTP

const verifyResetOtp = async (req, res) => {

    try {

        console.log("\nVerify Reset OTP API called");

        const { phone, otp } = req.body;

        // Validate input
        if (
            typeof phone !== "string" ||
            !/^\d{10}$/.test(phone) ||
            typeof otp !== "string" ||
            !/^\d{6}$/.test(otp)
        ) {
            return res.status(400).json({
                message: "Enter a valid mobile number and OTP"
            });
        }

        // Find the password reset OTP
        const result = await pool.query(
            `SELECT p.*
             FROM password_reset_otps p
             JOIN users u ON p.user_id = u.id
             WHERE u.phone = $1`,
            [phone]
        );

        if (result.rows.length === 0) {
            return res.status(400).json({
                message: "Invalid or expired OTP"
            });
        }

        const record = result.rows[0];

        // Check OTP expiration
        if (new Date(record.expires_at) <= new Date()) {
            return res.status(400).json({
                message: "OTP expired. Please request a new OTP"
            });
        }

        // Check whether OTP is already verified
        if (record.is_verified) {
            return res.status(400).json({
                message: "OTP already verified"
            });
        }

        // Allow only 5 verification attempts
        const attempt = await pool.query(
            `UPDATE password_reset_otps
             SET attempts = attempts + 1
             WHERE id = $1
             AND attempts < 5
             AND is_verified = FALSE
             AND expires_at > NOW()
             AND otp_hash = $2
             RETURNING id`,
            [record.id, record.otp_hash]
        );

        if (attempt.rowCount === 0) {
            return res.status(429).json({
                message: "Request a new OTP"
            });
        }

        // Compare OTP with stored hash
        const isValid = await bcrypt.compare(
            otp,
            record.otp_hash
        );

        if (!isValid) {

            console.log("OTP verification failed");

            return res.status(400).json({
                message: "Invalid OTP"
            });
        }

        // Generate a secure password reset token
        const resetToken = crypto
            .randomBytes(32)
            .toString("hex");

        // Hash reset token
        const resetTokenHash = crypto
            .createHash("sha256")
            .update(resetToken)
            .digest("hex");

        // Reset token expires after 10 minutes
        const resetTokenExpiresAt = new Date(
            Date.now() + 10 * 60 * 1000
        );

        // Update OTP verification status
        const verified = await pool.query(
            `UPDATE password_reset_otps
             SET is_verified = TRUE,
                 reset_token_hash = $1,
                 reset_token_expires_at = $2
             WHERE id = $3
             AND is_verified = FALSE
             AND expires_at > NOW()
             AND otp_hash = $4`,
            [
                resetTokenHash,
                resetTokenExpiresAt,
                record.id,
                record.otp_hash
            ]
        );

        if (verified.rowCount === 0) {
            return res.status(400).json({
                message: "OTP is no longer valid"
            });
        }

        console.log("Password Reset OTP verified successfully");
        console.log("Reset token generated successfully");

        return res.status(200).json({
            message: "OTP verified successfully",
            resetToken: resetToken
        });

    } catch (error) {

        console.error("Verify Reset OTP Error:", error);

        return res.status(500).json({
            message: "Internal server error"
        });

    }
};


// Reset Password

const resetPassword = async (req, res) => {

    try {

        console.log("\nReset Password API called");

        const { resetToken, newPassword, confirmPassword } = req.body;

        // Validate required fields
        if (!resetToken || !newPassword || !confirmPassword) {
            return res.status(400).json({
                message: "All fields are required"
            });
        }

        // Validate reset token format
        if (
            typeof resetToken !== "string" ||
            !/^[a-f0-9]{64}$/.test(resetToken)
        ) {
            return res.status(400).json({
                message: "Invalid reset token"
            });
        }

        // Validate password length
        if (
            typeof newPassword !== "string" ||
            newPassword.length < 8 ||
            Buffer.byteLength(newPassword, "utf8") > 72
        ) {
            return res.status(400).json({
                message: "Password must contain at least 8 characters and at most 72 bytes"
            });
        }

        // Check whether passwords match
        if (newPassword !== confirmPassword) {
            return res.status(400).json({
                message: "Passwords do not match"
            });
        }

        // Hash the received reset token
        const resetTokenHash = crypto
            .createHash("sha256")
            .update(resetToken)
            .digest("hex");

        // Hash the new password
        const passwordHash = await bcrypt.hash(newPassword, 10);

        // Consume reset token and update password atomically
        const result = await pool.query(
            `WITH valid_reset AS (
                DELETE FROM password_reset_otps
                WHERE reset_token_hash = $1
                AND is_verified = TRUE
                AND reset_token_expires_at > NOW()
                RETURNING user_id
            )

            UPDATE users
            SET password_hash = $2
            WHERE id IN (
                SELECT user_id FROM valid_reset
            )
            RETURNING id`,

            [resetTokenHash, passwordHash]
        );

        // Check whether password was updated
        if (result.rowCount === 0) {

            console.log("Invalid or expired reset token");

            return res.status(400).json({
                message: "Invalid or expired reset token"
            });
        }

        console.log("Password reset successfully");

        return res.status(200).json({
            message: "Password reset successfully"
        });

    } catch (error) {

        console.error("Reset Password Error:", error);

        return res.status(500).json({
            message: "Internal server error"
        });

    }
};

module.exports = {
    forgotPassword,
    verifyResetOtp,
    resetPassword
};