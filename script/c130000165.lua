--[[
Valerie the Flamespear
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you activate a Spell Card (except during the Damage Step): You can Special Summon this card from your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT()
	e1:SetCondition(s.spcon)
	e1:SetSpecialSummonSelfFunctions()
	c:RegisterEffect(e1)
	--[[If you control a Level 7 or higher Spellcaster or a Dragon Fusion Monster that lists "Dark Magician" or "Dark Magician Girl" as material: You can shuffle 1 Spellcaster monster from your GY or banishment into your Deck; add 1 Spell/Trap from your GY to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetLabel(0)
	e2:SetFunctions(
		xgl.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),
		s.thcost,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL}

--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsSpellEffect()
end

--E2
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard({SET_FLAMESPEAR_STYLE,SET_VIXEN_BREW})
end

--E3
function s.cfilter(c)
	return c:IsFaceup() and ((c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7)) or (c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and c:ListsCodeAsMaterial(CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL)))
end
function s.thcostfilter(c,tp)
	return c:IsFaceupEx() and c:IsMonsterType() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToDeckAsCost()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c)
end
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_GB,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_GB,0,1,1,nil,tp)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local IsCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		return IsCostChecked or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end