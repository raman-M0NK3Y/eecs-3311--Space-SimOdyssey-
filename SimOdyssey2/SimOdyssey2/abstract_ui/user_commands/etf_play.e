note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_PLAY
inherit
	ETF_PLAY_INTERFACE
create
	make
feature -- command
	play
    	do
    		if model.getGameStarted = true then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("To start a new mission, please abort the current one first.")
    		else
				model.game_begin
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
