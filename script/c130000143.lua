--[[
Ancestagon Triceraprisma
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
if not Ancestagon then
	Ancestagon = {}
	Duel.LoadScript("glitchylib_archetypes.lua",false)
end
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--[[Once per turn, when an "Ancestagon" monster(s) is Summoned to your field (except during the Damage Step): You can Special Summon 1 "Ancestagon Token" (Dinosaur/FIRE/Level 2/0 ATK/0 DEF), but
	it cannot be used as Fusion, Synchro, or Link Material, except for the Summon of an "Ancestagon" monster.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(0,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:OPT(true)
	e1:SetFunctions(
		xgl.EventGroupCond(s.cfilter),
		nil,
		s.tktg,
		s.tkop
	)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	e1:FlipSummonEventClone(c)
	--[[If this card is face-up in your Extra Deck: You can Tribute 2 "Ancestagon" monsters; Special Summon this card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCost(Ancestagon.DukeSilveraptorTributeCost)
	e2:SetSpecialSummonSelfFunctions(true)
	c:RegisterEffect(e2)
	--[[Your opponent cannot target cards in your Pendulum Zones with card effects.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_PZONE,0)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--[[Up to twice per turn, when your opponent activates a card or effect that targets a card(s) on your field, GY and/or banishment (Quick Effect): You can Tribute 1 "Ancestagon" Monster Card from
	your Monster Zone or Pendulum Zone; negate the activation, and if you do, destroy that card.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:OPT(2)
	e4:SetFunctions(s.negcon,s.negcost,s.negtg,s.negop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_ANCESTAGON}

--E1
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsSetCard(SET_ANCESTAGON) and c:IsControler(tp)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ANCESTAGON,SET_ANCESTAGON,TYPES_TOKEN,0,0,2,RACE_DINOSAUR,ATTRIBUTE_FIRE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if s.tktg(e,tp,eg,ep,ev,re,r,rp,0) then
		local token=Duel.CreateToken(tp,TOKEN_ANCESTAGON)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(id,3)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
			e1:SetValue(s.matlimit)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.matlimit(e,sc,sumtype,tp)
	if sc:IsSetCard(SET_ANCESTAGON) then return false end
	local not_allowed={SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_LINK}
	local sum=(SUMMON_TYPE_FUSION|SUMMON_TYPE_SYNCHRO|SUMMON_TYPE_LINK)&sumtype
	for _,val in pairs(not_allowed) do
		if sum==val then return true end
	end
	return false
end

--E3
function s.tfilter(c,tp)
	return (c:IsOnField() or c:IsLocation(LOCATION_GB)) and c:IsControler(tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local extraGroup=Duel.Group(aux.FilterBoolFunction(Card.IsSetCard,SET_ANCESTAGON),tp,LOCATION_PZONE,0,nil):Filter(Card.IsReleasable,nil)
	if chk==0 then return xgl.CheckReleaseGroupCost(tp,Card.IsSetCard,1,1,extraGroup,false,nil,nil,SET_ANCESTAGON) end
	local g=xgl.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,extraGroup,false,nil,nil,SET_ANCESTAGON)
	Duel.Release(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end