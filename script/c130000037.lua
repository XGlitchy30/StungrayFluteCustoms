--[[
Moblins' Mask Maker
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[The first time this card would be destroyed by battle each turn, it is not destroyed]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)
	--[[If this card's current ATK is different from its original ATK (Quick Effect): You can discard 1 card; add 1 "Moblins" Spell/Trap from your GY to your hand]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetRelevantTimings()
	e2:SetFunctions(
		s.thcon,
		xgl.DiscardCost(nil,1),
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MOBLINS}

--E1
function s.valcon(e,re,r,rp)
	return (r&REASON_BATTLE)~=0
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsAttack(c:GetBaseAttack())
end
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_MOBLINS) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.PlayerHasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end