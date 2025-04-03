--Modifications to the function that attaches materials to Xyz Monsters
local _Overlay = Duel.Overlay

Duel.Overlay=function(xyz,mat,...)
	-- local og,oct
	-- if xyz:IsLocation(LOCATION_MZONE) then
		-- og=xyz:GetOverlayGroup()
		-- oct=#og
	-- end
	_Overlay(xyz,mat,...)
	-- if oct and xyz:GetOverlayCount()>oct then
		-- Duel.RaiseEvent(mat,EVENT_XYZATTACH,nil,0,0,xyz:GetControler(),xyz:GetOverlayCount()-oct)
	-- end
	
	local mg=Group.CreateGroup()
	if type(mat)=="Card" then
		mg:AddCard(mat)
	else
		mg:Merge(mat)
	end
	for mc in aux.Next(mg) do
		if not mc:IsHasEffect(EFFECT_REMEMBER_XYZ_HOLDER) then
			local e1=Effect.CreateEffect(mc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_REMEMBER_XYZ_HOLDER)
			e1:SetLabelObject(xyz)
			mc:RegisterEffect(e1)
		else
			local e1=mc:GetCardEffect(EFFECT_REMEMBER_XYZ_HOLDER)
			e1:SetLabelObject(xyz)
		end
	end
end

--Returns the most recent Xyz Monster that had (c) attached to it as material. If (c) is currently attached to an Xyz Monster, then the latter is returned (not the previous Xyz Monster).
--If (c) never was attached to an Xyz Monster during the Duel, nil is returned instead
function Card.GetPreviousXyzHolder(c)
	local e=c:IsHasEffect(EFFECT_REMEMBER_XYZ_HOLDER)
	if e then
		local xyzc=e:GetLabelObject()
		return xyzc
	end
	return
end