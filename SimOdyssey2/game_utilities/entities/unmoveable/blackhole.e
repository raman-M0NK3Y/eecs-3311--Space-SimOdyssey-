note
	description: "Summary description for {BLACKHOLEE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BLACKHOLE

inherit
	UNMOVEABLE_ENTITY

create
	make

feature
	make
	do
		setsymbol ('O')
		shared_info := shared_info_access.shared_info
		id := shared_info.generateid(Current)
	end
end
