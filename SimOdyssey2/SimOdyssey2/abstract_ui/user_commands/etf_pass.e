note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_PASS
inherit
	ETF_PASS_INTERFACE
create
	make
feature -- command
	pass
    	do
    		if model.getGameStarted = false or model.getgameover then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:no mission in progress.")
    		else
	    		model.turn ("pass", 0)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end
end
