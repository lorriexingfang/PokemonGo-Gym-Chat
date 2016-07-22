if Meteor.isClient
  Template.spinner_master.rendered=->
    this.$('.spinner-overlay').parent().find("img.lazy2").lazyload {
      effect : "fadeIn"
      effectspeed: 600
      threshold: 800
      load:->
        $(this).parent().find('.spinner-overlay').remove()
      }
