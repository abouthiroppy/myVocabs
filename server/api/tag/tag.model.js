'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

// TODO: add default tag for saving current watching tag
var tagSchema = new Schema({
  name: String,
  value: String
});

module.exports = mongoose.model('Tag', tagSchema);