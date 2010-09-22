var sys = require("sys"),
   http = require("http");
http.createServer(function (request, response) {
  response.writeHead(200, {"Content-Type": "text/html"});
  response.write("<html><head><title>Node, node, node</title></head>\n");
  response.write("<body>\n");
  response.write("<a href='http://www.youtube.com/watch?v=C526lxeHo-M'>Node, Node, Node!</a>\n");
  response.write("</body>\n");
  response.write("</html>\n");
  response.end();
}).listen(1234);
sys.puts("Server running at http://127.0.0.1:1234/");