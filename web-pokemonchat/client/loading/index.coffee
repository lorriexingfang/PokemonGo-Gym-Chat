public_loading = null
dep = new Tracker.Dependency
text = ''
$public_loading_index = null

Template.public_loading_index.rendered = ()->
  $public_loading_index = this.$("#public_loading_index")


Template.public_loading_index.helpers
  get_text: ->
    dep.depend()
    text

  is_min: ->
    text is ''

  show: (value)->
    text = if value is undefined then '' else value
    dep.changed()

    if public_loading is null
      public_loading = Blaze.render Template.public_loading_index, document.body
      console.log("show " + value);
  close: ()->
    if public_loading isnt null
      Blaze.remove public_loading
      public_loading = null
      console.log("close ");
