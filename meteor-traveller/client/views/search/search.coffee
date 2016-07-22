Template.searching.created = ()->
Template.searching.onRendered ()->
  console.log(this.$('#keywords'))
  this.$('#keywords').css('width', $('.seach-index').width() - 60)
Template.searching.helpers
  resultPage:->
    Session.get('resultPage') || 'search_top'
  keywords:->
    Session.get 'search_key'
Template.searching.events
  "click #btn_seach":->
    search_key = $("#keywords").val();
    search_key = $.trim(search_key);
    if search_key isnt ''
      Session.set 'search_key' ,search_key
      showLoading()
      Meteor.call "remoteSearchPosts", search_key, (error, result) ->        
        if error
          PUB.toast('search failed')
          console.log 'remoteSearchPosts failed'
        else
          Session.set 'searchResult', result
          Session.set 'resultPage','findkey'
        closeLoading()
  "click #back_btn":->
    window.page.back()
  "click .search_page_top":(e)->
    Session.set 'search_key' ,e.currentTarget.innerHTML
    showLoading()
    Meteor.call "remoteSearchPosts", e.currentTarget.innerHTML, (error, result) ->      
      if error
        PUB.toast('search failed')
        console.log 'remoteSearchPosts failed'
      else
        Session.set 'searchResult', result
        Session.set 'resultPage','findkey'
      closeLoading()
Template.findkey.helpers
  lists:->
    Session.get 'searchResult'
  isempty:->
    rlt = Session.get("searchResult")
    if rlt
      rlt.length <= 0
    else
      true
