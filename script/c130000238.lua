--[[
Blocco Cascata
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")

if not Kappa then
	Kappa = {}
	Duel.LoadScript("glitchylib_archetypes.lua",false)
end

function s.initial_effect(c)
	--When your opponent's monster declares a direct attack: Target that monster; negate the attack, and if you do, Special Summon 2 "Kappa" monsters from your GY in face-down Defense Position, including a Normal Monster.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_SET)
	e1:SetCustomCategory(CATEGORY_NEGATE_ATTACK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--If your "Kappa" Normal Monster(s) is destroyed by battle while this card is in your GY: You can Set this card, but banish it when it leaves the field.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetCustomCategory(CATEGORY_SET_SPELLTRAP)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetCondition(s.spcon)
	e2:SetSSetSelfFunctions(false,true)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KAPPA}
s.lists_kappa_monster=true

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
function s.spfilter(c,e,tp)
	return c:IsKappa() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	local g=Duel.Group(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e)
		and Duel.GetMZoneCount(tp)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>=2 and g:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
	end
	Duel.SetTargetCard(tg)
	Duel.SetCustomOperationInfo(0,CATEGORY_NEGATE_ATTACK,tg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsRelateToChain() and Duel.NegateAttack() and Duel.GetMZoneCount(tp)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		local g=Duel.Group(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		if #g>=2 and g:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
			local sg=xgl.SelectUnselectGroup(0,g,e,tp,2,2,nil,1,tp,HINTMSG_SPSUMMON,nil,nil,false,aux.FilterBoolFunction(Card.IsType,TYPE_NORMAL))
			if #sg==2 then
				Duel.HintMessage(1-tp,HINTMSG_CONFIRM)
				sg:Select(1-tp,0,#sg,nil)
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end

--E2
function s.spconfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousTypeOnField(TYPE_NORMAL)
		and (c:IsPreviousSetCard(SET_KAPPA) or c:IsPreviousCodeOnField(table.unpack(OFFICIAL_CODES_KAPPA)))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end