--[[
Vixen Mixin Potion Shop
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:Activation()
	--[[You can send 1 card from your hand to the GY; Set 1 "Vixen Brew" Spell/Trap from your Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCustomCategory(CATEGORY_SET_SPELLTRAP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:HOPT()
	e1:SetCost(xgl.ToGraveCost(nil,LOCATION_HAND))
	e1:SetSSetFunctions(nil,nil,xgl.ArchetypeFilter(SET_VIXEN_BREW),LOCATION_DECK,0,1,1,nil)
	c:RegisterEffect(e1)
	--[[If you Summon exactly 1 "Valerie the Flamespear", and you control no other monsters (except during the Damage Step): You can add 1 "Flamespear Style" Spell/Trap from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:HOPT()
	e2:SetCondition(aux.AND(xgl.EventGroupCond(s.cfilter,1,1),s.thcon))
	e2:SetSearchFunctions(s.thfilter)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	e2:FlipSummonEventClone(c)
	--[[During damage calculation, if your Spellcaster monster battles: You can reveal any number of Spells/Traps with different names in your hand, and if you do, your battling monster gains 500 ATK/DEF for each card revealed, until the end of this turn.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORIES_ATKDEF)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_VALERIE_THE_FLAMESPEAR}
s.listed_series={SET_VIXEN_BREW,SET_FLAMESPEAR_STYLE}

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_MZONE,0,eg)==0
end
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsCode(CARD_VALERIE_THE_FLAMESPEAR) and c:IsSummonPlayer(tp)
end
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_FLAMESPEAR_STYLE)
end

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetBattleMonster(tp)
	return tc and tc:IsFaceup() and tc:IsRace(RACE_SPELLCASTER)
end
function s.rvfilt(c)
	return c:IsSpellTrap() and not c:IsPublic()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rvfilt,tp,LOCATION_HAND,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetBattleMonster(tp)
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		local sg=Duel.GetMatchingGroup(s.rvfilt,tp,LOCATION_HAND,0,nil)
		local ct=sg:GetClassCount(Card.GetCode)
		local g=xgl.SelectUnselectGroup(sg,e,tp,1,ct,xgl.dncheck,1,tp,HINTMSG_CONFIRM)
		if #g>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(#g*500)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end