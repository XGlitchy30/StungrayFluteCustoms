--[[
Percussion Beetle Triplet Performance
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[Special Summon 1 "Percussion Beetle" monster from your GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetSpecialSummonFunctions(nil,false,xgl.ArchetypeFilter(SET_PERCUSSION_BEETLE),LOCATION_GRAVE,0,1,1,nil)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY; apply 1 of the following effects.
	● Increase the Levels of all "Percussion Beetle" monsters you control by 1 until the End Phase.
	● Detach 1 material from an Xyz Monster on the field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:SetFunctions(nil,aux.bfgcost,s.eftg,s.efop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PERCUSSION_BEETLE}

function s.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_PERCUSSION_BEETLE) and c:HasLevel()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lvg=Duel.Group(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #lvg>0 or Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LVCHANGE,lvg,#lvg,0,1)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local lvg=Duel.Group(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	local b1=#lvg>0
	local b2=Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT)
	if not b1 and not b2 then return end
	local opt=xgl.Option(tp,id,2,b1,b2)
	if opt==0 then
		local c=e:GetHandler()
		for tc in aux.Next(lvg) do
			xgl.UpdateLevel(tc,1,RESET_PHASE|PHASE_END,{c,true})
		end
	elseif opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
		local sg=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,1,REASON_EFFECT)
		if #sg==0 then return end
		Duel.HintSelection(sg)
		sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end
