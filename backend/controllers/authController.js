const pool = require("../config/db");
const bcrypt = require("bcryptjs");
const generateLoginOtp = require("../utils/loginOtp");

// ================= REGISTRATION =================

const register = async (req, res) => {
    try {
        const { full_name, username, email, phone, password } = req.body;

        // Validate required fields
        if (![full_name, username, email, phone, password]
            .every(value => typeof value === "string" && value.trim())) {
            return res.status(400).json({
                message: "All fields are required"
            });
        }

        // Validate email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(email)) {
            return res.status(400).json({
                message: "Invalid email address"
            });
        }

        // Validate mobile number
        if (!/^[0-9]{10}$/.test(phone)) {
            return res.status(400).json({
                message: "Enter a valid 10-digit mobile number"
            });
        }

        // Validate password
        if (password.length < 8 ||
            Buffer.byteLength(password, "utf8") > 72) {
            return res.status(400).json({
                message: "Password must be at least 8 characters and at most 72 bytes"
            });
        }

        // Check whether the user already exists
        const existingUser = await pool.query(
            `SELECT id FROM users
             WHERE username = $1 OR email = $2 OR phone = $3`,
            [username, email, phone]
        );

        if (existingUser.rows.length > 0) {
            return res.status(409).json({
                message: "User already exists"
            });
        }

        // Hash the password
        const password_hash = await bcrypt.hash(password, 12);

        // Store user details in PostgreSQL
        const result = await pool.query(
            `INSERT INTO users
             (full_name, username, email, phone, password_hash)
             VALUES ($1, $2, $3, $4, $5)
             RETURNING id, full_name, username, email, phone`,
            [full_name, username, email, phone, password_hash]
        );

        return res.status(201).json({
            message: "Registration successful",
            user: result.rows[0]
        });

    } catch (error) {

        if (error.code === "23505") {
            return res.status(409).json({
                message: "User already exists"
            });
        }

        console.error(error);

        return res.status(500).json({
            message: "Internal server error"
        });
    }
};


// ================= LOGIN =================

const login = async (req, res) => {
    try {
        const { username, password, phone } = req.body;
   
        // Validate input
        if (typeof username !== "string" ||
            !username.trim() ||
            typeof password !== "string" ||
            !password ||
            Buffer.byteLength(password, "utf8") > 72 ||
            typeof phone !== "string" ||
            !/^[0-9]{10}$/.test(phone)) {

            return res.status(400).json({
                message: "Valid username, password and phone number are required"
            });
        }

        // Confirm that the credentials and phone number belong to the same user.
        const result = await pool.query(
            "SELECT id, phone, password_hash FROM users WHERE username = $1",
            [username]
        );

        if (result.rows.length === 0) {
            return res.status(401).json({
                message: "Invalid username, password or phone number"
            });
        }

        const user = result.rows[0];
        const isMatch = await bcrypt.compare(
            password,
            user.password_hash
        );

        if (!isMatch || user.phone !== phone) {
            return res.status(401).json({
                message: "Invalid username, password or phone number"
            });
        }

        if (process.env.NODE_ENV === "production") {
            return res.status(503).json({
                message: "OTP delivery is not configured"
            });
        }

        const otp = await generateLoginOtp(phone);

        if (otp === null) {
            return res.status(429).json({
                message: "Wait 60 seconds before requesting another OTP"
            });
        }

        // Local development only; use an SMS provider for production delivery.
        console.log("Generated OTP:", otp);
        return res.status(200).json({
            message: "OTP generated successfully",
            expiresIn: 300
        });

    } catch (error) {

        console.error(error);

        return res.status(500).json({
            message: "Internal server error"
        });
    }
};

module.exports = { register, login };