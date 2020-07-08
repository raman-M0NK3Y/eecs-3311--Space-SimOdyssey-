note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LIFTOFF
inherit
	ETF_LIFTOFF_INTERFACE
create
	make
feature -- command
	liftoff
    	do
    		if model.getGameStarted = false then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:no mission in progress.")
    		elseif model.getexplorer.getlanded ~ "F" then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:you are not on a planet at " + model.getsector (model.getexplorer))
    		else
				model.turn ("liftoff", 0)
    		end
			etf_cmd_container.on_change.notify ([Current])
		end

end
