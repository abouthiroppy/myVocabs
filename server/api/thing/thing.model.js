'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

// var ThingSchema = new Schema({
//   name: String,
//   info: String,
//   active: Boolean
// });

var wordSchema = new Schema({
  word: String,
  date: String,
  roughly: String,
  explain: String,
  priority: Number,
  keywords: Array,
  accessCount: Number,
  close: Boolean
});

module.exports = mongoose.model('Thing', wordSchema);