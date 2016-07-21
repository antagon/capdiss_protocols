--- Internet Control Message Protocol (ICMP) packet dissector.
-- This module is based on code adapted from nmap's nselib. See http://nmap.org/.
-- @module icmp
local bstr = require ("bstr")
local icmp = {}

--- ICMP message types.
-- TODO: fix descriptions and add more types...
-- see here: http://www.networksorcery.com/enp/protocol/icmp.htm
icmp.type = {
	ICMP_ECHOREPLY = 0,       -- Echo Reply
	ICMP_DEST_UNREACH = 3,    -- Destination Unreachable
	ICMP_SOURCE_QUENCH = 4,   -- Source Quench
	ICMP_REDIRECT = 5,        -- Redirect (change route)
	ICMP_ECHO = 8,            -- Echo Request
	ICMP_TIME_EXCEEDED = 11,  -- Time Exceeded
	ICMP_PARAMETERPROB = 12,  -- Parameter Problem
	ICMP_TIMESTAMP = 13,      -- Timestamp Request
	ICMP_TIMESTAMPREPLY = 14, -- Timestamp Reply
	ICMP_INFO_REQUEST = 15,   -- Information Request
	ICMP_INFO_REPLY = 16,     -- Information Reply
	ICMP_ADDRESS = 17,        -- Address Mask Request
	ICMP_ADDRESSREPLY = 18    -- Address Mask Reply
}

--- ICMP message type codes.
icmp.code = {
	ICMP_NET_UNREACH = 0,     -- Network Unreachable
	ICMP_HOST_UNREACH = 1,    -- Host Unreachable
	ICMP_PROT_UNREACH = 2,    -- Protocol Unreachable
	ICMP_PORT_UNREACH = 3,    -- Port Unreachable
	ICMP_FRAG_NEEDED = 4,     -- Fragmentation Needed/DF set
	ICMP_SR_FAILED = 5,       -- Source Route failed
	ICMP_NET_UNKNOWN = 6,     -- Destination network unknown
	ICMP_HOST_UNKNOWN = 7,    -- Destination host unknown
	ICMP_HOST_ISOLATED = 8,   -- Source host isolated
	ICMP_NET_ANO = 9,         -- The destination network is administratively prohibited
	ICMP_HOST_ANO = 10,       -- The destination host is administratively prohibited
	ICMP_NET_UNR_TOS = 11,    -- The network is unreachable for Type Of Service
	ICMP_HOST_UNR_TOS = 12,   -- The host is unreachable for Type Of Service
	ICMP_PKT_FILTERED = 13,   -- Packet filtered
	ICMP_PREC_VIOLATION = 14, -- Precedence violation
	ICMP_PREC_CUTOFF = 15,    -- Precedence cut off

	ICMP_REDIR_NET = 0,       -- Network error
	ICMP_REDIR_HOST = 1,      -- Host error
	ICMP_REDIR_NETTOS = 2,    -- TOS and network error
	ICMP_REDIR_HOSTTOS = 3,   -- TOS and host error

	ICMP_EXC_TTL = 0,         -- Time to live exceeded during transit
	ICMP_EXC_FRAGTIME = 1     -- Fragment reassembly timeout
}

--- Create a new object.
-- @tparam string packet byte string of packet data 
-- @treturn table New icmp table.
function icmp.new (packet)
	if type (packet) ~= "string" then
		error ("parameter 'packet' is not a string", 2)
	end

	local icmp_pkt = setmetatable ({}, { __index = icmp })

	icmp_pkt.buff = packet

	return icmp_pkt
end

--- Parse the packet data.
-- @treturn boolean True on success, false on failure (error message is set).
-- @see icmp.new
-- @see icmp:set_packet
function icmp:parse ()
	if string.len (self.buff) < 8 then
		self.errmsg = "incomplete ICMP header data"
		return false
	end

	self.icmp_type = bstr.u8 (self.buff, 1)
	self.icmp_code = bstr.u8 (self.buff, 2)
	self.icmp_sum = bstr.u16 (self.buff, 3)

	return true
