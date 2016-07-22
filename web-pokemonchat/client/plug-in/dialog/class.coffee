class dialog
  alert: (msg, callback)->
    this.open(Template.plugInDialogConfirm, {text: msg, btns: ['确定'], length: 1, callback: callback})
    
  confirm: (msg, btns, callback)->
    this.open(Template.plugInDialogConfirm, {text: msg, btns: btns, length: btns.length, callback: callback})
    
  toast: (msg)->
    id = (new Mongo.ObjectID)._str
    $wrap = $('#wrap')
    if($wrap.find('#dialog-toast').length <= 0)
      $wrap.append('<ul id="dialog-toast"></ul>')
    $toast_ul = $wrap.find('#dialog-toast')
    $toast_ul.append('<li id="' + id + '" style="display:none;">' + msg + '</li>')
    $toast = $('#' + id)
    $toast.fadeIn()
    Meteor.setTimeout(
      ()->
        $toast.fadeOut ()->
          $toast.remove()
      3000
    )

  toast2: (msg)->
    id = (new Mongo.ObjectID)._str
    $wrap = $('#wrap')
    if($wrap.find('#dialog-toast').length <= 0)
      $wrap.append('<ul id="dialog-toast"></ul>')
    $toast_ul = $wrap.find('#dialog-toast')
    $toast_ul.append('<li id="' + id + '" style="display:none; background-color:#5cb85c; text-align: center; opacity: 0.95;">' + msg + '</li>')
    $toast = $('#' + id)
    $toast.fadeIn()
    Meteor.setTimeout(
      ()->
        $toast.fadeOut ()->
          $toast.remove()
      3000
    )

  longtoast: (msg)->
    id = (new Mongo.ObjectID)._str
    $wrap = $('#wrap')
    if($wrap.find('#dialog-toast').length <= 0)
      $wrap.append('<ul id="dialog-toast"></ul>')
    $toast_ul = $wrap.find('#dialog-toast')
    $toast_ul.append('<li id="' + id + '" style="display:none; background-color:#5cb85c; text-align: center; opacity: 0.95;">' + msg + '</li>')
    $toast = $('#' + id)
    $toast.fadeIn()
    Meteor.setTimeout(
      ()->
        $toast.fadeOut ()->
          $toast.remove()
      3000#10000*60
    )
    
  open: (view, data)->
    id = (new Mongo.ObjectID)._str 
    $wrap = $('#wrap')
    $wrap.append('<div id="' + id + '"></div>')
    $dialog = $('#' + id)
    data = data || {}
    data.dialog_id = id
    
    Blaze.renderWithData(Template.plugInDialog, {id: id}, document.getElementById(id))
    Blaze.renderWithData(view, data, document.getElementById(id + '_view'))
    $dialog.find('.plug-in-dialog').css('margin-top', '-' + ($dialog.find('.plug-in-dialog').height()/2+10) + 'px')
    $dialog.find('.plug-in-dialog').css('margin-left', '-' + ($dialog.find('.plug-in-dialog').width()/2) + 'px')
    
    return id
    
  close: (id)->
    $dialog = $('#' + id)
    $dialog.remove()

@Dialog = new dialog()