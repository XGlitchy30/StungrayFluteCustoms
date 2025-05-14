--[[
Ancestagon Plasmatail
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_target.lua")
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--[[You can add this card from your Pendulum Zone to your Extra Deck, face-up; excavate the top 5 cards of your Deck, add 1 excavated Level 8 or higher "Ancestagon" monster to your Extra Deck
	face-up, also place the remaining cards on the bottom of the Deck in any order.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		xgl.ToExtraFaceupSelfCost,
		s.tetg,
		s.teop
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal Summoned: You can add 1 "Ancestagon" Spell/Trap from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetSearchFunctions(xgl.SpellTrapFilter(Card.IsSetCard,SET_ANCESTAGON))
	c:RegisterEffect(e2)
	--[[If this card is Pendulum Summoned: You can discard 1 card; banish 1 card from your opponent's GY.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:HOPT()
	e3:SetCondition(xgl.PendulumSummonedCond)
	e3:SetCost(Cost.Discard())
	e3:SetSendtoFunctions(LOCATION_REMOVED,false,nil,0,LOCATION_GRAVE,1,1,nil)
	c:RegisterEffect(e3)
	--[[If this card is Tributed: You can activate this effect; for the rest of this turn, monsters your opponent controls cannot target "Ancestagon" monsters you control with card effects that would
	not destroy them.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,3)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_RELEASE)
	e4:HOPT()
	e4:SetFunctions(nil,nil,nil,s.efop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_ANCESTAGON}
s.PreventLoop = 0

--E1
function s.exctefilter(c)
	local eset={c:IsHasEffect(EFFECT_CANNOT_TO_EXTRA_P)}
	for _,e in ipairs(eset) do
		if e:GetOwner()~=c then
			return false
		end
	end
	return true
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetDecktopGroup(tp,5)
		return #g==5 and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_TO_EXTRA_P) and g:FilterCount(s.exctefilter,nil)>0
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.tefilter(c,e,tp)
	return c:IsLevelAbove(8) and c:IsSetCard(SET_ANCESTAGON) and c:IsAbleToExtraFaceup(e,tp)
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5):Filter(s.tefilter,nil,e,tp)
	local ct=0
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOEXTRA)
		local sg=g:Select(tp,1,1,nil)
		Duel.DisableShuffleCheck()
		if Duel.SendtoExtraP(g,tp,REASON_EFFECT)>0 then
			ct=Duel.GetGroupOperatedByThisEffect(e):FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_DECK)
		end
	end
	local ac=5-ct
	if ac>0 then
		Duel.MoveToDeckBottom(ac,tp)
		Duel.SortDeckbottom(tp,tp,ac)
	end
end

--E4
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tgtg)
	e1:SetValue(s.tgval)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(CARD_ANCESTAGON_PLASMATAIL)
	e2:SetTarget(aux.FilterBoolFunction(Card.IsSetCard,SET_ANCESTAGON))
	e2:SetValue(1-tp)
	Duel.RegisterEffect(e2,tp)
end
function s.tgtg(e,c)
	local res=c:IsSetCard(SET_ANCESTAGON)
	if res then
		e:SetLabelObject(c)
	end
	return res
end
function s.tgval(e,re,rp)
	local tp=e:GetHandlerPlayer()
	if not (rp==1-tp and re:IsMonsterEffect()) or re:IsHasCustomCategory(nil,CATEGORY_FLAG_ANCESTAGON_PLASMATAIL) then return false end
	if not re:IsHasCategory(CATEGORY_DESTROY) then return true end
	
	local params
	local res=false
	local eff,loc,p=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_CONTROLER)
	if not eff or eff~=re then
		params={re,rp,last_eg,last_ep,last_ev,last_re,last_r,last_rp,CHK_ANCESTAGON_PLASMATAIL}
		local rc=re:GetHandler()
		res=rc:IsLocation(LOCATION_MZONE) and rc:IsControler(rp)
	else
		local eg,ep,ev,reff,r,rplayer = Duel.GetChainEvent(0)
		params={re,rp,eg,ep,ev,reff,r,rplayer,CHK_ANCESTAGON_PLASMATAIL}
		res=loc&LOCATION_MZONE>0 and p==rp
	end
	if not res then return false end
	local tgfunc=re:GetTarget()
	if not tgfunc then return false end
	if not xgl.AncestagonPlasmatailPreventLoop and s.PreventLoop<3 then
		s.PreventLoop = s.PreventLoop+1
		local returns=tgfunc(table.unpack(params))
		for _,ret in ipairs(returns) do
			local cat,tab=table.unpack(ret)
			if cat==CATEGORY_DESTROY then
				local infoct,infop,infoval,f,povp,loc1,loc2,min,max,exc = table.unpack(tab)
				local extra={}
				if #tab>10 then
					for i=11,#tab do
						table.insert(extra,tab[i])
					end
				end
				local locchk
				if povp then
					locchk = (povp==tp and loc1&LOCATION_MZONE>0) or (povp==1-tp and loc2&LOCATION_MZONE>0)
				else
					locchk = infop==tp and infoval&LOCATION_MZONE>0
				end
				if locchk and (infoct==0 or (max and infoct==max)) then
					local c=e:GetLabelObject()
					if not f or f(c,table.unpack(extra)) then
						s.PreventLoop = 0
						return false
					end
				end
			end
		end
	end
	s.PreventLoop = 0
	return true
end