Template.chatMessageDashboard.helpers
	own: ->
		return 'own' if this.data.u?._id is Meteor.userId()

	username: ->
		return this.u.username

	messageDate: (date) ->
		return moment(date).format('LL')

	isSystemMessage: ->
		return this.t in ['s', 'p', 'f', 'r', 'au', 'ru', 'ul', 'nu', 'wm', 'uj']

	isEditing: ->
		return this._id is Session.get('editingMessageId')

	renderMessage: ->
		this.html = this.msg
		if _.trim(this.html) isnt ''
			this.html = _.escapeHTML this.html
		message = RocketChat.callbacks.run 'renderMessage', this
		this.html = message.html.replace /\n/gm, '<br/>'
		return this.html

	message: ->
		switch this.t
			when 'r' then t('Room_name_changed', { room_name: this.msg, user_by: Session.get('user_' + this.u._id + '_name') }) + '.'
			when 'au' then t('User_added_by', { user_added: this.msg, user_by: Session.get('user_' + this.u._id + '_name') })
			when 'ru' then t('User_removed_by', { user_removed: this.msg, user_by: Session.get('user_' + this.u._id + '_name') })
			when 'ul' then t('User_left', this.msg)
			when 'nu' then t('User_added', this.msg)
			when 'wm' then t('Welcome', this.msg)
			when 'uj' then t('User_joined_channel', { user: this.msg })
			else this.msg

	time: ->
		return moment(this.ts).format('HH:mm')

	getPupupConfig: ->
		template = Template.instance()
		return {
			getInput: ->
				return template.find('.input-message-editing')
		}

Template.chatMessageDashboard.events
	'mousedown .edit-message': ->
		self = this
		Session.set 'editingMessageId', undefined
		Meteor.defer ->
			Session.set 'editingMessageId', self._id

			Meteor.defer ->
				$('.input-message-editing').select()

	'click .mention-link': (e) ->
		Session.set('flexOpened', true)
		Session.set('showUserInfo', $(e.currentTarget).data('username'))

Template.chatMessageDashboard.onRendered ->
	if(this.lastNode.className.match("own"))
		ScrollListener.toBottom(true)
		return

	message = $(this.lastNode)
	parent = message.parent().children().last()

	if message.get(0) is parent.get(0)
		ScrollListener.toBottom(false)