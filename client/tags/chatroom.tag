'use strict';
/* global riot */

<chatroom>
    <div class="container-fluid fill">
        <div class="panel panel-default fill">
            <div class="panel-heading lead cyan">
                { opts.title }
            </div>
            <div id="chatroom-panel-body" class="panel-body lead">
                <div class="row-fluid fill">
                    <div id="userlist" class="span2 hidden-phone fill">
                        <ul class="nav nav-list">
                            <li class = "nav-header">Users</li>
                            <li each={ user, i in users }><a>{ user }</a></li>
                        </ul>
                    </div>
                    <div class="span10 fill">
                        <div id="chatdiv">
                            <ul class="fill">
                                <li each={ messages } class={ red: source === 'chatroom' }>
                                    { (source === 'chatroom' ? '' : source + ': ') + text }
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            <div class="panel-footer">
                <div class="lead">
                    <input type="text" id="messageinput" name="messageinput" value="" class="form-control" onkeydown={ messagekeyup } placeholder="Enter text here to chat." autofocus>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        var self = this;
        
        self.messages = [];
        
        var socket = io.connect();
        
        this.on('update', function () {
            var chatdiv = $('#chatdiv');
            chatdiv.stop().animate({
                    scrollTop: chatdiv.prop('scrollHeight')
                },
                parseInt(300, 10)
            );
        
        });

        socket.on('connect', function () {
            console.log('socket.io connected.');
        });
        
        socket.on('chatroom:init', function (data) {
            self.name = data.name;
            self.users = data.users;

            for(var i=0; i < data.recentMessages.length; i++) {
                self.messages.push(data.recentMessages[i]);
            }
            
            self.update();
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

            var message = self.messageinput.value.trim();
            
            if (e.which === 13 && message.length > 0) {
                socket.emit('chatroom:send:message', {
                        source: self.name,
                        message: message
                    });
        
                    self.messages.push({
                        source: self.name,
                        text: message,
                        timestamp: Date.now()
                    });

                    self.messageinput.value = '';
                    
                    self.update();
                }
                
            return true;
        }
    </script>
    
    <style>
        #messageinput {
            width: 100% !important;
            border: 0px !important;
        }
        
        #chatroom-panel-body {
            height: calc(100% - 204px);
            height: -o-calc(100% - 204px);
            height: -webkit-calc(100% - 204px);
            height: -moz-calc(100% - 204px);
        }
        
        #chatdiv {
            overflow-y: hidden;
            padding-top: 20px;
            height: calc(100% - 20px);
            height: -o-calc(100% - 20px);
            height: -webkit-calc(100% - 20px);
            height: -moz-calc(100% - 20px);
        }
        

        #userlist ul.nav-list {
            height: calc(100% - 50px);
            margin-left: 0px !important;
        }
        
        .panel-heading {
            background-color: black !important;
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
        
        .cyan {
            color: cyan !important;
        }
        
        .red {
            color: red !important;
        }
    </style>

</chatroom>
