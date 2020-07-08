note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_WORMHOLE
inherit
	ETF_WORMHOLE_INTERFACE
create
	make
feature -- command
	wormhole
    	do
    		if model.getGameStarted = false or model.getgameover then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:no mission in progress.")
    		elseif model.getexplorer.getlanded ~ "T" then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:you are currently landed at " + model.getsector (model.getexplorer))
    		elseif model.haswormhole (model.getexplorer) = false then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Explorer couldn't find wormhole at " + model.getsector (model.getexplorer))
    		else
    			model.turn ("wormhole", 0)
    		end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
