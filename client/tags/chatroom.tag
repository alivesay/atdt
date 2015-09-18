'use strict';
/* global riot */

<chatroom>
    <div class="container-fluid fill">
        <div class="panel panel-default fill">
            <div class="panel-heading lead">
                { opts.title }
            </div>
            <div id="chatroom-panel-body" class="panel-body lead">
                <ul>
                    <li each={ messages }>
                        { (source === 'chatroom' ? '' : source + ': ') + text }
                    </li>
                </ul>
            </div>
            <div class="panel-footer">
                <input type="text" id="messageinput" name="messageinput" value="" class="form-control" onkeydown={ messagekeyup } placeholder="Enter text here to chat.">
            </div>
        </div>
    </div>
    <script>
        var self = this;
        
        self.messages = [];
        
        var socket = io.connect();

        socket.on('connect', function () {
            console.log('socket.io connected.');
        });
        
        socket.on('chatroom:init', function (data) {
            self.name = data.name;
            self.users = data.users;
        });

        socket.on('chatroom:send:name', function (data) {
            self.name = data.name;
        });

        socket.on('chatroom:send:message', function (message) {
            self.messages.push(message);
            self.update();
        });

        socket.on('chatroom:user:join', function (data) {
            self.messages.push({
                source: 'chatroom',
                text: 'User ' + data.name + ' has joined.',
                timestamp: Date.now()
            });

            self.users.push(data.name);
            self.update();
        });

        socket.on('chatroom:user:left', function (data) {
            self.messages.push({
                source: 'chatroom',
                text: 'User ' + data.name + ' has left.',
                timestamp: Date.now()
            });
        
            self.users = $.grep(self.users, function(val) {
                return val !== data.name;
            });
            
            self.update();
        });

        messagekeyup(e) {
            if (e.which === 13) {
                socket.emit('chatroom:send:message', {
                        source: self.name,
                        message: self.messageinput.value
                    });
        
                    self.messages.push({
                        source: self.name,
                        text: self.messageinput.value,
                        timestamp: Date.now()
                    });
        console.log(self.messages);
                    self.messageinput.value = '';
                }
                
            return true;
        }
    </script>
    
    <style>
        #messageinput {
            width: 100% !important;
        }
        
        #chatroom-panel-body {
            height: calc(100% - 184);
            height: -o-calc(100% - 184px);
            height: -webkit-calc(100% - 184px);
            height: -moz-calc(100% - 184px);
        }
        
        ::-webkit-input-placeholder {
            color: yellow !important;
        }
        
        :-moz-placeholder {
            color: yellow !important;
        }
        
        ::-moz-placeholder {
            color: yellow !important;
        }
        
        :-ms-input-placeholder {  
            color: yellow !important;
        }
    </style>

</chatroom>
