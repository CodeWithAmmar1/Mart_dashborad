const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// 1. Connect to MongoDB
mongoose.connect('mongodb+srv://aliammar0342:aliammar0342@backhand.bl5s3.mongodb.net/mart?appName=backhand')
    .then(() => console.log('Connected to Database'))
    .catch(err => console.error(err));
const itemSchema = new mongoose.Schema({
    name: { type: String, unique: true, required: true },
    price: Number,
    stock: { type: Number, default: 0 }
});

const Item = mongoose.model('Item', itemSchema);
const Sell = mongoose.model('sell', itemSchema);

app.post('/api/items/add', async (req, res) => {
    const { name, price, stock } = req.body;
    try {
        const item = await Item.findOneAndUpdate(
            { name: name.toLowerCase() },
            { $inc: { stock: stock }, $set: { price: price } },
            { upsert: true, new: true }
        );
        res.status(200).json(item);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 3. Sell Item (Decrease Logic)
// Add this helper schema for history
const SaleSchema = new mongoose.Schema({
    itemName: String,
    amount: Number,
    date: { type: Date, default: Date.now }
});
const Sale = mongoose.model('Sale', SaleSchema);

app.post('/api/items/sell', async (req, res) => {
    const { name, quantity } = req.body;
    try {
        const item = await Item.findOne({ name: name.toLowerCase() });
        if (!item || item.stock < quantity) return res.status(400).send("No Stock");

        item.stock -= quantity;
        await item.save();

        // Save to sales history
        await Sale.create({ itemName: name, amount: item.price * quantity });

        res.status(200).json(item);
    } catch (err) { res.status(500).json(err); }
});
// Add this to your server.js
app.get('/api/items', async (req, res) => {
    try {
        const items = await Item.find();
        res.status(200).json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Add this in your Node.js backend
app.post('/api/items/delete', async (req, res) => {
    const { name } = req.body;
    await Item.deleteOne({ name: name }); // Assuming you use Mongoose
    res.status(200).send("Deleted");
});
app.listen(3000, () => console.log("Server running on port 3000"));