--[[
Percussion Beetle Thud
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchymods_xyz.lua")
function s.initial_effect(c)
	--[[You can target 1 "Percussion Beetle" monster you control; increase its Level by 1, and if you do, Special Summon this card from your hand, and if you do that, increase this card's Level by 1.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If this card is detached from a LIGHT Xyz Monster: You can target 1 Set Spell/Trap your opponent controls; it cannot be activated this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_MOVE)
	e2:HOPT()
	e2:SetFunctions(s.limcon,nil,s.limtg,s.limop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PERCUSSION_BEETLE}

--E1
function s.lvfilter(c)
	return c:IsSetCard(SET_PERCUSSION_BEETLE) and c:IsFaceup() and c:HasLevel()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExists(true,s.lvfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g+c,2,tp,1)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:HasLevel() then
		local c=e:GetHandler()
		local e1,diff,reg=xgl.UpdateLevel(tc,1,true,{c,true})
		if reg and not tc:IsImmuneToEffect(e1) and diff>0 and c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsFaceup() and c:HasLevel() then
			xgl.UpdateLevel(c,1,true,{c,true})
		end
	end
end

--E2
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_DECK|LOCATION_HAND) or c:IsBanished(POS_FACEDOWN) or not c:IsPreviousLocation(LOCATION_OVERLAY) then
		return false
	end
	local rc=c:GetPreviousXyzHolder()
	return rc:IsFaceup() and rc:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.limtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(s.cafilter,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
	Duel.SelectTarget(tp,s.cafilter,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToChain() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(STRING_CANNOT_TRIGGER)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end