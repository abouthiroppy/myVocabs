/**
 * Broadcast updates to client when the model changes
 */

'use strict';

var word = require('./word.model');

exports.register = function(socket) {
  word.schema.post('save', function (doc) {
    onSave(socket, doc);
  });
  word.schema.post('remove', function (doc) {
    onRemove(socket, doc);
  });
}

function onSave(socket, doc, cb) {
  socket.emit('word:save', doc);
}

function onRemove(socket, doc, cb) {
  socket.emit('word:remove', doc);
}