end

--- Get data encapsulated in a packet.
-- @treturn string Packet data or an empty string.
function icmp:get_data ()
	return string.sub (self.buff, 8 + 1, -1)
end

--- Get length of data encapsulated in a packet.
-- @treturn integer Data length.
function icmp:get_datalen ()
	return string.len (self.buff) - 8
end

--- Change or set new packet data.
-- @tparam string packet byte string of packet data
function icmp:set_packet (packet)
	self.buff = packet
end

--- Get packet type.
-- @treturn integer Packet type.
-- @see icmp.type
function icmp:get_type ()
	return self.icmp_type
end

--- Get packet code.
-- @treturn integer Packet code.
-- @see icmp.code
-- @see icmp.code_to_text
function icmp:get_code ()
	return self.icmp_code
end

--- Get packet's checksum.
-- @treturn integer Packet checksum.
function icmp:get_checksum ()
	return self.icmp_sum
end

--- Translate packet's code number to text.
-- @tparam integer type Packet type.
-- @tparam integer code Packet code.
-- @treturn string Message or nil, if combination of type and code does not exists.
-- @see icmp.type
-- @see icmp.code
function icmp.code_to_text (type, code)
	local types = {}

	types[ICMP_DEST_UNREACH][ICMP_NET_UNREACH] = "Network Unreachable"
	types[ICMP_DEST_UNREACH][ICMP_HOST_UNREACH] = "Host Unreachable"
	types[ICMP_DEST_UNREACH][ICMP_PROT_UNREACH] = "Protocol Unreachable"
	types[ICMP_DEST_UNREACH][ICMP_PORT_UNREACH] = "Port Unreachable"
	types[ICMP_DEST_UNREACH][ICMP_FRAG_NEEDED] = "Fragmentation Needed/DF set"
	types[ICMP_DEST_UNREACH][ICMP_SR_FAILED] = "Source Route failed"
	types[ICMP_DEST_UNREACH][ICMP_NET_UNKNOWN] = "Destination network unknown"
	types[ICMP_DEST_UNREACH][ICMP_HOST_UNKNOWN] = "Destination host unknown"
	types[ICMP_DEST_UNREACH][ICMP_HOST_ISOLATED] = "Source host isolated"
	types[ICMP_DEST_UNREACH][ICMP_NET_ANO] = "The destination network is administratively prohibited"
	types[ICMP_DEST_UNREACH][ICMP_HOST_ANO] = "The destination host is administratively prohibited"
	types[ICMP_DEST_UNREACH][ICMP_NET_UNR_TOS] = "The network is unreachable for Type Of Service"
	types[ICMP_DEST_UNREACH][ICMP_HOST_UNR_TOS] = "The host is unreachable for Type Of Service"
	types[ICMP_DEST_UNREACH][ICMP_PKT_FILTERED] = "Packet filtered"
	types[ICMP_DEST_UNREACH][ICMP_PREC_VIOLATION] = "Precedence violation"
	types[ICMP_DEST_UNREACH][ICMP_PREC_CUTOFF] = "Precedence cut off"

	types[ICMP_REDIRECT][ICMP_REDIR_NET] = "Network error"
	types[ICMP_REDIRECT][ICMP_REDIR_HOST] = "Host error"
	types[ICMP_REDIRECT][ICMP_REDIR_NETTOS] = "TOS and network error"
	types[ICMP_REDIRECT][ICMP_REDIR_HOSTTOS] = "TOS and host error"

	types[ICMP_TIME_EXCEEDED][ICMP_EXC_TTL] = "Time to live exceeded during transit"
	types[ICMP_TIME_EXCEEDED][ICMP_EXC_FRAGTIME] = "Fragment reassembly timeout"

	if types[type] then
		return types[type][code]
	end

	return nil
end

return icmp
