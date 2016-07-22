if Meteor.isClient

  my_images_view = null

  Template.imagesView.rendered=->
    $('#wrap2 .swiper-container').css 'height',($(window).height())+'px'
    $('#wrap2 .swiper-container').css 'width',$(window).width()+'px'
    $('#wrap2 .swiper-slide').css 'display','table'
    $('#wrap2 .swiper-slide a').css 'display','table-cell'
    $('#wrap2 .swiper-slide a').css 'vertical-align','middle'
    selected = Session.get("images_view_images_selected")
    images = Session.get "images_view_images"
    initialIndex = 0
    if (selected && selected isnt "")
      for i in [0..images.length-1]
        if images[i] is selected
          initialIndex = i
    swiper = new Swiper '.swiper-container',
      initialSlide: initialIndex
      loop:false
      grabCursor: true
      createPagination: false
      watchActiveIndex: true
      onSlideChangeEnd:(sw)->
        $("#images_view_text").html((sw.activeIndex + 1) + "/" + Session.get("images_view_images").length)
    $("#images_view_text").html((initialIndex + 1) + "/" + Session.get("images_view_images").length)
  Template.imagesView.helpers
    images:->
      images = Session.get "images_view_images"
    show: (value)->
      if my_images_view is null
        Session.set('imageview_scrollTop', document.body.scrollTop)
        $('body').append("<div id='wrap2' style='z-index: 99999; background-color: #000; min-height: 100%; height: auto; position: fixed; top: 0; left:0;'>")
        my_images_view = Blaze.render Template.imagesView, document.getElementById('wrap2')
    close: ()->
      if my_images_view isnt null
        #Blaze.remove my_images_view
        $('#wrap2').remove()
        my_images_view = null
        document.body.scrollTop = Session.get('imageview_scrollTop')
  Template.imagesView.events
    "click .swiper-slide":->
        Template.imagesView.__helpers.get('close')();
