note
	description: "Summary description for {STAR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	STAR

inherit
	UNMOVEABLE_ENTITY

feature {NONE} -- Attributes of ALL Stars

	luminosity : INTEGER

feature -- Queries
	getLuminosity : INTEGER
	do
		Result := luminosity
	end
feature -- Commands for all Star Objects

	setLuminosity (lumInput : INTEGER)
	do
		luminosity := lumInput
	end

end
