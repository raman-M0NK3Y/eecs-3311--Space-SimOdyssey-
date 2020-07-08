note
	description: "Summary description for {REPRODUCTIVE_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	REPRODUCTIVE_ENTITY

inherit
	FUELED_ENTITY

feature -- Attributes

	actions_left_until_reproduction : INTEGER

feature -- Commands

	set_actions_left_until_reproduction (actions_left : INTEGER)
	do
		actions_left_until_reproduction := actions_left
	end

feature -- Queries

	get_actions_left_until_reproduction : INTEGER
	do
		Result := actions_left_until_reproduction
	end

end
