# Space 4
if Meteor.isClient
#    Session.setDefault "city", "昆明市"
    
    Template.city_province.helpers
        province: ->
            province
    Template.city_province.events
        "click .button_left":->
            Session.set('view', Session.get('city-return-view'))
        "click li":(event)->
            if event.currentTarget.getAttribute('name') == "附近"
                Session.set "city", "附近"
                PUB.back()
            else
                Session.set 'cityProID',event.currentTarget.getAttribute('ProID')
                Session.set 'cityProName',event.currentTarget.getAttribute('name')
                Session.set 'view','city_city'
    Template.city_city.helpers
        city: ->
            proId = Number(Session.get 'cityProID')
            ctarr = []
            citys.forEach (c)->
                if Number(c.ProID) is proId
                    ctarr.push c
            ctarr
    Template.city_city.events
        "click .button_left":->
            Session.set "view", "city_province"
        "click li":(event)->
            city = event.currentTarget.getAttribute('name')
            Session.set "city", city
            Session.set('view', Session.get('city-return-view'))