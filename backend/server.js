// const express = require('express');
// const mongoose = require('mongoose');
// const cors = require('cors');

// const app = express();
// app.use(cors());
// app.use(express.json());

// // 1. Connect to MongoDB
// mongoose.connect('mongodb+srv://aliammar0342:aliammar0342@backhand.bl5s3.mongodb.net/mart?appName=backhand')
//     .then(() => console.log('Connected to Database'))
//     .catch(err => console.error(err));
// const itemSchema = new mongoose.Schema({
//     name: { type: String, unique: true, required: true },
//     price: Number,
//     stock: { type: Number, default: 0 }
// });

// const Item = mongoose.model('Item', itemSchema);
// const Sell = mongoose.model('sell', itemSchema);

// app.post('/api/items/add', async (req, res) => {
//     const { name, price, stock } = req.body;
//     try {
//         const item = await Item.findOneAndUpdate(
//             { name: name.toLowerCase() },
//             { $inc: { stock: stock }, $set: { price: price } },
//             { upsert: true, new: true }
//         );
//         res.status(200).json(item);
//     } catch (err) {
//         res.status(500).json({ error: err.message });
//     }
// });

// // 3. Sell Item (Decrease Logic)
// // Add this helper schema for history
// const SaleSchema = new mongoose.Schema({
//     itemName: String,
//     amount: Number,
//     date: { type: Date, default: Date.now }
// });
// const Sale = mongoose.model('Sale', SaleSchema);

// app.post('/api/items/sell', async (req, res) => {
//     const { name, quantity } = req.body;
//     try {
//         const item = await Item.findOne({ name: name.toLowerCase() });
//         if (!item || item.stock < quantity) return res.status(400).send("No Stock");

//         item.stock -= quantity;
//         await item.save();

//         // Save to sales history
//         await Sale.create({ itemName: name, amount: item.price * quantity });

//         res.status(200).json(item);
//     } catch (err) { res.status(500).json(err); }
// });
// // Add this to your server.js
// app.get('/api/items', async (req, res) => {
//     try {
//         const items = await Item.find();
//         res.status(200).json(items);
//     } catch (err) {
//         res.status(500).json({ error: err.message });
//     }
// });

// // Add this in your Node.js backend
// app.post('/api/items/delete', async (req, res) => {
//     const { name } = req.body;
//     await Item.deleteOne({ name: name }); // Assuming you use Mongoose
//     res.status(200).send("Deleted");
// });
// app.listen(3000, () => console.log("Server running on port 3000"));

// const express = require('express');
// const mongoose = require('mongoose');
// const cors = require('cors');
// require('dotenv').config(); // Load variables from Railway

// const app = express();
// app.use(cors());
// app.use(express.json());

// // 1. Updated Connection (Uses Railway Variables)
// const mongoURI = process.env.MONGO_URL || 'mongodb+srv://aliammar0342:aliammar0342@backhand.bl5s3.mongodb.net/mart?appName=backhand';

// mongoose.connect(mongoURI)
//     .then(() => console.log('Connected to MongoDB via Railway'))
//     .catch(err => console.error('Connection Error:', err));

// // --- SCHEMAS ---
// const itemSchema = new mongoose.Schema({
//     name: { type: String, unique: true, required: true },
//     price: Number,
//     stock: { type: Number, default: 0 }
// });

// const Item = mongoose.model('Item', itemSchema);

// const SaleSchema = new mongoose.Schema({
//     itemName: String,
//     amount: Number,
//     date: { type: Date, default: Date.now }
// });
// const Sale = mongoose.model('Sale', SaleSchema);

// // --- ROUTES ---

// app.get('/api/items', async (req, res) => {
//     try {
//         const items = await Item.find();
//         res.status(200).json(items);
//     } catch (err) {
//         res.status(500).json({ error: err.message });
//     }
// });

// app.post('/api/items/add', async (req, res) => {
//     const { name, price, stock } = req.body;
//     try {
//         const item = await Item.findOneAndUpdate(
//             { name: name.toLowerCase() },
//             { $inc: { stock: stock }, $set: { price: price } },
//             { upsert: true, new: true }
//         );
//         res.status(200).json(item);
//     } catch (err) {
//         res.status(500).json({ error: err.message });
//     }
// });

// app.post('/api/items/sell', async (req, res) => {
//     const { name, quantity } = req.body;
//     try {
//         const item = await Item.findOne({ name: name.toLowerCase() });
//         if (!item || item.stock < quantity) return res.status(400).send("No Stock");

//         item.stock -= quantity;
//         await item.save();
//         await Sale.create({ itemName: name, amount: item.price * quantity });

//         res.status(200).json(item);
//     } catch (err) { res.status(500).json(err); }
// });

// app.post('/api/items/delete', async (req, res) => {
//     try {
//         const { name } = req.body;
//         await Item.deleteOne({ name: name });
//         res.status(200).send("Deleted");
//     } catch (err) { res.status(500).send(err); }
// });

// // 2. IMPORTANT: Railway Dynamic Port
// const PORT = process.env.PORT || 3000;
// // Change your listen line to this:
// app.listen(process.env.PORT || 3000, '0.0.0.0', () => {
//     console.log(`Server is running on port ${process.env.PORT || 3000}`);
// });
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors'); // Declared once at the top
require('dotenv').config();

const app = express();

// --- CORS CONFIGURATION ---
// Keep it simple. This covers all common needs without crashing the router.
app.use(cors()); 
app.use(express.json());

// --- DATABASE CONNECTION ---
const mongoURI = process.env.MONGO_URL || 'mongodb+srv://aliammar0342:aliammar0342@backhand.bl5s3.mongodb.net/mart?appName=backhand';

mongoose.connect(mongoURI)
    .then(() => console.log('Connected to MongoDB via Railway'))
    .catch(err => console.error('Connection Error:', err));

// --- SCHEMAS ---
const Item = mongoose.model('Item', new mongoose.Schema({
    name: { type: String, unique: true, required: true },
    price: Number,
    stock: { type: Number, default: 0 }
}));

const Sale = mongoose.model('Sale', new mongoose.Schema({
    itemName: String,
    amount: Number,
    date: { type: Date, default: Date.now }
}));

// --- ROUTES ---
app.get('/api/items', async (req, res) => {
    try {
        const items = await Item.find();
        res.status(200).json(items);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

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

app.post('/api/items/sell', async (req, res) => {
    const { name, quantity } = req.body;
    try {
        const item = await Item.findOne({ name: name.toLowerCase() });
        if (!item || item.stock < quantity) return res.status(400).send("No Stock");

        item.stock -= quantity;
        await item.save();
        await Sale.create({ itemName: name, amount: item.price * quantity });
        res.status(200).json(item);
    } catch (err) { res.status(500).json(err); }
});

app.post('/api/items/delete', async (req, res) => {
    try {
        const { name } = req.body;
        await Item.deleteOne({ name: name });
        res.status(200).send("Deleted");
    } catch (err) { res.status(500).send(err); }
});

// --- SERVER INITIALIZATION ---
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on port ${PORT}`);
});