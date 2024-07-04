--[[
Fairy Shark
Card Author: Pretz
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control a Level 5 WATER monster, you can Special Summon this card (from your hand), and if you do, all other Level 5 WATER monsters you control gain 200 ATK]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--[[If this card is detached from an Xyz Monster to activate a WATER monster's effect: You can add it to your hand]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:HOPT()
	e2:SetFunctions(s.thcon,s.thcost,s.thtg,s.thop)
	c:RegisterEffect(e2)
	--Register a flag if a monster is used as Xyz Material
	aux.GlobalCheck(s,function()
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_BE_MATERIAL)
		ge:SetCondition(s.regcon)
		ge:SetOperation(s.regop)
		Duel.RegisterEffect(ge,0)
	end)
end
local FLAG_BROKEN_OATH = id+100

function s.oathfilter(c)
	return c:IsMonster() and not c:IsLevel(5)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_XYZ>0 and eg:IsExists(s.oathfilter,1,nil)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(ep,FLAG_BROKEN_OATH,RESET_PHASE|PHASE_END,0,1)
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(s.cfilter,tp,LOCATION_MZONE,0,c)
	for tc in g:Iter() do
		tc:UpdateATK(200,true,c)
	end
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_DECK|LOCATION_HAND) or c:IsBanished(POS_FACEDOWN) or not c:IsReason(REASON_COST) or not c:IsPreviousLocation(LOCATION_OVERLAY)
		or not re:IsActivated() then
		return false
	end
	local rc=re:GetHandler()
	local ch=Duel.GetCurrentChain()
	local attr=rc:IsRelateToChain(ch) and rc:GetAttribute() or Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_ATTRIBUTE)
	return re:IsActiveType(TYPE_MONSTER) and attr&ATTRIBUTE_WATER==ATTRIBUTE_WATER
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return not Duel.PlayerHasFlagEffect(tp,FLAG_BROKEN_OATH)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e1:SetTarget(function(e,c) return c:IsMonster() and not c:IsLevel(5) end)
	e1:SetValue(s.sumlimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,2))
end
function s.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Search(c)
	end
end