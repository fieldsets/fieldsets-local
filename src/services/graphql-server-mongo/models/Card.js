const { model, Schema } = require('mongoose');

const cardSchema = new Schema({
  id: Number,
  title: String,
  cover_image_url: String,
  average_rating: Number,
  athlete: Object
});

module.exports = model('Card', cardSchema);