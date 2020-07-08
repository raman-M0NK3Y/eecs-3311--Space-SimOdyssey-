note
	description: "Summary description for {EXPLORER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EXPLORER

inherit
	FUELED_ENTITY

create
	make

feature -- Attributes
	life : INTEGER
	landed : STRING

feature -- Constructor
	make
	do
		turnsLeft := 999
		set_name ("Explorer")
		maxFuel := 3
		landed := "F"
		fuel := 3
		life := 3
		setsymbol ('E')
		set_deathMessage("")
	    shared_info := shared_info_access.shared_info
		id := shared_info.generateid(Current)
	end

feature -- Queries

	getLife : INTEGER
	do
		Result := life
	end

	getLanded : STRING
	do
		Result := landed
	end

	getDeathMsg : STRING
	do
		Result := death_message
	end

feature -- Commands

	setLife (newLife  : INTEGER)
	do
		life := newLife
	end

	setDeathMsg (message : STRING)
	do
		death_message :=  message
	end

	setLanded (newLanded : STRING)
	do
		landed := newLanded
	end
end
