--- Intermediary application module.
-- @module app
local app = {}

--- Recognized application types.
-- @see dissector
app.type = {
	DISSECTOR = 0x01 -- Packet dissector
}

--- Create a new application of type _type_.
-- @tparam integer type Type of an application.
-- @treturn table New application object.
-- @see app.type
function app:new (type)
	local app_new = nil

	if type == app.type.DISSECTOR then
		app_new = require ("app/dissector")
	else
		error ("unrecognized application type", 2)
	end

	return app_new
end

return app

