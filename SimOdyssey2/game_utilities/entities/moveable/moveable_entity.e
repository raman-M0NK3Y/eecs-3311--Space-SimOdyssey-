note
	description: "Summary description for {MOVEABLE_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	MOVEABLE_ENTITY

inherit
	ENTITY

feature -- Shared attributes for all moveable entities

	name : STRING
	death_message : STRING
	turnsLeft : INTEGER

feature -- Commands

	set_deathMessage (message : STRING)
	do
		death_message := message
	end

	set_name (nameInput : STRING)
	do
		name := nameinput
	end

	setTurnsLeft (turns : INTEGER)
	do
		turnsLeft := turns
	end

feature -- Queries

	get_name : STRING
	do
		Result := name
	end

	getTurnsLeft : INTEGER
	do
		Result := turnsLeft
	end
end
