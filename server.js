var connect = require('connect');
var serveStatic = require('serve-static');
var port = 8080;
try{
  if (!connect().use(serveStatic(__dirname+'/OEBPS')).listen(port)){
    throw new Error('  Cannot establish connection.');
  } else{
    console.log('  Listening on http://localhost:'+port);
  }
} catch (err) {
  console.error(err.stack);
}

