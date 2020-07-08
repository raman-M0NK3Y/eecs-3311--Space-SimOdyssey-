note
	description: "Summary description for {JANITAUR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JANITAUR

inherit
	REPRODUCTIVE_ENTITY

create
	make

feature -- Janitaur specific attribute

	load : INTEGER

feature -- Constructor
	make
	do
		maxFuel := 5
		set_actions_left_until_reproduction (2)
		setfuel (5)
		setsymbol ('J')
		set_deathmessage ("")
		set_name ("Janitaur")
		shared_info := shared_info_access.shared_info
		id := shared_info.generateid(Current)
	end

feature -- Queries

	getLoad : INTEGER
	do
		Result := load
	end

feature -- Command

	setLoad (newLoad : INTEGER)
	do
		load := newLoad
	end
end
