layout = null
views = []

Template.popup.helpers
  show: (val)->
    if(val isnt undefined and val isnt '' and val isnt null)
      exist = false
      for item in views
        if(item is val)
          exist = true
          break
      if(!exist)
        views.push(val)
      
    if(layout is null)
      while(views.length > 0)
        view = views.shift()
        if(localStorage.getItem("poppup_#{view}_show") is null)
          localStorage.setItem("poppup_#{view}_show", 'true')
          layout = Blaze.renderWithData(Template.popup, {view: view}, document.body)
          return
  close: ()->
    if(layout isnt null)
      Blaze.remove(layout)
      layout = null
      
    Template.popup.__helpers.get('show')()
    
Template.popup.events
  'click .event':->
    Template.popup.__helpers.get('close')()