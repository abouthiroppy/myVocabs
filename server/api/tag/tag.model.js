'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var tagSchema = new Schema({
  name: String
});

module.exports = mongoose.model('Tag', tagSchema);