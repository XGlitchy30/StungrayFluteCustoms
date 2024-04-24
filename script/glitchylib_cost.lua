--[[Costs that make you pay LP
val = Amount of LP to pay]]
function Auxiliary.PayLPCost(val)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.CheckLPCost(tp,val) end
				Duel.PayLPCost(tp,val)
			end
end