

var express = require("express");

var content = express();
var contentRoot = "/files"
content.use(contentRoot, express.static(__dirname + "/../content/files"));
contentRoot = ":8000" + contentRoot;
content.listen(8000);

var app = express();

var rootPath = "/toolkit/v2";

require("./api/packlist").register(app, rootPath, contentRoot);

app.listen(9000);