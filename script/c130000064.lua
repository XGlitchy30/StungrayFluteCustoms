--[[
Tempest Salvo
Card Author: LimitlessSocks
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If your opponent controls 2 or more monsters than you do, you can Special Summon this card (from your hand).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spscon)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY, except the turn it was sent there, then target 2 Equip Spells in your GY; your opponent banishes 1 of them, and you add the other to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE|CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(aux.exccon,aux.bfgcost,s.target,s.operation)
	c:RegisterEffect(e2)
	--[[You cannot Summon monsters, except Machine monsters]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.sumlimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e6)
end

--E1
function s.spscon(e,c)
	if c==nil then return true end
	local p=c:GetControler()
	return Duel.GetLocationCount(p,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(p,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(p,LOCATION_MZONE,0)>=2
end

--E2
function s.filter(c,e,p)
	return c:IsEquipSpell() and c:IsCanBeEffectTarget(e) and (c:IsAbleToRemove(p) or c:IsAbleToHand())
end
function s.gcheck(g,e,tp,mg,c)
	if #g==1 then return true end
	local c1,c2=g:GetFirst(),g:GetNext()
	return (c1:IsAbleToRemove(1-tp) and c2:IsAbleToHand()) or (c2:IsAbleToRemove(1-tp) and c1:IsAbleToHand())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.Group(s.filter,tp,LOCATION_GRAVE,0,nil,e,1-tp)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,0)
	end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
function s.rmfilter(c,p,g)
	return c:IsAbleToRemove(p) and g:IsExists(Card.IsAbleToHand,1,c)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g~=2 then return end
	Duel.HintMessage(1-tp,HINTMSG_REMOVE)
	local rg=g:FilterSelect(1-tp,s.rmfilter,1,1,nil,1-tp,g)
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		g:Sub(rg)
		Duel.Search(g:GetFirst())
	end
end

--E4
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_MACHINE)
end