local _IsExtraLinked = Card.IsExtraLinked

Card.IsExtraLinked = function(c)
	return _IsExtraLinked(c) or c:IsHasEffect(EFFECT_BECOME_EXTRA_LINKED)
end