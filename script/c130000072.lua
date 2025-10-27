--[[
Hieratic Seal of Divine Dominion
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	local e0=aux.AddEquipProcedure(c,nil,xgl.MonsterFilter(TYPE_XYZ,Card.IsSetCard,SET_HIERATIC))
	e0:HOPT(true)
	--You can only control 1 "Hieratic Seal of Divine Dominion". 
	c:SetUniqueOnField(1,0,id)
	--Once per turn, when your opponent activates a monster effect in the hand (Quick Effect): You can detach 1 material from this card; negate the activation, and if you do, destroy it.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:OPT()
	e1:SetFunctions(
		s.negcon,
		Cost.DetachFromSelf(1,1,nil),
		s.negtg,
		s.negop
	)
	xgl.RegisterEquipGrantEffect(c,e1)
end
s.listed_names={id}

--E1
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp
		and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()&LOCATION_HAND>0 and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end