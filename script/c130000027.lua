--[[
Reclamation of Aramivir
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Add 1 monster that mentions an "Adventurer Token" from your Deck or GY to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; Tribute 1 "Adventurer Token", or 1 card that mentions it, then you can Special Summon 1 "Adventurer Token" (Fairy/EARTH/Level 4/ATK 2000/DEF 2000). You can only control 1 "Adventurer Token" Summoned this way.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_RELEASE|CATEGORIES_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,aux.bfgcost,s.rltg,s.rlop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_ADVENTURER}

--E1
function s.thfilter(c)
	return c:ListsCode(TOKEN_ADVENTURER) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--E2
function s.rlfilter(c)
	return (c:IsCode(TOKEN_ADVENTURER) or c:ListsCode(TOKEN_ADVENTURER)) and c:IsReleasableByEffect()
end
function s.chkfilter(c)
	return c:IsFaceup() and c:IsCode(TOKEN_ADVENTURER) and c:HasFlagEffect(id)
end
function s.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.rlfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return #g>0 end
	if not g:IsExists(Card.IsFacedown,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,tp,LOCATION_ONFIELD)
	else
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_ONFIELD)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.rlop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.rlfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Release(g,REASON_EFFECT)>0 and Duel.GetMZoneCount(tp)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ADVENTURER,0,TYPES_TOKEN,2000,2000,4,RACE_FAIRY,ATTRIBUTE_EARTH)
			and not Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local token=Duel.CreateToken(tp,TOKEN_ADVENTURER)
			if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
				token:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,0)
			end
		end
	end
end