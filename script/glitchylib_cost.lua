--Shows a description string to the opponent when the effect is activated. Useful for cards with multiple effects that can be activated in the same conditions
function Auxiliary.InfoCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end

--Shadow cost that sets the label of the effect to 1. Useful for effects whose resolution depends on the cost
function Auxiliary.LabelCost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end

--[[Costs that make you pay LP
val = Amount of LP to pay]]
function Auxiliary.PayLPCost(val)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.CheckLPCost(tp,val) end
				Duel.PayLPCost(tp,val)
			end
end

--COSTS THAT INVOLVE THE ACTIVATOR OF THE EFFECT ITSELF
function Auxiliary.BanishFacedownSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost(POS_FACEDOWN) end
	Duel.Remove(e:GetHandler(),POS_FACEDOWN,REASON_COST)
end
function Auxiliary.DiscardSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function Auxiliary.DetachSelfCost(min,max)
	if not min then min=1 end
	if not max or max<min then max=min end
	
	if min==max then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,min,REASON_COST) end
					e:GetHandler():RemoveOverlayCard(tp,min,min,REASON_COST)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then
						for i=min,max do
							if c:CheckRemoveOverlayCard(tp,i,REASON_COST) then
								return true
							end
						end
						return false
					end
					local list={}
					for i=min,max do
						if c:CheckRemoveOverlayCard(tp,i,REASON_COST) then
							table.insert(list,i)
						end
					end
					if #list==0 then return end
					if #list==max-min then
						c:RemoveOverlayCard(tp,min,max,REASON_COST)
					else
						local ct=Duel.AnnounceNumber(tp,table.unpack(list))
						c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
					end
				end
	end
end

--[[Costs that require the activator to reveal itself from the hand
► reset: If not defined, the cost simply requires the activator to be revealed to the opponent momentarily. Otherwise, the cost will require the activator to be kept revealed as long as the EFFECT_PUBLIC effect does not expire: this parameter sets the condition for the aforementioned effect's expiration.
► rct: If reset is defined by passing a RESET_PHASE constant, you can specify the exact phase of the Duel when the expiration takes place (2nd, 3rd, next, ...)
]]
function Auxiliary.RevealSelfCost(reset,rct)
	if not rct then rct=1 end
	
	if not reset then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then return not c:IsPublic() end
				Duel.ConfirmCards(1-tp,c)
			end
	else
		if not rct then rct=1 end
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then return not c:IsPublic() end
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_PUBLIC)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
					c:RegisterEffect(e1)
				end
	end
end

function Auxiliary.RemoveCounterSelfCost(ctype,min,max)
	if not min then min=1 end
	if not max or max<min then max=min end
	
	if min==max then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then return c:IsCanRemoveCounter(tp,ctype,min,REASON_COST) end
					c:RemoveCounter(tp,ctype,min,REASON_COST)
				end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then
						for i=min,max do
							if c:IsCanRemoveCounter(tp,ctype,i,REASON_COST) then
								return true
							end
						end
						return false
					end
					local list={}
					for i=min,max do
						if c:IsCanRemoveCounter(tp,ctype,i,REASON_COST) then
							table.insert(list,i)
						end
					end
					if #list==0 then return end
					local ct=Duel.AnnounceNumber(tp,table.unpack(list))
					c:RemoveCounter(tp,ctype,ct,REASON_COST)
				end
	end
end
function Auxiliary.ToDeckSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function Auxiliary.ToExtraSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function Auxiliary.ToGraveSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function Auxiliary.TributeSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end

--COST THAT INVOLVE MOVING CARDS

--Costs that discard a card(s) (min to max)
function Auxiliary.DiscardCost(f,min,max,exc)
	f=aux.DiscardFilter(f,true)
	min=min or 1
	max=max or min
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,LOCATION_HAND,0,min,exc) end
				Duel.DiscardHand(tp,f,min,max,REASON_COST|REASON_DISCARD,exc)
			end
end

--Costs that send a card(s) (min to max) from a location(s) to the GY
function Auxiliary.ToGraveCost(f,loc1,loc2,min,max,exc)
	f=aux.ToGraveFilter(f,true)
	loc1=loc1 or LOCATION_ONFIELD
	loc2=loc2 or 0
	min=min or 1
	max=max or min
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local g=Duel.SelectMatchingCard(tp,f,tp,loc1,loc2,min,max,exc,e,tp)
				if #g>0 then
					local ct=Duel.SendtoGrave(g,REASON_COST)
					return g,ct
				end
				return g,0
			end
end