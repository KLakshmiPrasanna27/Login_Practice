const pool = require("../config/db");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");

const generateLoginOtp = async (phone) => {
    const otp = crypto.randomInt(100000, 1000000).toString();
    const otpHash = await bcrypt.hash(otp, 12);
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    const result = await pool.query(
        `INSERT INTO otp_verifications
            (phone, otp_hash, expires_at, purpose)
         VALUES ($1, $2, $3, 'login')
         ON CONFLICT (phone)
         DO UPDATE SET
            otp_hash = EXCLUDED.otp_hash,
            expires_at = EXCLUDED.expires_at,
            purpose = EXCLUDED.purpose,
            attempts = 0,
            is_verified = FALSE,
            created_at = CURRENT_TIMESTAMP
         WHERE otp_verifications.created_at
            <= CURRENT_TIMESTAMP - INTERVAL '60 seconds'
         RETURNING id`,
        [phone, otpHash, expiresAt]
    );

    return result.rowCount === 0 ? null : otp;
};

module.exports = generateLoginOtp;
