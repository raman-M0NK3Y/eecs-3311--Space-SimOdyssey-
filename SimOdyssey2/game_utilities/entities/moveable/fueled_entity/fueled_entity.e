note
	description: "Summary description for {FUELED_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	FUELED_ENTITY

inherit
	MOVEABLE_ENTITY

feature -- Attributes for all fueled entities
	fuel : INTEGER
	maxFuel : INTEGER
feature -- Commands

	setFuel (newFuel  : INTEGER)
	do
		fuel := newFuel
	end
feature -- Queries

	getFuel : INTEGER
	do
		Result := fuel
	end

	getMaxFuel : INTEGER
	do
		Result := maxFuel
	end
end
