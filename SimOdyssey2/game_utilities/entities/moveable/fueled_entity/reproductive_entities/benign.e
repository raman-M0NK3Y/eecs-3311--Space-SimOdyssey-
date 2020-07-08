note
	description: "Summary description for {BENIGN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BENIGN

inherit
	REPRODUCTIVE_ENTITY
create
	make

feature -- Constructor
	make
	do
		maxFuel := 3
		set_actions_left_until_reproduction (1)
		set_name("Benign")
		setfuel (3)
		setsymbol ('B')
		set_deathmessage ("")
		shared_info := shared_info_access.shared_info
		id := shared_info.generateid(Current)
	end
end
