note
	description: "Summary description for {ENTITY_COMPARE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENTITY_COMPARE

inherit
	KL_COMPARATOR[ENTITY]

create
	default_create

feature -- Inherited Features

	attached_less_than (entity1, entity2 : attached ENTITY): BOOLEAN
	do
		Result := entity1.getid < entity2.getid
	end


end
