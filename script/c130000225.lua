--[[
Mostro Ricostruito
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Reveal 1 monster in your hand, then target 1 monster in your GY with the same Type and Attribute, but a different ATK and DEF; banish both monsters face-down, and if you do, add 1 monster from your Deck to your hand with the same Type and Attribute, but a different ATK and DEF from those cards. You can only activate 1 "Monster Remade" per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCost(xgl.DummyCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.rvfilter(c,tp)
	return c:IsMonster() and not c:IsPublic() and c:IsAbleToRemoveFacedown()
		and Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,c,c,tp,c:GetRace(),c:GetAttribute(),c:GetAttack(),c:GetDefense())
end
function s.rmfilter(c,c1,tp,rc,attr,atk,def)
	return c:IsMonster() and c:IsAbleToRemoveFacedown() and c:IsAttributeRace(attr,rc) and not c:IsAttack(atk) and c:HasDefense() and not c:IsDefense(def) and aux.SpElimFilter(c,true)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,Group.FromCards(c,c1),c:GetRace()|rc,c:GetAttribute()|attr,{atk,c:GetAttack()},{def,c:GetDefense()})
end
function s.thfilter(c,races,attributes,atks,defs)
	return c:IsMonster() and c:IsAbleToHand() and c:IsAttributeRace(attributes,races) and not c:IsAttack(table.unpack(atks)) and not c:IsDefense(table.unpack(defs))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local rc=Duel.Group(Card.HasFlagEffectLabel,tp,LOCATION_HAND,0,chkc,id,e:GetFieldID()):GetFirst()
		local race,attr,atk,def=rc:GetRace(),rc:GetAttribute(),rc:GetAttack(),rc:GetDefense()
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rmfilter(chkc,rc,race,attr,atk,def)
	end
	if chk==0 then
		return e:IsCostChecked() and Duel.IsExistingMatchingCard(s.rvfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	local eid=e:GetFieldID()
	local rc=Duel.Select(HINTMSG_REVEAL,false,tp,s.rvfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1,eid)
	local tc=Duel.Select(HINTMSG_REMOVE,true,tp,s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,rc,rc,tp,rc:GetRace(),rc:GetAttribute(),rc:GetAttack(),rc:GetDefense()):GetFirst()
	local g=Group.FromCards(rc,tc)
	Duel.SetTargetParam(eid)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.rmchk(c)
	return c:IsLocation(LOCATION_REMOVED) and c:IsFacedown()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=Duel.Group(Card.HasFlagEffectLabel,tp,LOCATION_HAND,0,chkc,id,Duel.GetTargetParam()):GetFirst() 
	local tc=Duel.GetFirstTarget()
	if not rc or not tc:IsRelateToChain() then return end
	local rg=Group.FromCards(rc,tc)
	if Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)==2 and rg:FilterCount(s.rmchk,nil)==2 then
		local races=rc:GetRace()|tc:GetRace()
		local attributes=rc:GetAttribute()|tc:GetAttribute()
		local atks={rc:GetAttack(),tc:GetAttack()}
		local defs={rc:GetDefense(),tc:GetDefense()}
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,races,attributes,atks,defs)
		if #sg>0 then
			Duel.Search(sg)
		end
	end
end