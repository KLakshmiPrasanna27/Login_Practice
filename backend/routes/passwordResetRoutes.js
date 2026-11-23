const express = require("express");

const router = express.Router();

const {
    forgotPassword,
    verifyResetOtp,
    resetPassword
} = require("../controllers/passwordResetController");

// Generate Password Reset OTP
router.post("/forgot-password", forgotPassword);

// Verify Password Reset OTP
router.post("/verify-reset-otp", verifyResetOtp);

// Reset Password
router.post("/reset-password", resetPassword);

module.exports = router;