note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_LAND
inherit
	ETF_LAND_INTERFACE
create
	make
feature -- command
	land
    	do
    		if model.getGameStarted = false or model.getgameover then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:no mission in progress.")
    		elseif model.getexplorer.getlanded ~ "T" then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:already landed on a planet at " + model.getsector (model.getexplorer))
    		elseif model.hasyellowdwarf (model.getexplorer).has = false then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:no yellow dwarf at " + model.getsector (model.getexplorer))
    		elseif model.hasPlanets(model.getexplorer).has = FALSE then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:no planets at " + model.getsector (model.getexplorer))
    		elseif model.hasunvisitedplanets (model.getexplorer).has = false then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Negative on that request:no unvisited attached planet at " + model.getsector (model.getexplorer))
    		else
    			model.turn ("land", 0)
			end
				etf_cmd_container.on_change.notify ([Current])
    	end


end
