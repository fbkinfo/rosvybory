var http = require('http');
var sys = require('sys');
var url = require('url');

http.createServer(function(request, response) {
  var target_port;
  if (request.url.match(/^\/events/)) {
    target_port = 8000;
  } else {
    target_port = 3000;
  }

  console.log(request.url +' -> '+ target_port);

  var proxy = http.createClient(target_port, 'localhost');
  var proxy_request = proxy.request(request.method, request.url, request.headers);
  proxy_request.addListener('response', function(proxy_response) {
    proxy_response.addListener('data', function(chunk) {
      if (target_port == 8000) {
        console.log("cuhnk: "+ chunk);
      }
      response.write(chunk, 'binary');
    });
    proxy_response.addListener('end', function() {
      if (target_port == 8000) {
        console.log("Server closed connection.");
      }
      response.end();
    })
    response.writeHead(proxy_response.statusCode, proxy_response.headers);
  });
  request.addListener('data', function(chunk) {
    proxy_request.write(chunk, 'binary');
  });
  request.addListener('end', function() {
    if (target_port == 8000) {
      console.log("Client closed.");
    }
    proxy_request.end();
  })
}).listen(8080);
