note
	description: "Summary description for {ASTEROID}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ASTEROID

inherit
	NO_FUEL_ENTITY

create
	make

feature -- Constructor
	make
	do
		set_name("Asteroid")
		setsymbol ('A')
		set_deathMessage("")
		shared_info := shared_info_access.shared_info
		id := shared_info.generateid(Current)
	end

end
