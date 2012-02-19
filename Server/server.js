/*******************************************************************************
 * IMPORTS
 ******************************************************************************/
var io = require( 'socket.io' );
var express = require( 'express' );


/*******************************************************************************
 * GLOBALS
 ******************************************************************************/
var PORT = 8888;

var http;
var persistent;


/*******************************************************************************
 * HTTP Server
 ******************************************************************************/
http = express.createServer();

http.configure( function()
{
	// parse POST data into request.body
	http.use( express.bodyParser() );
	
	// directory containing client files
	http.use( express.static( __dirname + '/public' ) );
	
	// to route http.get/post paths ( must be after bodyParser for some reason )
	http.use( http.router );
});

// Phone POSTs contents of SMS here
http.post( '/sms', function( request, response )
{
	// send to all clients
	persistent.sockets.emit( 'sms', request.body );
	
	// can possibly wait for reply here before responding...
	
	response.send( 200 );
});

http.all( '*', function( request, response )
{
	response.send( 404 );
});

http.listen( PORT );


/*******************************************************************************
 * Comet Server
 ******************************************************************************/
persistent = io.listen( http );

persistent.sockets.on( 'connection', function( client )
{  
  client.on( 'message', function( data )
  {
  });
  
  client.on( 'disconnect', function()
  {
  });
});