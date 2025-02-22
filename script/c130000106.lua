--[[
Fienthalete Ripcord
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[You can Special Summon this card (from your hand) by discarding a Fiend monster. You can only Special Summon "Fienthalete Ripcord" once per turn this way.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT(true)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--[[If this card is Summoned to a zone a "Fienthalete" Link Monster points to: You can make this card lose 700 ATK, and if you do, 1 "Fienthalete" Link Monster you control gains 700 ATK.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(
		s.atkcon,
		nil,
		s.atktg,
		s.atkop
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	e2:FlipSummonEventClone(c)
	--While this card has 1000 ATK or less, it can attack your opponent directly.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(s.diratkcon)
	c:RegisterEffect(e3)
end
s.listed_series={SET_FIENTHALETE}

--E1
function s.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsDiscardable()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_DISCARD,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_DISCARD|REASON_COST|REASON_SUMMON)
	g:DeleteGroup()
end

--E2
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(SET_FIENTHALETE)
end
function s.lkfilter(c,hc)
	return s.filter(c) and c:GetLinkedGroup():IsContains(hc)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExists(false,s.lkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetAdditionalOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,-700)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,700)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		local e1,diff,reg=c:UpdateATK(-700,true,{c,true})
		if reg and not c:IsImmuneToEffect(e1) and diff<=0 then
			local g=Duel.Select(HINTMSG_FACEUP,false,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
			if Duel.Highlight(g) then
				g:GetFirst():UpdateATK(700,true,{c,true})
			end
		end
	end
end

--E3
function s.diratkcon(e)
	return e:GetHandler():IsAttackBelow(1000)
end