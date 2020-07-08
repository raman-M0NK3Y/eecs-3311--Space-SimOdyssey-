note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_TEST
inherit
	ETF_TEST_INTERFACE
create
	make
feature -- command
	test(a_threshold: INTEGER_32 ; j_threshold: INTEGER_32 ; m_threshold: INTEGER_32 ; b_threshold: INTEGER_32 ; p_threshold: INTEGER_32)
		require else
			test_precond(a_threshold, j_threshold, m_threshold, b_threshold, p_threshold)
    	do
    		if model.getGameStarted = true then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("To start a new mission, please abort the current one first.")
    		elseif not (p_threshold >= b_threshold and b_threshold >= m_threshold and m_threshold >= j_threshold and j_threshold >= a_threshold) then
    			model.incrementinvalidmoves
    			model.seterrortrue
    			model.seterrormsg ("Thresholds should be non-decreasing order.")
    		else
    			model.test (a_threshold, j_threshold, m_threshold, b_threshold, p_threshold)
    		end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
