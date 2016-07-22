#   编辑个人资料
    Session.setDefault('edit_nike_edit', false)
    Template.my_nike.rendered=->
        $('.set-up').css('min-height', $('body').height()-48-55)
        Session.set('edit_nike_edit', false)
    Template.my_nike.helpers
        nike: ()->
            return Meteor.user().profile.nike
        edit: ()->
            return Session.equals('edit_nike_edit', true)
    Template.my_nike.events 
        'keydown #my_edit_nike': (event, tpl) ->
            if event.keyCode is 8
                return true
            target = event.target
            count = target.value.replace(/[^\x00-\xff]/g,"**").length
            count < 16
        'change #my_edit_nike, keydown #my_edit_nike, blur #my_edit_nike': (event, tpl) ->
            target = event.target
            value = target.value
            count = value.replace(/[^\x00-\xff]/g,"**").length
            while count > 16
                value = value.substring(0, value.length-1)
                count = value.replace(/[^\x00-\xff]/g,"**").length
            target.value = value
        'click #btn_back': ()->
            PUB.back()
        'click #edit': ()->
            Session.set('edit_nike_edit', true)
        'click #save': ()->
            nike = $('#my_edit_nike').val()
            if nike is "" then window.plugins.toast.showLongBottom '昵称不能为空！'
            else if nike.length>16 then window.plugins.toast.showLongBottom '昵称不能超过16个字符!'
            else
                if nike isnt Meteor.user().profile.nike
                    timeout = setTimeout(`function(){PUB.toast('当前网络状况不佳，保存失败！');}`, 5000) 
                    Meteor.call 'isUserNikeUsed',nike,(error,result)->
                        if result
                            Meteor.clearTimeout(timeout)
                            PUB.toast '昵称已被使用!'
                        else
                            Meteor.users.update(
                                {_id: Meteor.userId()}
                                {$set:{'profile.nike':nike}}
                                (err)->
                                    Meteor.clearTimeout(timeout)
                                    if(err)
                                        PUB.toast('保存失败，请重试!')
                                    else
                                        PUB.toast('保存成功!')
                                        Session.set('edit_nike_edit', false)
                            )
                else
                    PUB.toast('保存成功!')
                    Session.set('edit_nike_edit', false)
        'click #cancel': ()->
            Session.set('edit_nike_edit', false)
    Session.setDefault('edit_signature_edit', false)
    Template.my_signature.rendered=->
        $('.set-up').css('min-height', $('body').height()-48-55)
        Session.set('edit_signature_edit', false)
    Template.my_signature.helpers
        signature: ()->
            Meteor.user().profile.signature
        edit: ()->
            Session.equals('edit_signature_edit', true)
    Template.my_signature.events 
        'click #btn_back': ()->
            PUB.back()
        'click #edit': ()->
            Session.set('edit_signature_edit', true)
        'click #save': ()->
            signature = $('#my_edit_signature').val()
            if signature is "" then window.plugins.toast.showLongBottom '签名不能为空！'
            else
                timeout = setTimeout(`function(){PUB.toast('当前网络状况不佳，保存失败！');}`, 5000) 
                Meteor.users.update(
                    {_id: Meteor.userId()}
                    {$set:{'profile.signature':signature}}
                    (err)->
                        Meteor.clearTimeout(timeout)
                        if(err)
                            PUB.toast('保存失败，请重试！')
                        else
                            PUB.toast('保存成功!')
                            Session.set('edit_signature_edit', false)
                            Session.set('updateSignature', Session.get('updateSignature')+1)
                )
        'click #cancel': ()->
            Session.set('edit_signature_edit', false)
    Template.my_sex.rendered=->
        $('.set-up').css('min-height', $('body').height()-48-55)
    Template.my_sex.sex = ->
        Meteor.user().profile.sex is '女'
    Template.my_sex.events 
        'click #btn_back':->
            PUB.back()
        'click #my_edit_sex li':(e)->
            sex = e.currentTarget.id
            Meteor.users.update Meteor.userId(),{$set:{'profile.sex':sex}}
            PUB.page 'my_info'
    Template.my_birthday.rendered=->
        $('.set-up').css('min-height', $('body').height()-48-55)
    Template.my_birthday.helpers
        birthday: ()->
            Meteor.user().profile.birthday
        isAndroid: ()->
            Meteor.isCordova and device.platform is 'Android'
    Template.my_birthday.events 
        'focus #my_edit_birthday': (e)->
            if(Template.my_birthday.__helpers.get('isAndroid')())
                $('#my_edit_birthday').blur()
                birthday = new Date()
                if($('#my_edit_birthday').val() != '')
                    birthday = new Date($('#my_edit_birthday').val())
                datePicker.show {date: birthday, mode: 'date'}, (date)->
                    if(isNaN(date.getFullYear()))
                        return
                    if(date != undefined)
                        $('#my_edit_birthday').val(date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate())
        'click #btn_back':->
            birthday = $('#my_edit_birthday').val()
            one = birthday.replace(/-/g,'/')
            if Date.parse(one) > Date.parse(new Date())
                 PUB.toast '请正确填写生日！'
            else
                Meteor.users.update Meteor.userId(),{$set:{'profile.birthday':birthday}}
                PUB.back()
            return
    Template.my_province.helpers 
        province:->
            province
    Template.my_province.events 
        'click #btn_back':->
            PUB.back()
        'click ul li':(e)->
            Session.set 'ProID',e.currentTarget.getAttribute('ProID')
            PUB.page 'my_city'
    Template.my_city.helpers 
        city:->
            proId = Number(Session.get 'ProID')
            ctarr = []
            citys.forEach (c)->
                if Number(c.ProID) is proId
                    ctarr.push c
            ctarr
    Template.my_city.events 
        'click #btn_back':->
            PUB.back()
        'click ul li':(e)->
            city = e.currentTarget.getAttribute('name')
            Meteor.users.update Meteor.userId(),{$set:{'profile.city':city}}
            PUB.page 'my_info'
