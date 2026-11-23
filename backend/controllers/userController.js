const pool = require("../config/db");

// ================= GET PROFILE =================

const getProfile = async (req, res) => {
    try {
        const userId = req.user.id;

        const result = await pool.query(
            `SELECT id, full_name, username,
                    email, phone, created_at
             FROM users WHERE id = $1`,
            [userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                message: "User not found"
            });
        }

        return res.status(200).json({
            message: "Profile retrieved successfully",
            user: result.rows[0]
        });

    } catch (error) {
        console.error(error);

        return res.status(500).json({
            message: "Internal server error"
        });
    }
};


// ================= UPDATE PROFILE =================

const updateProfile = async (req, res) => {
    try {
        const userId = req.user.id;

        const { full_name, username, email, phone } = req.body;

        // Validate required fields
        if (![full_name, username, email, phone]
            .every(value => typeof value === "string" && value.trim())) {

            return res.status(400).json({
                message: "All fields are required"
            });
        }

        // Validate email
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            return res.status(400).json({
                message: "Invalid email address"
            });
        }

        // Validate phone number
        if (!/^[0-9]{10}$/.test(phone)) {
            return res.status(400).json({
                message: "Invalid mobile number"
            });
        }

        // Update user details
        const result = await pool.query(
            `UPDATE users
             SET full_name = $1,
                 username = $2,
                 email = $3,
                 phone = $4
             WHERE id = $5
             RETURNING id, full_name, username, email, phone`,
            [full_name, username, email, phone, userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                message: "User not found"
            });
        }

        return res.status(200).json({
            message: "Profile updated successfully",
            user: result.rows[0]
        });

    } catch (error) {

        if (error.code === "23505") {
            return res.status(409).json({
                message: "Username, email or phone already exists"
            });
        }

        console.error(error);

        return res.status(500).json({
            message: "Internal server error"
        });
    }
};


// ================= DELETE ACCOUNT =================

const deleteAccount = async (req, res) => {
    try {
        const userId = req.user.id;

        const result = await pool.query(
            "DELETE FROM users WHERE id = $1 RETURNING id",
            [userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                message: "User not found"
            });
        }

        return res.status(200).json({
            message: "Account deleted successfully"
        });

    } catch (error) {
        console.error(error);

        return res.status(500).json({
            message: "Internal server error"
        });
    }
};

module.exports = {
    getProfile,
    updateProfile,
    deleteAccount
};