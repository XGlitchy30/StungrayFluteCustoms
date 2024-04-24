--[[
Numbers Revolution
Card Author: Fishy
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchylib_delayed_event.lua")
function s.initial_effect(c)
	c:Activation()
	--[[While you have 4000 or less LP, you can activate and resolve the effects of "Number" Xyz Monsters you control that require you to have 1000 LP or less to activate and/or resolve
	them even if you do not have 1000 LP or less]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(CARD_NUMBERS_REVOLUTION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.lpcon)
	e1:SetTarget(s.lptg)
	c:RegisterEffect(e1)
	--[[Once while this card is face-up on the field, if you Xyz Summon a "Number" Xyz Monster (except during the Damage Step): You can pay 500 LP;
	attach 1 monster from your Deck to that Xyz Summoned monster, but you cannot activate the effects of monsters with that name for the rest of the turn.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_SPSUMMON_SUCCESS,s.cfilter,id,LOCATION_FZONE,false,LOCATION_FZONE)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCustomCategory(CATEGORY_ATTACH)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_FZONE)
	e2:OPT()
	e2:SetFunctions(nil,aux.PayLPCost(500),s.attg,s.atop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NUMBER}

--E1
function s.lpcon(e)
	return Duel.GetLP(e:GetHandlerPlayer())<=4000
end
function s.lptg(e,c,p,re,val,chk)
	if val>1000 then return false end
	if chk==0 then
		return c:IsFaceup() and c:IsControler(e:GetHandlerPlayer()) and c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_NUMBER)
	elseif chk==1 then
		local player,loc,settab = Duel.GetChainInfo(0,
			CHAININFO_TRIGGERING_CONTROLER,
			CHAININFO_TRIGGERING_LOCATION,
			CHAININFO_TRIGGERING_SETCODES
		)
		local setchk=false
		if #settab==0 then return false end
		for _,setc in ipairs(settab) do
			if setc&SET_NUMBER==SET_NUMBER then
				setchk=true
				break
			end
		end
		return setchk and player==e:GetHandlerPlayer() and loc&LOCATION_MZONE==LOCATION_MZONE and re:IsActiveType(TYPE_XYZ)
	end
	return false
end

--E2
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
function s.xyzfilter(c,tp)
	return c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
end
function s.atfilter(c,xyzc,tp)
	return c:IsMonster() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.xyzfilter,1,nil,tp)
	end
	Duel.SetTargetCard(eg)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,1,tp,LOCATION_DECK,eg,1)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(s.xyzfilter,nil,tp)
	if #g==0 then return end
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACHTO)
		g=g:Select(tp,1,1,nil,tp)
		Duel.HintSelection(g)
	end
	local xyzc=g:GetFirst()
	local atc=Duel.Select(HINTMSG_XMATERIAL,false,tp,s.atfilter,tp,LOCATION_DECK,0,1,1,nil,xyzc,tp):GetFirst()
	if atc and Duel.Attach(atc,xyzc) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(id,1)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetLabel(atc:GetCode())
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end