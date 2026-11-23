const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

const {
    getProfile,
    updateProfile,
    deleteAccount
} = require("../controllers/userController");

// Read
router.get("/profile", authMiddleware, getProfile);

// Update
router.put("/profile", authMiddleware, updateProfile);

// Delete
router.delete("/profile", authMiddleware, deleteAccount);

module.exports = router;