--[[
Aeriel Gishki
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_disclosure.lua")
function s.initial_effect(c)
	--Cannot be used as Synchro Material.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--If you Normal Summon a "Gishki" monster: You can Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	--[[You can discard 1 "Gishki" card; draw 1 card and reveal it, and if it is a "Gishki" card, you can increase or reduce the Levels of any number of monsters you control by up to 2.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DRAW|CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(nil,Cost.Discard(s.cfilter),s.drtg,s.drop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GISHKI}

--E1
function s.nsfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GISHKI)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:IsExists(s.nsfilter,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.cfilter(c)
	return c:IsSetCard(SET_GISHKI)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.lvfilter(c)
	return c:IsFaceup() and c:HasLevel()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local tc=Duel.GetOperatedGroup():GetFirst()
	Duel.RevealCards(1-tp,tc)
	if tc:IsSetCard(SET_GISHKI) and Duel.IsExists(false,s.lvfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local c=e:GetHandler()
		local pool=Duel.Group(s.lvfilter,tp,LOCATION_MZONE,0,nil)
		local escape=0
		while #pool>0 and escape<64 do
			escape=escape+1
			Duel.HintMessage(tp,HINTMSG_LVCHANGE)
			local mc=pool:Select(tp,0,1,nil):GetFirst()
			if mc then
				pool:RemoveCard(mc)
				Duel.HintSelection(mc)
				local opt=Duel.SelectEffect(tp,
					{true,aux.Stringid(id,3)},
					{true,aux.Stringid(id,4)},
					{mc:IsLevelAbove(2),aux.Stringid(id,5)},
					{mc:IsLevelAbove(3),aux.Stringid(id,6)})
				local val=({1,2,-1,-2})[opt]
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_LEVEL)
				e1:SetValue(val)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				mc:RegisterEffect(e1)
			else
				break
			end
		end
	end
	Duel.ShuffleHand(tp)
end