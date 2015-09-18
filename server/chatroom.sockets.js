var userNames = (function () {
  var names = {};

  var claim = function (name) {
    if (!name || names[name]) {
      return false;
    } else {
      names[name] = true;
      return true;
    }
  };

  var getGuestName = function () {
    var name;
    var nextUserId = 1;

    do {
      name = 'Guest' + nextUserId++;
    }  while (!claim(name));

    return name;
  };

  var get = function () {
    var res = [];
    for (user in names) {
      res.push(user);
    }

    return res;
  };

  var free = function (name) {
    if (names[name]) {
      delete names[name];
    }
  };

  return {
    claim: claim,
    free: free,
    get: get,
    getGuestName: getGuestName
  };
}());

var recentMessages = {
    
    _MESSAGE_LIMIT: 10,
    _messages: [],
    
    get: function () {
        return this._messages;
    },
    
    push: function (message) {
        this._messages.push(message);
        if (this._messages.length > this._MESSAGE_LIMIT) {
            this._messages.shift(message);
        }
    }
};

module.exports = function (socket) {
    var name = userNames.getGuestName();

    socket.emit('chatroom:init', {
        name: name,
        users: userNames.get(),
        recentMessages: recentMessages.get()
    });

    socket.broadcast.emit('chatroom:user:join', {
        name: name
    });

    socket.on('chatroom:send:message', function (data) {
        if (!data.message) {
            return;
        }
        
        var text = data.message.trim();
        
        if (text.length === 0) {
            return;
        }
        
        var message = {
            source: name,
            text: text,
            timestamp: Date.now()
        };

        recentMessages.push(message);
        socket.broadcast.emit('chatroom:send:message', message);
    });

    socket.on('disconnect', function () {
        socket.broadcast.emit('chatroom:user:left', {
            name: name
        });
        userNames.free(name);
    });
};