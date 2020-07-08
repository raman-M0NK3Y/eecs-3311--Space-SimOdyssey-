note
	description: "Summary description for {YELLOW_DWARF}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	YELLOW_DWARF

inherit
	STAR

create
	make

feature
	make
	do
		setsymbol ('Y')
		setluminosity (2)
		shared_info := shared_info_access.shared_info
		id := shared_info.generateid(Current)
	end

end
