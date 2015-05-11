'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var currentSetting = new Schema({
  selectTag: String
});

module.exports = mongoose.model('Current', currentSetting);
