Meteor.startup ->
  $.fn.forceLazyLoad = ()->
    this.find("img.lazy").lazyload({effect: "fadeIn", effectspeed: 600, threshold: 800})
  Template.onRendered ->
    this.$("img.lazy").lazyload({effect: "fadeIn", effectspeed: 600, threshold: 800})
    
#    if this.view.name is "Template.#{Session.get('view')}"
#      Template.public_loading_index.__helpers.get('close')()