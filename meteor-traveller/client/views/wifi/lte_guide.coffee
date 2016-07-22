Template.lteGuide.onRendered ()->
  $('#wrap').hide()
  $('#footer').hide()
Template.lteGuide.helpers
Template.lteGuide.events
  'click .tips': (e, t)->
    t.$('.hint-text').show()
    t.$('.hint-text-mask').show()
  'click .hint-text': (e, t)->
    t.$('.hint-text').hide()
    t.$('.hint-text-mask').hide()
  'click .hint-text-mask': (e, t)->
    t.$('.hint-text').hide()
    t.$('.hint-text-mask').hide()
  'click .btn-yes': (e, t)->
    count = parseInt(window.localStorage.getItem("LTE_hint_flag"))+1
    window.localStorage.setItem("LTE_hint_flag",count)
    $('#wrap').show()
    $('#footer').show()
    Session.set("public_upload_index_images", [])
    Session.set('view', 'wifiIndex')
    $('#lte_guide_box').remove()