--[[
Morning Prayers in Necrovalley
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:Activation()
	--During your Main Phase, you can Normal Summon 1 "Gravekeeper's" monster each turn in addition to your Normal Summon/Set. (You can only gain this effect once per turn.)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GRAVEKEEPERS))
	c:RegisterEffect(e1)
	--Once per turn: You can target 1 "Gravekeeper's" monster you control and 1 "Gravekeeper's" monster in your GY; the first target gains ATK equal to the Level of the second target x 100 until the end of this turn.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GRAVEKEEPERS}

--E2
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GRAVEKEEPERS)
end
function s.gyfilter(c)
	return c:IsSetCard(SET_GRAVEKEEPERS) and c:IsLevelAbove(1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g1,#g1,tp,g2:GetFirst():GetLevel()*100)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards()
	if #tg~=2 then return end
	local g1,g2=tg:Split(Card.IsLocation,nil,LOCATION_MZONE)
	local tc1,tc2=g1:GetFirst(),g2:GetFirst()
	if s.filter(tc1) and s.gyfilter(tc2) then
		tc1:UpdateATK(tc2:GetLevel()*100,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
	end
end