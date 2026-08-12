local _SynchroCond, _SynchroTarget, _SynchroOperation = Synchro.Condition, Synchro.Target, Synchro.Operation

function Synchro.TunerSubFilterGlitchy(sync,tp,f1)
	return	function(c)
				if f1 and not f1(c,sync,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) then return false end
				local eset={c:IsHasEffect(EFFECT_CAN_BE_TUNER_GLITCHY)}
				for _,e in ipairs(eset) do
					if e:Evaluate(c,sync,tp) then
						return true
					end
				end
				return false
			end
end

function Synchro.Condition(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
	return	function(e,c,smat,mg,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local dg
				local lv=c:GetLevel()
				local g
				local mgchk
				if sub1 then
					sub1=aux.OR(sub1,Synchro.TunerSubFilterGlitchy(c,tp,f1))
				else
					sub1=Synchro.TunerSubFilterGlitchy(c,tp,f1)
				end
				return _SynchroCond(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)(e,c,smat,mg,min,max)
			end
end
function Synchro.Target(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
				local sg=Group.CreateGroup()
				local lv=c:GetLevel()
				local mgchk
				local g
				local dg
				if sub1 then
					sub1=aux.OR(sub1,Synchro.TunerSubFilterGlitchy(c,tp,f1))
				else
					sub1=Synchro.TunerSubFilterGlitchy(c,tp,f1)
				end
				return _SynchroTarget(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
			end
end

--Enable turn count limit for EFFECT_SYNCHRO_MATERIAL_CUSTOM. These effs can now return a third object (a bool) that specified which custom material path(s) expire the count limit
function Synchro.Operation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	for tc in g:Iter() do
		local effs_with_ctlim,descs={},{}
		for _,te in ipairs({tc:GetCardEffect(EFFECT_SYNCHRO_MATERIAL_CUSTOM)}) do
			if te:IsHasProperty(EFFECT_FLAG_COUNT_LIMIT) then
				local op=te:GetOperation()
				local ok,tlvchk,must_use_ctlim=op(te,Group.CreateGroup(),Group.CreateGroup(),g,c:GetLevel(),c,tp)
				if ok and must_use_ctlim then
					table.insert(effs_with_ctlim,te)
					table.insert(descs,te:GetDescription())
				end
			end
		end
		if #effs_with_ctlim>0 then
			Duel.Hint(HINT_CARD,tp,tc:GetOriginalCode())
			local selected=#effs_with_ctlim>1 and Duel.SelectOption(tp,table.unpack(descs))+1 or 1
			local te=effs_with_ctlim[selected]
			if te then
				te:UseCountLimit(tp)
			end
		end
	end
	_SynchroOperation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
end