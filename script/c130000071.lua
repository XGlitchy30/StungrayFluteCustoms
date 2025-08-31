--[[
Hieratic Shrine to The Spheres
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("glitchylib_delayed_event.lua")
local FLAG_MERGED_EVENT	=	id
function s.initial_effect(c)
	c:Activation()
	--[[Your opponent cannot target face-up monsters with 0 ATK or DEF for attacks.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.target)
	c:RegisterEffect(e1)
	--[[If a "Hieratic" monster(s) is Tributed: Take 1 Dragon monster from your GY, and either add it to your hand, or, if it is a "Hieratic" monster with a name different from the Tributed "Hieratic"
	monster(s), Special Summon it instead.]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_RELEASE,s.cfilter,FLAG_MERGED_EVENT,LOCATION_SZONE,nil,LOCATION_SZONE,aux.ReturnMergedID,nil,true,s.RegisterNameInTable,true)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetFunctions(aux.MergedDelayedEventCondition,nil,s.tgtg,s.tgop)
	c:RegisterEffect(e2)
	if not s.MergedDelayedEventInfotable then
		s.MergedDelayedEventInfotable={}
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TURN_END)
		ge1:OPT()
		ge1:SetOperation(s.resetop)
		Duel.RegisterEffect(ge1,0)
	end
	--[[You can reveal 1 Normal Monster in your hand; Special Summon 1 "Hieratic" monster from your hand.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:HOPT()
	e3:SetFunctions(
		nil,
		xgl.RevealCost(xgl.MonsterFilter(TYPE_NORMAL),1,1,nil),
		xgl.SpecialSummonTarget(nil,aux.FilterBoolFunction(Card.IsSetCard,SET_HIERATIC),LOCATION_HAND,0,1,1,nil),
		xgl.SpecialSummonOperation(nil,aux.FilterBoolFunction(Card.IsSetCard,SET_HIERATIC),LOCATION_HAND,0,1,1,nil)
	)
	c:RegisterEffect(e3)
end
s.listed_series={SET_HIERATIC}

function s.resetop()
	xgl.ClearTableRecursive(s.MergedDelayedEventInfotable)
	xgl.ClearTableRecursive(aux.DelayedEventRaiserTable)
end

--E1
function s.target(e,c)
	return c:IsAttack(0) or c:IsDefense(0)
end

--E2
function s.RegisterNameInTable(c)
	if not s.MergedDelayedEventInfotable[MERGED_ID] then
		s.MergedDelayedEventInfotable[MERGED_ID] = {}
	end
	local codes=c:IsPreviousLocation(LOCATION_MZONE) and {c:GetPreviousCodeOnField()} or {c:GetCode()}
	for _,code in ipairs(codes) do
		table.insert(s.MergedDelayedEventInfotable[MERGED_ID],code)
	end
end
function s.filter(c,eg,e,tp,ev,ftcheck)
	if not c:IsRace(RACE_DRAGON) then return false end
	return c:IsAbleToHand() or (ftcheck and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not xgl.FindInTable(s.MergedDelayedEventInfotable[ev],c:GetCode()))
end
function s.cfilter(c)
	if c:IsPreviousLocation(LOCATION_MZONE) then
		return c:IsPreviousSetCard(SET_HIERATIC)
	elseif not c:IsPreviousLocation(LOCATION_ONFIELD) then
		return c:IsMonsterType() and c:IsSetCard(SET_HIERATIC)
	else
		return false
	end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ftcheck=Duel.GetMZoneCount(tp)>0
	local tc=Duel.Select(HINTMSG_RESOLVEEFFECT,false,tp,aux.Necro(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,eg,e,tp,ev,ftcheck):GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp,
		function(c)
			return ftcheck and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not xgl.FindInTable(s.MergedDelayedEventInfotable[ev],c:GetCode())
		end,
		function(c)
			return Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,2))
	end
end