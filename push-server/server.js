var http = require('http');
var sys = require('sys');
var fs = require('fs');
var redis = require("redis");

http.createServer(function(req, res) {
  if (req.headers.accept && req.headers.accept == 'text/event-stream') {
    if (req.url.match(/^\/events/)) {
      bindSubscriber(req, res);
    } else {
      res.writeHead(404);
      res.end();
    }
  } else {
    if (req.url == '/') {
      res.writeHead(200, {'Content-Type': 'text/html'});
      res.write(fs.readFileSync(__dirname + '/index.html'));
      res.end();
    } else {
      res.writeHead(404);
      res.end();
    }
  }
}).listen(8000);

function bindSubscriber(req, res) {
  console.log("Binding");
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive'
  });
  res.write('\n');

  var id = 0;

  var subscriber = redis.createClient();
  subscriber.subscribe('reports')
  subscriber.on('message', function(channel, message) {
    if (true || TODO.matchFilter()) {
      id++;
      writeSSE(res, id, message);
    }
  });

  req.connection.addListener("close", function() {
    console.log("Closing connection");
    subscriber.unsubscribe();
    subscriber.quit();
  });
}

function writeSSE(res, id, data) {
  console.log("Sending "+ data);
  res.write('id: ' + id + '\n');
  res.write("data: " + data + '\n\n');
}
