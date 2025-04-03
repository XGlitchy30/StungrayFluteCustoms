--Creates a cost function by merging the individual cost functions passed as paramters
function Glitchy.CreateCost(...)
	local x={...}
	if #x==0 then return end
	local f	=	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then
						for _,cost in ipairs(x) do
							if not cost(e,tp,eg,ep,ev,re,r,rp,chk) then
								return false
							end
						end
						return true
					end
					for _,cost in ipairs(x) do
						cost(e,tp,eg,ep,ev,re,r,rp,chk)
					end
				end
	return f
end

--Shows a description string to the opponent when the effect is activated. Useful for cards with multiple effects that can be activated in the same conditions
function Glitchy.InfoCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end

--Shadow cost that sets the label of the effect to 1. Useful for effects whose resolution depends on the cost
function Glitchy.LabelCost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end

--COSTS THAT INVOLVE THE ACTIVATOR OF THE EFFECT ITSELF
function Glitchy.BanishFacedownSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost(POS_FACEDOWN) end
	Duel.Remove(c,POS_FACEDOWN,REASON_COST)
end
function Glitchy.DiscardSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST|REASON_DISCARD)
end
function Glitchy.DetachSelfCost(min,max)
	if not min then min=1 end
	if not max or max<min then max=min end
	
	if min==max then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local c=e:GetHandler()
					if chk==0 then return c:CheckRemoveOverlayCard(tp,min,REASON_COST) end
					c:RemoveOverlayCard(tp,min,min,REASON_COST)
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
function Glitchy.RevealSelfCost(reset,rct)
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

function Glitchy.RemoveCounterSelfCost(ctype,min,max)
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
function Glitchy.ToDeckSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function Glitchy.ToExtraSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function Glitchy.ToGraveSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function Glitchy.ToHandSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHandAsCost() end
	Duel.SendtoHand(c,nil,REASON_COST)
end
function Glitchy.TributeSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end

--COST THAT INVOLVE MOVING CARDS

--Costs that discard a card(s) (min to max)
function Glitchy.DiscardCost(f,min,max,exc)
	f=xgl.DiscardFilter(f,true)
	min=min or 1
	max=max or min
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,LOCATION_HAND,0,min,exc) end
				Duel.DiscardHand(tp,f,min,max,REASON_COST|REASON_DISCARD,exc)
			end
end

--[[Costs that reveal a card(s) in hand
If reset is defined, the cards will be KEPT REVEALED in the hand and will return private knowledge only after the set timing]]
function Glitchy.RevealCost(f,min,max,exc,reset,rct)
	if not min then min=1 end
	if not max then max=min end
	
	if not reset then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local exc=(not exc) and nil or e:GetHandler()
					if chk==0 then return Duel.IsExistingMatchingCard(xgl.RevealFilter(f),tp,LOCATION_HAND,0,min,exc) end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
					local g=Duel.SelectMatchingCard(tp,xgl.RevealFilter(f),tp,LOCATION_HAND,0,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						Duel.ConfirmCards(1-tp,g)
					end
				end
	else
		if not rct then rct=1 end
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local exc=(not exc) and nil or e:GetHandler()
					if chk==0 then return Duel.IsExistingMatchingCard(xgl.RevealFilter(f),tp,LOCATION_HAND,0,min,exc) end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
					local g=Duel.SelectMatchingCard(tp,xgl.RevealFilter(f),tp,LOCATION_HAND,0,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
					for tc in aux.Next(g) do
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_PUBLIC)
						e1:SetReset(RESET_EVENT|RESETS_STANDARD|reset,rct)
						tc:RegisterEffect(e1)
					end
				end
	end
end

--Costs that send a card(s) (min to max) from a location(s) to the GY
function Glitchy.ToGraveCost(f,loc1,loc2,min,max,exc)
	f=xgl.ToGraveFilter(f,true)
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

-----------------------------------------------------------------------
--LP Payment Costs
function Glitchy.PayLPCost(lp)
	if not lp then lp=1000 end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.CheckLPCost(tp,lp) end
				Duel.PayLPCost(tp,lp)
			end
end
function Glitchy.PayHalfLPCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end

--RESTRICTIONS
--[[Scripts the following restriction: "You cannot Special Summon monsters the turn you activate/use this effect, except [f] monsters".
* f 	= Filter for the monsters that can still be SSed under the restriction
* oath	= If true, the restriction is not applied if the activation of the effect is negated
* reset	= Defines the reset timing for the restriction
* id	= ID used for the activity counter and the description string
* cf	= Filter for the activity counter (if not a function, it matches f). It supports LOCATION constants in order to exclude monsters Special Summoned from a specific location from being counted
		towards the restriction
* desc	= Description id (0 to 16)

OPTIONAL PARAMS:
* other = If true, it scripts "You cannot Special Summon OTHER monsters the turn you activate/use this effect, except [f] monsters"
* cost	= It is possible to invoke an additional user-defined cost function along with the one that handles the restriction.
]]
function Glitchy.SSRestrictionCost(f,oath,reset,id,cf,desc,...)
	local x={...}
	local cost	= #x>0 and x[#x] or nil
	local other	= #x>1 and x[#x-1] or nil
	
	if id then
		local donotcount_function = type(cf)=="function" and cf or f
		if type(cf)=="number" then
			local new_donotcount_function = function(c,...)
				return not c:IsSummonLocation(cf) or (donotcount_function and donotcount_function(c,...))
			end
			Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,new_donotcount_function)
		else
			Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,donotcount_function)
		end
	end
	local prop=EFFECT_FLAG_PLAYER_TARGET
	if oath then prop=prop|EFFECT_FLAG_OATH end
	if desc then prop=prop|EFFECT_FLAG_CLIENT_HINT end
	if not reset then reset=RESET_PHASE|PHASE_END end
	
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,chk)) end
				local e1=Effect.CreateEffect(e:GetHandler())
				if desc then
					e1:SetDescription(id,desc)
				end
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(prop)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetReset(reset)
				e1:SetTargetRange(1,0)
				if type(cf)~="number" then
					e1:SetTarget(	function(eff,c,sump,sumtype,sumpos,targetp,se)
										return (not f or not f(c,eff,sump,sumtype,sumpos,targetp,se)) and (not other or se~=e)
									end
								)
				else
					e1:SetTarget(	function(eff,c,sump,sumtype,sumpos,targetp,se)
										return (not f or not f(c,eff,sump,sumtype,sumpos,targetp,se)) and c:IsLocation(cf) and (not other or se~=e)
									end
								)
				end
				Duel.RegisterEffect(e1,tp)
				if cost then
					cost(e,tp,eg,ep,ev,re,r,rp,chk)
				end
			end
