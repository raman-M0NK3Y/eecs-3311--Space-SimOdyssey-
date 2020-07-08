note
	description: "Summary description for {MALEVOLENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MALEVOLENT

inherit
	REPRODUCTIVE_ENTITY

create
	make

feature -- Constructor
	make
	do
		maxFuel := 3
		set_actions_left_until_reproduction (1)
		set_name ("Malevolent")
		setFuel(3)
		setsymbol ('M')
		set_deathmessage ("")
		shared_info := shared_info_access.shared_info
		id := shared_info.generateid(Current)
	end

end
