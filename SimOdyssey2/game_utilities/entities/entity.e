note
	description: "Summary description for {ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENTITY

feature{NONE} -- Attributes that ALL ENTITIES have

	symbol : CHARACTER
	id : INTEGER
	shared_info_access : SHARED_INFORMATION_ACCESS
	shared_info: SHARED_INFORMATION
	
feature -- Queries

	getSymbol : CHARACTER
	do
		Result := symbol
	end

	getid : INTEGER
	do
		Result := id
	end

feature -- Commands

	setSymbol(symbolInput : CHARACTER)
	do
		symbol := symbolInput
	end
end
