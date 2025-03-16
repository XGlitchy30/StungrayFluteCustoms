--[[
Elemental HERO Mirror Master
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If this card is Normal or Special Summoned: You can send 1 "Elemental HERO" monster from your hand or Deck to the GY; this card's name becomes that card's name,
	also this card's Attribute becomes that card's Attribute, until the end of your next turn]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		xgl.LabelCost,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[If this card is sent to your GY: You can target 1 Level 4 or lower "Elemental HERO" Normal Monster in your GY; Special Summon it in Defense Position.
	You cannot Special Summon monsters from the Extra Deck, except Fusion Monsters, the turn you use this effect.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		s.spcost,
		xgl.SpecialSummonTarget(true,s.spfilter,LOCATION_GRAVE,0,1,1,nil,0,false,false,false,false,POS_FACEUP_DEFENSE),
		xgl.SpecialSummonOperation(TGCHECK_IT,s.spfilter,LOCATION_GRAVE,0,1,1,nil,0,false,false,false,false,POS_FACEUP_DEFENSE)
	)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={SET_ELEMENTAL_HERO}

--E1
function s.tgfilter(c,attr,...)
	return c:IsMonster() and c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsAbleToGraveAsCost() and (c:IsAttributeExcept(attr) or not c:IsCode(...))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cattr,ccodes=c:GetAttribute(),{c:GetCode()}
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExists(false,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,cattr,table.unpack(ccodes))
	end
	e:SetLabel(0)
	local tc=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,cattr,table.unpack(ccodes)):GetFirst()
	if tc then
		local eid=e:GetFieldID()
		Duel.SetTargetParam(eid)
		local codes,attr={tc:GetCode()},tc:GetAttribute()
		local fe=c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,0)
		fe:SetLabel(eid,attr,table.unpack(codes))
		Duel.SendtoGrave(tc,REASON_COST)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or c:IsFacedown() or not c:HasFlagEffect(id) then return end
	local fe=c:GetFlagEffectWithSpecificLabel(id,Duel.GetTargetParam())
	if not fe then return end
	local attr,codes=nil,{}
	for i,elem in ipairs({fe:GetLabel()}) do
		if i==2 then
			attr=elem
		elseif i>2 then
			table.insert(codes,elem)
		end
	end
	if #codes>0 then
		local main_code=codes[1]
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
		e1:SetValue(main_code)
		c:RegisterEffect(e1)
		table.remove(codes,1)
		if #codes>0 then
			for _,additional_code in ipairs(codes) do
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_ADD_CODE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
				e2:SetValue(additional_code)
				c:RegisterEffect(e2)
			end
		end
	end
	if attr then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetValue(attr)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
		c:RegisterEffect(e3)
	end
end

--E2
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(id,2)
	e2:SetReset(RESET_PHASE|PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_FUSION)
end
function s.spfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsLevelBelow(4)
end