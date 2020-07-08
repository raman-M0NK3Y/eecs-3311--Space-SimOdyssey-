note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MOVE
inherit
	ETF_MOVE_INTERFACE
create
	make
feature -- command
	move(dir: INTEGER_32)
		require else
			move_precond(dir)
    	do
    		if model.getGameStarted = false or model.getgameover = true then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:no mission in progress.")
    		elseif model.getexplorer.getlanded ~ "T" then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:you are currently landed at " + model.getsector (model.getexplorer))
--    		elseif model.getsectorfull then
--    			model.incrementinvalidmoves
--    			model.seterrortrue
--    			model.seterrormsg ("Cannot transfer to new location as it is full.")
    		else
	    		model.turn ("move", dir)
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
