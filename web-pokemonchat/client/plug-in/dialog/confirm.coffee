Template.plugInDialogConfirm.events
  'click .my-btn': (e, t)->
    t.$('.my-btn').each (i)->
      if($(this).html() is $(e.currentTarget).html())
        if(t.data.callback)
          t.data.callback(i)
        Dialog.close(t.data.dialog_id)