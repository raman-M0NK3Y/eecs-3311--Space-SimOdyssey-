note
	description: "Summary description for {ETF_INT_PARAM}."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_INT_PARAM

inherit
	ETF_PRIMITIVE_PARAM_TYPE
		redefine
			out
		end
create
	default_create

feature -- Queries
	eiffel_type : STRING
		do
			Result := out
		end

	create_clause : STRING
		do
			Result := "create {ETF_INT_PARAM}"
		end

	out : STRING
		do
			Result := "INTEGER_32"
		end
end


