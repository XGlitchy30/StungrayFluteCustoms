--Shows a description string to the opponent when the effect is activated. Useful for cards with multiple effects that can be activated in the same conditions
function Auxiliary.InfoCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end

--[[Costs that make you pay LP
val = Amount of LP to pay]]
function Auxiliary.PayLPCost(val)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.CheckLPCost(tp,val) end
				Duel.PayLPCost(tp,val)
			end
end