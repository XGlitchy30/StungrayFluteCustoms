--[[
Ascetic Gathering
Card Author: Riku
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Add 1 Ritual Spell from your Deck to your hand, then add 1 non-Effect Ritual Monster from your Deck or GY to your hand whose name is mentioned on that Ritual Spell,
	or if you added "Regressed Ritual Art", you can add 1 non-Effect Ritual Monster from your Deck or GY to your hand, instead]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.thtg,s.thop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_REGRESSED_RITUAL_ART}

--E1
function s.thfilter1(c,tp,necro,forced)
	local f = necro and aux.Necro(s.thfilter2) or s.thfilter2
	return c:IsRitualSpell() and c:IsAbleToHand() and (not forced or Duel.IsExists(false,s.thfilter2,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,c,c))
end
function s.thfilter2(c,spell)
	if not c:IsRitualMonster() or not c:IsAbleToHand() then return false end
	return not c:IsType(TYPE_EFFECT) and (spell:IsCode(CARD_REGRESSED_RITUAL_ART) or c:IsMentionedByRitualSpell(spell))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.thfilter1,tp,LOCATION_DECK,0,1,nil,tp,false,true)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.ForcedSelect(HINTMSG_ATOHAND,false,tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tp,true,true)
	if #g>0 and Duel.SearchAndCheck(g,tp) then
		Duel.ShuffleHand(tp)
		local g2=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter2),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,g:GetFirst())
		if #g2>0 then
			Duel.BreakEffect()
			Duel.Search(g2,tp)
		end
	end
end