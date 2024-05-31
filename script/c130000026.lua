--[[
Gaia the Firewing Pegasus Lancer
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id = GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--"Gaia the Fierce Knight" + "Firewing Pegasus"
	Fusion.AddProcMix(c,true,true,CARD_GAIA_THE_FIERCE_KNIGHT,CARD_FIREWING_PEGASUS)
	--This card's name becomes "Gaia the Fierce Knight" while it is on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(CARD_GAIA_THE_FIERCE_KNIGHT)
	c:RegisterEffect(e1)
	--If this card is Special Summoned: You can add 1 card from your Deck to your hand that mentions "Gaia the Fierce Knight" or "Firewing Pegasus" during the End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.regtg)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	--If this card, that was Special Summoned this turn, battles a Defense Position monster, your opponent cannot activate cards or effects until the end of the Damage Step.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetCondition(s.actcon)
	c:RegisterEffect(e3)
	if not s.unmarked_mentions then
		s.unmarked_mentions={[49328340]=true}
	end
end
s.listed_names={CARD_GAIA_THE_FIERCE_KNIGHT,CARD_FIREWING_PEGASUS}
s.material_setcode=SET_GAIA_THE_FIERCE_KNIGHT

--E2
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.thcon)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thfilter(c)
	if not c:IsAbleToHand() then return false end
	if c:ListsCode(CARD_GAIA_THE_FIERCE_KNIGHT,CARD_FIREWING_PEGASUS) then return true end
	local codes={c:GetCode()}
	for _,code in ipairs(codes) do
		if s.unmarked_mentions[code]==true then
			return true
		end
	end
	return false
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--E3
function s.actcon(e)
	local c=e:GetHandler()
	if not c:IsStatus(STATUS_SPSUMMON_TURN) then return false end
	local a,d=Duel.GetAttacker(),Duel.GetAttackTarget()
	if not a or not d then return false end
	if a~=c then
		a,d=d,a
	end
	return c==a and d:IsDefensePos()
end