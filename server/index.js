var Hapi = require('hapi');

var server = new Hapi.Server();

server.connection({ port: process.env.PORT });

var plugins = [
    { register: require('inert') }
];

var ATDTServer = {
    boot: function (callback) {
        server.register(plugins, function (err) {
            if (err) {
                throw err;
            }
            
            server.route({
                method: 'GET',
                path: '/{param*}',
                handler: {
                    directory: {
                        path: './client',
                        redirectToSlash: true,
                        index: true
                    }
                }
            });
        
            server.on('response', function (request) {
                console.log("[%s] %s %s - %s",
                            request.info.remoteAddress,
                            request.method.toUpperCase(),
                            request.url.path,
                            request.response.statusCode);
            });
            
            server.start(function () {
                console.log('Server running at:', server.info.uri);
                
                var io = require('socket.io')(server.listener);
                
                io.on('connection', function (socket) {
                      var remoteAddress = socket.client.conn.remoteAddress;
                      console.log('socket: ' + socket.id + ':' + remoteAddress);
                      require('./chatroom.sockets.js')(socket);
                });
                
                if (callback) {
                    return callback();
                }
            });
        });
    }
}

module.exports = ATDTServer;