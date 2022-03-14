const { model, Schema } = require('mongoose');

const athleteSchema = new Schema({
  username: { type: String, default: null },
  email: { type: String, unique: true },
  first_name: String,
  last_name: String,
  password: { type: String },
  token: { type: String },
  cards: Array
});

module.exports = model('Athlete', athleteSchema);