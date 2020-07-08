note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_STATUS
inherit
	ETF_STATUS_INTERFACE
create
	make
feature -- command
	status
    	do
			-- perform some update on the model state
			if model.getGameStarted = false then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:no mission in progress.")
    		else
				model.statuson
				model.incrementinvalidmoves
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
