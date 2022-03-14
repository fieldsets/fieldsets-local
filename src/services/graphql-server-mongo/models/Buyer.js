const { model, Schema } = require('mongoose');

const buyerSchema = new Schema({
  id: Number,
  first_name: String,
  last_name: String,
  email: String,
  cards: Array
});

module.exports = model('Buyer', buyerSchema);