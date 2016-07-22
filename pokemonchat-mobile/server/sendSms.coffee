#@bishen.org 发送短信回调方法
#2014.11.30
#请在本地执行安装 npm install -g fibers
#阿里云服务器上我已经安装过了
Meteor.startup ->
    Future = Npm.require 'fibers/future'
    Meteor.methods 
        'sendSMS':(m,n)->
            future = new Future()
            parm = 
                account:'cf_xundong_km'
                password:'D07EA2047EC93E772CF183BC02E4A7B7'
                mobile:m
                content:'您的验证码是：'+n+'。请不要把验证码泄露给其他人。'
            Meteor.http.post "http://106.ihuyi.cn/webservice/sms.php?method=Submit",
                {params:parm},
                (error, result)->
#                    console.log result
#                    console.log error
                    if error isnt null
                        future["return"]({result:'failed'})
                        console.log '短信请求网络未连接'+ m 
                    else if result.statusCode is 200
                        Sms.insert({mobile:m,text:parm.content,createdAt: new Date()})
                        console.log '短信请求发出 '+m
                        future["return"]({result:'ok',xml:result.content})
                    else
                        future["return"]({result:'failed'})
                        console.log '短信请求失败 '+ m
            future.wait()
            
        'sendShortMessage':(mobile, message)->
          future = new Future()
          parm = 
              account:'cf_xundong_km'
              password:'D07EA2047EC93E772CF183BC02E4A7B7'
              mobile: mobile
              content: message
          Meteor.http.post "http://106.ihuyi.cn/webservice/sms.php?method=Submit",
              {params:parm},
              (error, result)->
#                    console.log result
#                    console.log error
                  if error isnt null
                      future["return"]({result:'failed'})
                      console.log '短信请求网络未连接'+ mobile 
                  else if result.statusCode is 200
                      Sms.insert({mobile:mobile,text:parm.content,createdAt: new Date()})
                      console.log '短信请求发出 '+mobile
                      future["return"]({result:'ok',xml:result.content})
                  else
                      future["return"]({result:'failed'})
                      console.log '短信请求失败 '+ mobile
          future.wait()