if Meteor.isClient

  mySwiper = null
  my_images_view = null

  Template.images_view.rendered=->
    templateData = this.data
    $('#wrap2 .swiper-container').css 'height',($(window).height())+'px'
    $('#wrap2 .swiper-container').css 'width',$(window).width()+'px'
    #$('#wrap2 .swiper-slide').css 'display','table'
    $('#wrap2 .swiper-slide').css 'background-color','black'
    #$('#wrap2 .swiper-slide a').css 'display','table-cell'
    $('#wrap2 .swiper-slide a').css 'vertical-align','middle'
    $('#wrap2 .swiper-slide a').css 'background','black'
    #$('#wrap2 .swiper-slide a img').css 'width',$(window).width()+'px'
    $('#wrap2 .swiper-slide a img').css 'border','1px solid black'
    selected = Session.get("images_view_images_selected")
    images = Session.get "images_view_images"
    initialIndex = 0
    if (selected && selected isnt "")
      for i in [0..images.length-1]
        if images[i] is selected
          initialIndex = i

    mySwiper = new Swiper '.images_view .swiper-container',
      initialSlide: initialIndex
      loop:false
      #grabCursor: true
      createPagination: false
      watchActiveIndex: true
      lazyLoading: true
      lazyLoadingInPrevNext: true
      lazyLoadingOnTransitionStart: false
      onSlideChangeStart:(sw)->
        #console.log("onSlideChangeStart, sw.activeIndex="+sw.activeIndex)
        if templateData and typeof templateData.callback is "function"
          #console.log("templateData is function")
          templateData.callback(sw.activeIndex)
        else
          console.log("templateData is NOT function, templateData="+JSON.stringify(templateData))
        if templateData and templateData.imageCount
          $("#images_view_text").html((sw.activeIndex + 1) + "/" + templateData.imageCount)
        else
          $("#images_view_text").html((sw.activeIndex + 1) + "/" + Session.get("images_view_images").length)
      onSlideChangeEnd:(sw)->
        return
        console.log("onSlideChangeEnd, sw.activeIndex="+sw.activeIndex)
        if templateData and typeof templateData.callback is "function"
          #console.log("templateData is function")
          templateData.callback(sw.activeIndex)
        else
          console.log("templateData is NOT function")
        if templateData and templateData.imageCount
          $("#images_view_text").html((sw.activeIndex + 1) + "/" + templateData.imageCount)
        else
          $("#images_view_text").html((sw.activeIndex + 1) + "/" + Session.get("images_view_images").length)
    if templateData and templateData.imageCount
      $("#images_view_text").html((initialIndex + 1) + "/" + templateData.imageCount)
    else
      $("#images_view_text").html((initialIndex + 1) + "/" + Session.get("images_view_images").length)
  Template.images_view.helpers
    images:->
      images = Session.get "images_view_images"
      Meteor.setTimeout (->
        if mySwiper? and mySwiper.update?
          mySwiper.update()
          $('#wrap2 .swiper-slide a img').css 'border','1px solid black'
          if images.length > 0
            if images[images.length-1] is 'fullscreenloading.png'
              if $('#wrap2 .swiper-slide').last().find('.swiper-lazy-preloader') is null
                $('#wrap2 .swiper-slide').last().append("<div class='last-swiper-element swiper-lazy-preloader'></div>")
            else
              $('.last-swiper-element').remove()
          console.log("mySwiper.update")
        ), 350
      console.log("images.length = "+images.length)
      images
    show: (data)->
      if my_images_view is null
        Session.set('imageview_scrollTop', document.body.scrollTop)
        $('body').append("<div id='wrap2' style='z-index: 99999; min-height: 100%; height: auto; position: absolute; top: 0; left:0;'>")
        $('#wrap').css('display', 'none')
        #$('#wrap').css('visibility', 'hidden')
        if data
          my_images_view = Blaze.renderWithData Template.images_view, data, document.getElementById('wrap2')
        else
          my_images_view = Blaze.render Template.images_view, document.getElementById('wrap2')

    close: ()->
      if my_images_view isnt null
        Blaze.remove my_images_view
        $('#wrap').css('display', '')
        #$('#wrap').css('visibility', '')
        $('#wrap2').remove()
        my_images_view = null
        mySwiper = null
        document.body.scrollTop = Session.get('imageview_scrollTop')
    isShow: () ->
      if my_images_view isnt null
        return true
      else
        return false
  Template.images_view.events
    "click .swiper-slide":->
      if my_images_view isnt null
        Template.images_view.__helpers.get('close')();
      else
        PUB.back()
      
  Template.photo_swipe.rendered=->
    window.openPhotoSwipe = (items)->
      w = $(window).width()/2
      h = $(window).height()/2
      pswpElement = document.querySelectorAll('.pswp')[0];
      options = 
        index: 0 
        history:false
        closeOnScroll:true
        focus: false
        loop:true
        showAnimationDuration: 0
        hideAnimationDuration: 0
      gallery = new PhotoSwipe( pswpElement, PhotoSwipeUI_Default, items, options)
      gallery.init()
      return
    return