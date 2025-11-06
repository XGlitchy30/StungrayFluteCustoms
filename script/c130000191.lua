--[[
Flight of the Vic Viper
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

if not Gradius then
	Gradius = {}
	Duel.LoadScript("glitchylib_archetypes.lua",false)
end

function s.initial_effect(c)
	--When this card is activated: Add 1 LIGHT Machine monster with the effect "If this card destroys an opponent's monster by battle", or "Vic Viper T301", from your Deck to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	local tgfunc=aux.TargetBoolFunction(s.cfilter)
	--During your Main Phase, you can Normal Summon 1 LIGHT Machine monster with the effect "If this card destroys an opponent's monster by battle", or "Vic Viper T301", in addition to your Normal Summon/Set.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e2:SetTarget(tgfunc)
	c:RegisterEffect(e2)
	--All LIGHT Machine monsters with the effect "If this card destroys an opponent's monster by battle" and "Vic Viper T301" gain 500 ATK, also, they gain 1 additional attack each Battle Phase.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(tgfunc)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetCustomCategory(0,CATEGORY_FLAG_INCREMENTAL)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(tgfunc)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	Gradius.RegisterAlpiniaCopyCheck(s)
end
s.listed_names={CARD_VIC_VIPER_T301}

--E1
function s.cfilter(c)
	if c:IsCode(CARD_VIC_VIPER_T301) then return true end
	if c:IsAttributeRace(ATTRIBUTE_LIGHT,RACE_MACHINE) and c:IsType(TYPE_EFFECT) then
		local eset={c:GetOwnEffects()}
		for _,e in ipairs(eset) do
			if e:IsHasCustomCategory(0,CATEGORY_FLAG_ALPINIA) then
				return true
			end
		end
		
		if Gradius.AlpiniaTable[c:GetOriginalCode()] or c:HasFlagEffect(CARD_ALPINIA) then
			return true
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end

--E4
function s.atkval(e,c,return_only_incr)
	if return_only_incr then return 1 end
	local ct=c:GetAttackAnnouncedCount()
	local extra_total_base, extra_total_incr = 0, 0
	local eset={c:GetCardEffect(EFFECT_EXTRA_ATTACK)}
	for _,ce in ipairs(eset) do
		if ce:IsHasCustomCategory(nil,CATEGORY_FLAG_INCREMENTAL) then
			local n=ce:Evaluate(c,true)
			extra_total_incr = extra_total_incr + n
		else
			local n=ce:Evaluate(c)
			extra_total_base = math.max(n,extra_total_base)
		end
	end
	local a=Duel.GetAttacker()
	local extra_total=extra_total_base + extra_total_incr + 1
	if ct<extra_total or (ct==extra_total and a and a==c) then
		return ct
	else
		return 0
	end
end