#   商家
    Session.setDefault('edit_business_edit', false)
    Template.edit_business.rendered=->
        $('.set-up').css('min-height', $('body').height()-48-55)
        if(Meteor.user().profile.business is undefined or Meteor.user().profile.business is '')
            Session.set('edit_business_edit', true)
        else
            Session.set('edit_business_edit', false)
    Template.edit_business.helpers
      business: ()->
          Meteor.user().profile.business
      eidt: ()->
          Session.get('edit_business_edit')
    Template.edit_business.events 
        'click #btn_back':->
            PUB.back()
        'click #cancel':->
            Session.set('edit_business_edit', false)
        'click #save':->
            business = $('#my_edit_business').val()
            if(business is '')
                PUB.toast('商家名称不能为空！')
            else
                timeout = setTimeout(()->
                    PUB.toast('当前网络状况不佳，保存失败！')
                ,5000) 
                Meteor.users.update(
                    {_id: Meteor.userId()}
                    {$set:{'profile.business':business}}
                    (err, number)->
                        PUB.toast('保存成功！')
                        Session.set('edit_business_edit', false)
                        clearTimeout timeout
                )        
        'click #edit':->
            Session.set('edit_business_edit', true)
    Template.edit_identity.identity = ->
        Meteor.user().profile.identity
    Template.edit_identity.events 
        'click #btn_back':->
            identity = $('#my_edit_identity').val()
            Meteor.users.update Meteor.userId(),{$set:{'profile.identity':identity}}
            PUB.back()
            return
    Session.setDefault('edit_tel_edit', false)
    Template.edit_tel.rendered=->
        $('.set-up').css('min-height', $('body').height()-48-55)
        if(Meteor.user().profile.tel is undefined or Meteor.user().profile.tel is '')
            Session.set('edit_tel_edit', true)
        else
            Session.set('edit_tel_edit', false)
    Template.edit_tel.helpers
        tel: ()->
            Meteor.user().profile.tel
        eidt: ()->
            Session.get('edit_tel_edit')
    Template.edit_tel.events 
        'click #btn_back':->
            PUB.back()
        'click #cancel':->
            Session.set('edit_tel_edit', false)
        'click #save':->
            tel = $('#my_edit_tel').val()
            if(tel is '')
                PUB.toast('电话不能为空！')
            else
                timeout = setTimeout(()->
                    PUB.toast('当前网络状况不佳，保存失败！')
                ,5000)
                Meteor.users.update(
                    {_id: Meteor.userId()}
                    {$set:{'profile.tel':tel}}
                    (err, number)->
                        PUB.toast('保存成功！') 
                        Session.set('edit_tel_edit', false)
                        clearTimeout timeout
                )
        'click #edit':->
            Session.set('edit_tel_edit', true)
    Session.setDefault('edit_address_edit', false)
    Template.edit_address.rendered=->
        $('.set-up').css('min-height', $('body').height()-48-55)
        if(Meteor.user().profile.address is undefined or Meteor.user().profile.address is '')
            Session.set('edit_address_edit', true)
        else
            Session.set('edit_address_edit', false)
    Template.edit_address.helpers
        address: ()->
            Meteor.user().profile.address
        eidt: ()->
            Session.get('edit_address_edit')
    Template.edit_address.events 
        'click #btn_back':->
            PUB.back()
        'click #cancel':->
            Session.set('edit_address_edit', false)
        'click #save':->
            address = $('#my_edit_address').val()
            if(address is '')
                PUB.toast('商家地址不能为空！')
            else
                timeout = setTimeout(()->
                    PUB.toast('当前网络状况不佳，保存失败！')
                ,5000)
                Meteor.users.update(
                    {_id: Meteor.userId()}
                    {$set:{'profile.address':address}}
                    (err, number)->
                        PUB.toast('保存成功！') 
                        Session.set('edit_address_edit', false)
                        clearTimeout timeout
                )
        'click #edit':->
            Session.set('edit_address_edit', true)
    Session.setDefault('edit_text_edit', false)
    Template.edit_text.rendered=->
        $('.set-up').css('min-height', $('body').height()-48-55)
        if(Meteor.user().profile.text is undefined or Meteor.user().profile.text is '')
            Session.set('edit_text_edit', true)
        else
            Session.set('edit_text_edit', false)
    Template.edit_text.helpers
        text: ()->
            Meteor.user().profile.text
        eidt: ()->
            Session.get('edit_text_edit')
    Template.edit_text.events 
        'click #btn_back':->
            PUB.back()
        'click #cancel':->
            Session.set('edit_text_edit', false)
        'click #save':->
            text = $('#my_edit_text').val()
            if(text is '')
                PUB.toast('商家简介不能为空！')
            else
                timeout = setTimeout(()->
                    PUB.toast('当前网络状况不佳，保存失败！')
                ,5000)
                Meteor.users.update(
                    {_id: Meteor.userId()}
                    {$set:{'profile.text':text}}
                    (err, number)->
                        PUB.toast('保存成功！') 
                        Session.set('edit_text_edit', false)
                        clearTimeout timeout
                )
        'click #edit':->
            Session.set('edit_text_edit', true)