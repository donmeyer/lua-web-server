-- Don's Lua web server demo app

-- Copyright (c) 2015, Donald T. Meyer
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
--
-- * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--
-- * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



-- The webserver class that does all the heavy lifting
webserver = require( "webserver" )


print( "Web server script running!" )


-- Some canned JSON content to return for demo purposes
local rcontent =
[===[{"pir-counts": {"LR": 44, "hall": 65, "MB": 17}, "dark-inside": false, "ac-on": true, "Animals": [{"bats": 456, "rats": 123}, null, "Mouse!", ["alpha", "beta", 999, true, false]], "temperatures": {"garage": 44, "outside": 32, "2nd floor": 69}, "doors": {"Front": true, "Back": false}, "chime": true, "rooms": ["bedroom", "study", "kitchen"]}]===]


-- An endpoint handler. This returns the canned JSON. (In a real app, the content would be dynamic of course.)
function do_status_json( session )
	webserver.sendOKResponse( session, rcontent, "application/json" )	
end


-- This handler returns some canned HTML
function do_status_html( session )
	content = "<html>"
	content = content .. "<h1>HA Status</h1>"

	val = 13.5
	if val ~= nil then
		s = string.format( "%1.3f", val )
	else
		s = "UNSET"
	end
	content = content .. string.format( "Light node battery voltage: %s<br>", s  )

	val = 1234
	if val ~= nil then
		s = string.format( "%d", val )
	else
		s = "UNSET"
	end
	content = content .. string.format( "Light node lambient light reading: %s<br>", s )

	val = "Watching a movie"
	if val ~= nil then
		s = string.format( "%s", val )
	else
		s = "UNSET"
	end
	content = content .. string.format( "Main Scene: %s<br>", s )

	content = content .. "</html>"

	webserver.sendOKResponse( session, content, "text/html" )
end


-- This handler returns some plain text
function do_mice( s )
	print( s.urlComponents.query )
	webserver.sendOKResponse( s, "Squeek! Squeek!", "text/plain" )	
end


-- This handler parses some of the path to take an action.
--
-- Note that some of this could be broken out into indivisual handlers as well (i.e. den and kitchen)
-- but is done this way for demo purposes.
--
--
-- Members of the session table:
--  method - Request Type (e.g. GET, POST)
--   urlComponents - Table containing URL components per the LuaSocket decoded URL specification
--   pathComponents - Table of the path components. At least keys 'path' and 'query'?
-- queryComponents - Table of the query key/value pairs
--   headers - Table of all headers as key/value pairs-- s.method
--   urlString - Entire URL string
--   version - HTTP version string
--  contentLength
--   content (only if contentLength > 0)
--
function do_action( s )
	--webserver.dumpSession( s )
	if s.pathComponents[2] == "den" then
	 	print( "Set Den state to", s.pathComponents[3] )
		if s.pathComponents[3] ~= nil then
			webserver.sendOKResponse( s, "Action successful", "text/plain" )
		else
			webserver.sendErrorResponse( s, 404, "Den action requires a valid state" )
		end
		return
	end

	if s.pathComponents[2] == "kitchen" then
		print( "Set Kitchen state to", s.pathComponents[3] )
		if s.pathComponents[3] ~= nil then
			webserver.sendOKResponse( s, "Action successful", "text/plain" )
		else
			webserver.sendErrorResponse( s, 404, "Kitchen action requires a valid state" )
		end
		return
	end

	webserver.sendErrorResponse( s, 404, "Invalid action, should be 'den' or 'kitchen'" )	
end



webserver.registerHandler( "/status", "GET", do_status_html )
webserver.registerHandler( "/status/json", "GET", do_status_json )
webserver.registerHandler( "/mice", "*", do_mice )
webserver.registerHandler( "/action/*", "POST", do_action )

webserver.run( "*", 8080 )
