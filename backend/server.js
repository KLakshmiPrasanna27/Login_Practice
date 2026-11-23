require("dotenv").config();
const passwordResetRoutes = require("./routes/passwordResetRoutes");
const express = require("express");
const cors = require("cors");
const pool = require("./config/db");

const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const otpRoutes = require("./routes/otpRoutes");

const app = express();

const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/otp", otpRoutes);
app.use("/api/auth", passwordResetRoutes);
// Test server
app.get("/", (req, res) => {
    res.json({
        message: "Backend server is running"
    });
});

// Test database
app.get("/api/test-db", async (req, res) => {
    try {
        const result = await pool.query("SELECT NOW()");

        res.json({
            message: "Database connected successfully",
            time: result.rows[0].now
        });

    } catch (error) {
        res.status(500).json({
            message: "Database connection failed"
        });
    }
});

// Start server
const startServer = async () => {
    try {
        await pool.query("SELECT NOW()");

        console.log("PostgreSQL connected successfully");

        app.listen(PORT, () => {
            console.log(`Server running on port ${PORT}`);
        });

    } catch (error) {
        console.error("Server startup failed:", error);
    }
};

startServer();