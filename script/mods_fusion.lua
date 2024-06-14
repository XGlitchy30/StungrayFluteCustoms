local _SelectMix = Fusion.SelectMix

function Fusion.SelectMix(c,tp,mg,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,...)
	if not aux.FusionSelectMixMod then
		return _SelectMix(c,tp,mg,sg,mustg,fc,sub,sub2,contact,sumtype,chkf,...)
	else
		local res
		local totalcount=#{...}
		local mustgcount=#mustg
		if mustgcount>totalcount then return false end
		if (Fusion.CheckExact and (Fusion.CheckExact~=totalcount or mustgcount>Fusion.CheckExact)) then return false end
		if (Fusion.CheckMax and (Fusion.CheckMax<totalcount or mustgcount>Fusion.CheckMax)) then return false end
		if (Fusion.CheckMin and Fusion.CheckMin>totalcount) then return false end
		-- local rg=Group.CreateGroup()
		local mg2=mg:Clone()
		--c has the fusion limit
		if not contact and c:IsHasEffect(EFFECT_FUSION_MAT_RESTRICTION) then
			local eff={c:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
			for i,f in ipairs(eff) do
				if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
					return false
				end
				local sg2=mg2:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
				-- rg:Merge(sg2)
				mg2:Sub(sg2)
				if mustgcount>0 and not mg2:Includes(mustg) then
					return false
				end
			end
		end
		--A card in the selected group has the fusion lmit
		if not contact then
			local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_FUSION_MAT_RESTRICTION)
			for tc in aux.Next(g2) do
				local eff={tc:GetCardEffect(EFFECT_FUSION_MAT_RESTRICTION)}
				for i,f in ipairs(eff) do
					if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
						return false
					end
				end
			end
		end
		-- mg2:Sub(rg)
		sg:AddCard(c)
		if #sg<totalcount then
			res=mg2:IsExists(Fusion.SelectMix,1,sg,tp,mg2,sg,mustg-sg,fc,sub,sub2,contact,sumtype,chkf,...)
		else
			res=Fusion.CheckMixGoal(tp,sg,fc,sub,sub2,contact,sumtype,chkf,...)
		end
		res = res and (sg:Includes(mustg) or #sg<totalcount)
		sg:RemoveCard(c)
		-- mg2:Merge(rg)
		return res
	end
end