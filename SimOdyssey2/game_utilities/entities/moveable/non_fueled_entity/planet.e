note
	description: "Summary description for {PLANET}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PLANET

inherit
	NO_FUEL_ENTITY

create
	make

feature -- Constructor
	make
	do
		set_name("Planet")
		isAttached := "F"
		supportsLife := "F"
		visited := "F"
		setsymbol ('P')
		set_deathMessage("")
		shared_info := shared_info_access.shared_info
		id := shared_info.generateid(Current)
	end

feature -- Attributes for all planets

	isAttached : STRING
	supportsLife : STRING
	visited : STRING

feature -- Commands

	setAttached( newAttached : STRING)
	do
		isAttached := newAttached
	end

	setSupportLife (newSupportLife : STRING)
	do
		supportsLife := newSupportLife
	end

	setVisited (newVisited : STRING)
	do
		visited := newVisited
	end

feature -- Queries

	getAttached : STRING
	do
		Result := isAttached
	end

	getSupportLife : STRING
	do
		Result := supportsLife
	end

	getVisted : STRING
	do
		Result := visited
	end

end
