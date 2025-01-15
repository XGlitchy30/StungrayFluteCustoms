--[[
Queltz Apparition
Card Author: LimitlessSocks
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control no monsters, or if you control a Ritual Monster: Special Summon this card as an Effect Monster (Thunder/FIRE/Level 8/ATK 1600/DEF 4000) with the following effect. (This card is
	also still a Trap.)]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	if not s.ritual_matching_function then
		s.ritual_matching_function={}
	end
	s.ritual_matching_function[c]=aux.FilterEqualFunction(Card.IsSetCard,SET_QUELTZ)
end
s.listed_series={SET_QUELTZ}

--E1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==0 or g:IsExists(aux.FaceupFilter(Card.IsRitualMonster),1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_QUELTZ,TYPE_MONSTER|TYPE_EFFECT,1600,4000,8,RACE_THUNDER,ATTRIBUTE_FIRE,POS_FACEUP,tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and s.sptg(e,tp,eg,ep,ev,re,r,rp,0) then
		c:AddMonsterAttribute(TYPE_EFFECT|TYPE_TRAP)
		Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
		--[[Once per opponent's turn: You can activate this effect; Ritual Summon 1 "Queltz" Ritual Monster from your hand or GY, by Tributing monsters in this card's column from either field,
		including this card, whose total Levels equal or exceed twice its Level.]]
		local e1=Ritual.CreateProc({
			handler=c,
			lvtype=RITPROC_GREATER,
			filter=aux.FilterBoolFunction(Card.IsSetCard,SET_QUELTZ),
			location=LOCATION_HAND|LOCATION_GRAVE,
			lv=function(c) return c:GetLevel()*2 end,
			matfilter=s.matfilter,
			extrafil=s.extrafil,
			forcedselection=function(e,tp,g,sc) return g:IsContains(e:GetHandler()) end
		})
		e1:SetDescription(id,1)
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_RELEASE)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_MZONE)
		e1:OPT()
		e1:SetCondition(xgl.TurnPlayerCond(1))
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		local op=e1:GetOperation()
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			local c=e:GetHandler()
			if not c:IsRelateToChain() or (c:IsControler(1-tp) and not c:IsFaceup()) then return end
			op(e,tp,eg,ep,ev,re,r,rp)
		end)
		c:RegisterEffect(e1,true)
		c:AddMonsterAttributeComplete()
	end
	Duel.SpecialSummonComplete()
end
function s.matfilter(c,e,tp)
	local h=e:GetHandler()
	return c==h or h:GetColumnGroup():IsContains(c)
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	local h=e:GetHandler()
	return h:GetColumnGroup():Filter(aux.FaceupFilter(Card.IsControler,1-tp),nil)
end