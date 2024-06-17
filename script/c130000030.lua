--[[
Mega Polymerization
Card Author: Sock
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
Duel.LoadScript("mods_fusion.lua")
function s.initial_effect(c)
	aux.FusionSelectMixMod=true
	aux.FusionSummonEffFilterMod=true
	--Discard 1 card, then target 1 or more monsters you control; Fusion Summon 1 Fusion Monster from your Extra Deck, using all those targets as material, and up to that many monsters your opponent controls, as Fusion Material. You can only activate 1 "Mega Polymerization" per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--E1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.matfilterself(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsCanBeEffectTarget(e) and not c:IsImmuneToEffect(e)
end
function s.matfilteroppo(c,p)
	return c:IsMonster() and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(p)
end
function s.fextra(ct)
	return	function(e,tp,mg)
				return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil),s.fextracheck(ct)
			end
end
function s.fextracheck(ct)
	return	function(tp,sg,fc)
				return sg:FilterCount(s.matfilteroppo,nil,1-tp)<=ct
			end
end
function s.fcheck(g,e,tp,mg,c)
	local res=Fusion.SummonEffTG(nil,s.matfilter(g),s.fextra(#g),nil,g,nil,nil,nil,nil,nil,nil,nil,nil,#g,nil,nil)(e,tp,nil,nil,nil,nil,nil,nil,0)
	return res,false
end
function s.matfilter(g)
	return	function(c)
				return g:IsContains(c)
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local self=Duel.GetFusionMaterial(tp):Filter(s.matfilterself,nil,e,tp)
	if chk==0 then
		return aux.SelectUnselectGroup(self,e,tp,1,#self,s.fcheck,0)
	end
	local tg=aux.SelectUnselectGroup(self,e,tp,1,#self,s.fcheck,1,tp,HINTMSG_FMATERIAL,s.fcheck,false,false)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.tgcheck(c,e,tp)
	return c:IsImmuneToEffect(e) or not c:IsControler(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g0=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=Duel.GetTargetCards()
	if #g~=#g0 or g:IsExists(s.tgcheck,1,nil,e,tp) then return end
	Fusion.SummonEffOP(nil,s.matfilter(g),s.fextra(#g),nil,g,nil,nil,nil,nil,nil,nil,nil,#g,nil,nil)(e,tp,eg,ep,ev,re,r,rp)
end