end

--TRIBUTE RELATED
function Glitchy.CheckReleaseGroupCost(tp,f,minc,maxc,extraGroup,use_hand,check,ex,...)
	local params={...}
	if type(maxc)~="number" then
		table.insert(params,1,ex)
		maxc,use_hand,check,ex=minc,maxc,use_hand,check
	end
	if not ex then ex=Group.CreateGroup() end
	local mg=Duel.GetReleaseGroup(tp,use_hand):Match(f or aux.TRUE,ex,table.unpack(params))
	if extraGroup then
		mg:Merge(extraGroup)
	end
	local g,exg=mg:Split(Auxiliary.ReleaseCostFilter,nil,tp)
	local specialchk=Auxiliary.MakeSpecialCheck(check,tp,exg,table.unpack(params))
	local mustg=g:Match(function(c,tp)return c:IsHasEffect(EFFECT_EXTRA_RELEASE) and c:IsControler(1-tp)end,nil,tp)
	local sg=Group.CreateGroup()
	return mg:Includes(mustg) and mg:IsExists(Auxiliary.RelCheckRecursive,1,nil,tp,sg,mg,exg,mustg,0,minc,maxc,specialchk)
end
function Glitchy.SelectReleaseGroupCost(tp,f,minc,maxc,extraGroup,use_hand,check,ex,...)
	if not ex then ex=Group.CreateGroup() end
	local mg=Duel.GetReleaseGroup(tp,use_hand):Match(f or aux.TRUE,ex,...)
	if extraGroup then
		mg:Merge(extraGroup)
	end
	local g,exg=mg:Split(Auxiliary.ReleaseCostFilter,nil,tp)
	local specialchk=Auxiliary.MakeSpecialCheck(check,tp,exg,...)
	local mustg=g:Match(function(c,tp)return c:IsHasEffect(EFFECT_EXTRA_RELEASE) and c:IsControler(1-tp)end,nil,tp)
	local sg=Group.CreateGroup()
	local cancel=false
	sg:Merge(mustg)
	while #sg<maxc do
		local cg=mg:Filter(Auxiliary.RelCheckRecursive,sg,tp,sg,mg,exg,mustg,#sg,minc,maxc,specialchk)
		if #cg==0 then break end
		cancel=Auxiliary.RelCheckGoal(tp,sg,exg,mustg,#sg,minc,maxc,specialchk)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local tc=Group.SelectUnselect(cg,sg,tp,cancel,cancel,1,1)
		if not tc then break end
		if #mustg==0 or not mustg:IsContains(tc) then
			if not sg:IsContains(tc) then
				sg=sg+tc
			else
				sg=sg-tc
			end
		end
	end
	if #sg==0 then return sg end
	if  #(sg&exg)>0 then
		local eff=(sg&exg):GetFirst():IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM)
		if eff then
			eff:UseCountLimit(tp,1)
			Duel.Hint(HINT_CARD,0,eff:GetHandler():GetCode())
		end
	end
	return sg
end