note
	description: "Summary description for {BLUE_GIANT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BLUE_GIANT

inherit
	STAR

create
	make

feature
	make
	do
		setsymbol ('*')
		setluminosity (5)
		shared_info := shared_info_access.shared_info
		id := shared_info.generateid(Current)
	end

end
