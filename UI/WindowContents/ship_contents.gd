extends Content

var _actor: Actor

func setup(actor: Actor):
	if !actor:
		return
	_actor = actor
	self.text = _actor.description
	return
