note
	description: "Summary description for {WORMHOLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WORMHOLE

inherit
	UNMOVEABLE_ENTITY

create
	make

feature
	make
	do
		setsymbol ('W')
		shared_info := shared_info_access.shared_info
		id := shared_info.generateid(Current)
	end
end
