Template.wifiSortBy.helpers
  checked: (i)->
    if Session.get('wifiSortByWay') is i
      return true
    else
      return false
Template.wifiSortBy.events
  'click .leftButton': ()->
    Session.set('view', 'pub_board')
  'click #sortByList li': (e)->
    Session.set('wifiSortByWay', e.currentTarget.id)
