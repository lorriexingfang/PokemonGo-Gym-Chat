Template.plugInDialog.events
  'click .plug-in-dialog-mask': (e, t)->
    Dialog.close(t.data.id)