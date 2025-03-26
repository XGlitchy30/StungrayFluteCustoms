--[[
Miraculous Discovery!
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[When an opponent's monster declares an attack while your LP are 2000 or less: You can target that monster; its ATK becomes 0 until the end of this turn]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[During your next turn after this card was activated: You can banish this card from your GY and send 1 card from your hand to the GY; draw 2 cards.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(s.drawcon,s.drawcost,xgl.DrawTarget(0,2),xgl.DrawOperation())
	c:RegisterEffect(e2)
end
--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():GetControler()==1-tp and Duel.GetLP(tp)<=2000
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local a=Duel.GetAttacker()
	if chkc then return false end
	if chk==0 then return a:IsCanBeEffectTarget(e) and a:IsCanChangeATK(0,e,tp,REASON_EFFECT) end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local tct=Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()+2 or Duel.GetTurnCount()+1
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_EXC_GRAVE|RESET_PHASE|PHASE_END|RESET_SELF_TURN,EFFECT_FLAG_OATH|EFFECT_FLAG_CLIENT_HINT,2,tct,aux.Stringid(id,2))
	end
	Duel.SetTargetCard(a)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,a,1,0,0,0,OPINFO_FLAG_SET)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		tc:ChangeATK(0,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
	end
end

--E2
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetTurnPlayer()~=tp or not c:HasFlagEffect(id) then return false end
	for _,tct in ipairs({c:GetFlagEffectLabel(id)}) do
		if tct==Duel.GetTurnCount() then
			return true
		end
	end
	return false
end
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST,nil)
end