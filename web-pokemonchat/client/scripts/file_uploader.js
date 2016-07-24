if (Meteor.isCordova){
    var uploadToAliyun = function(filename,URI, callback){
      var def = $.Deferred();
      Meteor.call('getAliyunWritePolicy',filename,URI,function(error,result){
        if(error) {
          def.reject(error);
          console.log('getAliyunWritePolicy error: ' + error);
          if(callback){
              callback(null);
          }
        }
        console.log('File URI is ' + result.orignalURI);
        var options = new FileUploadOptions();
        options.mimeType ="image/jpeg";
        options.chunkedMode = false;
        options.httpMethod = "PUT";
        options.fileName = filename;

        var uri = encodeURI(result.acceccURI);

        var headers = {
          "Content-Type": "image/jpeg",
          "Content-Md5":"",
          "Authorization": result.auth,
          "Date": result.date
        };
        options.headers = headers;

        var ft = new FileTransferBCS();
        ft.onprogress = function(progressEvent) {
          if (progressEvent.lengthComputable) {
            console.log('Loaded ' + progressEvent.loaded + ' Total ' + progressEvent.total);
            //computeProgressBar(filename, 60*(progressEvent.loaded/progressEvent.total));
            console.log('Uploaded Progress 1 ' + 60* (progressEvent.loaded / progressEvent.total ) + '%');
          } else {
            console.log('Upload ++');
          }
        };
        ft.upload(result.orignalURI, uri, function(e){
            var filename = result.acceccURI.replace(/^.*[\\\/]/, '');
            var cdnFileName = "http://localhost.com/" + filename;
            console.log("cdnFileName = "+cdnFileName);
            def.resolve({url: cdnFileName});
            if(callback){
                //computeProgressBar(filename, 100);
                console.log("2, cdnFileName = "+cdnFileName);
                callback(cdnFileName);
            }
        }, function(e){
          def.reject(e);
          console.log('upload error' + e.code );
          if(callback){
            callback(null);
          }
        }, options,true);
      });

      return def.promise();
    }

    var uploadToS3 = function(filename,URI,callback){
      Meteor.call('getS3WritePolicy',filename,URI,function(error,result){
        if(error) {
          console.log('getS3WritePolice error: ' + error);
            if(callback){
                callback(null);
            }
        }
        console.log('File URI is ' + result.orignalURI);
        var options = new FileUploadOptions();
        options.fileKey="file";
        var time = new Date().getTime();
        options.fileName = filename;
        options.mimeType ="image/jpeg";
        options.chunkedMode = false;

        var uri = encodeURI("https://travelers-bucket.s3.amazonaws.com/");

        var policyDoc = result.s3PolicyBase64;
        var signature = result.s3Signature ;
        var params = {
          "key": filename,
          "AWSAccessKeyId": 'AWSAccessKeyId',
          "acl": "public-read",
          "policy": policyDoc,
          "signature": signature,
          "Content-Type": "image/jpeg"
        };
        options.params = params;

        var ft = new FileTransfer();
        ft.onprogress = function(progressEvent) {
          if (progressEvent.lengthComputable) {
            console.log('Uploaded Progress 2' + 100* (progressEvent.loaded / progressEvent.total ) + '%');
          } else {
            console.log('Upload ++');
          }
        };
        ft.upload(result.orignalURI, uri, function(e){
            if(callback){
                callback('https://travelers-bucket.s3.amazonaws.com/' + filename);
            }
        }, function(e){
          console.log('upload error' + e.code )
          if(callback){
              callback(null);
          }
        }, options,true);
      });
    }
    var uploadToBCS = function(filename,URI,callback){
      var def = $.Deferred();
      Meteor.call('getBCSSigniture',filename,URI,function(error,result){
        if(error) {
            def.reject(error);
            console.log('getBCSSigniture error: ' + error);
            if(callback){
                callback(null);
            }
            return;
        }
        console.log('File URI is ' + result.orignalURI);
        console.log('Result is ' + JSON.stringify(result));
        var options = new FileUploadOptions();
        var time = new Date().getTime();
        options.mimeType ="image/jpeg";
        options.chunkedMode = false;
        options.httpMethod = "PUT";

        var uri = encodeURI("http://bcs.duapp.com/travelers-km/"+filename)+"?sign="+result.signture;

        var headers = {
          "x-bs-acl": "public-read",
          "Content-Type": "image/jpeg"
        };
        options.headers = headers;

        var ft = new FileTransferBCS();
        ft.onprogress = function(progressEvent) {
          if (progressEvent.lengthComputable) {
            console.log('Uploaded Progress 3' + 100* (progressEvent.loaded / progressEvent.total ) + '%');
          } else {
            console.log('Upload ++');
          }
        };
        ft.upload(result.orignalURI, uri, function(e){
            def.resolve({url: 'http://bcs.duapp.com/travelers-km/' + filename});
            if(callback){
                callback('http://bcs.duapp.com/travelers-km/' + filename);
            }
        }, function(e){
          def.reject(e);
          console.log('upload error' + e.code )
          if(callback){
              callback(null);
          }
        }, options,true);
      });

      return def.promise();
    }
    /**
    * upload file in cordova with plugin for select/resize file to S3
    *
    * @method uploadFileInCordova
    * @param {Function} callback
    * @return {Object} url in callback
    */
    var uploadFileInCordova = function(callback, limit){
      var def = $.Deferred();
      var upimgs = [];

      if(device.platform === 'Android' ){
            pictureSource = navigator.camera.PictureSourceType;
            destinationType = navigator.camera.DestinationType;
//          var cameraOptions = {
//            width: 400,
//            height: 400,
//            destinationType: destinationType.NATIVE_URI,
//            sourceType: pictureSource.SAVEDPHOTOALBUM,
//            quality: 60
//          };
/*
            window.plugins.multiImageSelector.getPictures(function(results) {
                if (!results.paths) {
                    def.resolve([]);
                    return;
                }
                var length = 0;
                try {
                    length = results.paths.length;
                } catch(error) {
                    length = results.paths.length;
                }
                if (length == 0) {def.resolve([]); return;}
                for (var i = 0; i < length; i++) {
                    console.info(results.paths[i]);
                    ImageBase64.base64({
                        uri: results.paths[i],
                        quality: 60,
                        width: 400,
                        height: 400
                    },
                    function(a) {
                        var timestamp = new Date().getTime();
                        var filename = Meteor.userId() + '_' + timestamp + '.jpg';
                        uploadToAliyun(filename,"data:image/jpg;base64,"+a.base64,callback).done(function(value){
                        //uploadToBCS(filename,"data:image/jpg;base64,"+a.base64,callback).done(function(value){
                          upimgs.push(value);

                          if(upimgs.length >= length)
                            def.resolve(upimgs);
                        }).fail(function(err){
                          def.reject(err);
                        });
                    },
                    function(e) {
                        def.reject(e);
                        alert("error" + e)
                    })
                }

            },
            function(error) {
                def.reject(error);
                alert('Error: ' + error);
            },
            {
                type: "multiple",
                limit: limit || 9,
                cancelButtonText: "取消",
                okButtonText: "确定",
                titleText: "选择图片",
                errorMessageText: "选择图片的个数超过了上限！"
            });
*/
          navigator.camera.getPicture(function(s){
              console.info(s);

              //判断是否图片
              if(s.indexOf("file:///")==0){
                  if(s.lastIndexOf('.')<=0){
                      PUB.toast('您选取的文件不是图片！');
                      def.resolve([]);
                      return;
                  }else{
                      var ext = s.substring(s.lastIndexOf('.')).toUpperCase();
                      if(!(ext.indexOf('.PNG')==0||ext.indexOf('.JPG')==0||ext.indexOf('.JPEG')==0||ext.indexOf('.GIF')==0)){
                        PUB.toast('您选取的文件不是图片！');
                        def.resolve([]);
                        return;
                      }
                  }
              }
              var timestamp = new Date().getTime();
              var filename = Meteor.userId()+'_'+timestamp+'.jpg';
              console.log('File name ' + filename);
              //uploadToS3(filename,results[i],callback);
              uploadToAliyun(filename,s, callback).done(function(value){
                upimgs.push(value);

                if(upimgs.length >= length)
                  def.resolve(upimgs);
              }).fail(function(err){
                def.reject(err);
              });
          }, function(s){
              def.resolve([]);
              console.info(s);
          }, {
            quality: 80,
            targetWidth: 400,
            targetHeight: 400,
            destinationType: destinationType.NATIVE_URI,
            sourceType: pictureSource.SAVEDPHOTOALBUM
          });
          return def.promise();
      }else{
        window.imagePicker.getPictures(
          function(results) {
            if(results == undefined){
              def.resolve([]);
              return;
            }
            var length = 0;
            try{
              length=results.length;
            }
            catch (error){
              length=results.length;
            }
            if (length == 0){
              def.resolve([]);
              return;
            }
            for (var i = 0; i < length; i++) {
              var timestamp = new Date().getTime();
              var filename = Meteor.userId()+'_'+timestamp+'.jpg';
              console.log('File name ' + filename);
              //uploadToS3(filename,results[i],callback);
              uploadToAliyun(filename,results[i], callback).done(function(value){
              //uploadToBCS(filename,results[i], callback).done(function(value){
                upimgs.push(value);

                if(upimgs.length >= length)
                  def.resolve(upimgs);
              }).fail(function(err){
                def.reject(err);
              });
            }
          }, function (error){
              def.reject(error);
              console.log('Pick Image Error ' + error);
              if(callback){
                  callback(null);
              }
          }, {
            maximumImagesCount: 9,
            width: 400,
            height: 400,
            quality: 80
          });
        }

        return def.promise();
      }
      
    /**
    * upload new taken photo in cordova with plugin for select/resize file to S3
    *
    * @method uploadFileInCordova
    * @param {Function} callback
    * @return {Object} url in callback
    */
    var uploadNewTakenPhotoInCordova = function(callback, limit){
      var def = $.Deferred();
      var upimgs = [];

      var pictureSource = navigator.camera.PictureSourceType;
      var destinationType = navigator.camera.DestinationType;

      navigator.camera.getPicture((function(s) {
        console.log('take photo suc');
        console.log('img URI value is: ' + s);
        var timestamp = new Date().getTime();
        var filename = Meteor.userId()+'_'+timestamp+'.jpg';
        console.log('File name ' + filename);

        uploadToAliyun(filename,s, callback).done(function(value){
          upimgs.push(value);
          console.log("in upload new taken photo, the value is: " + JSON.stringify(value))
          def.resolve(upimgs);
        }).fail(function(err){
                def.reject(err);
            });
      }), (function(s) {
        def.resolve([]);
        console.log('take photo failed');
      }), {
        quality: 80,
        destinationType: destinationType.FILE_URI,
        sourceType: pictureSource.CAMERA,
        targetWidth: 400,
        targetHeight: 400,
        correctOrientation: true,
        saveToPhotoAlbum: true
      });

      return def.promise();
    }

      // 使用： uploadNewTakenPhoto(/**/).done(function(value){}).fail(function(err){})
      uploadNewTakenPhoto = function(callback, limit){
        Template.public_loading_index.__helpers.get('show')('图片上传中...');

        return uploadNewTakenPhotoInCordova(callback, limit).done(function(value){
          Template.public_loading_index.__helpers.get('close')();
        }).fail(function(){
          Template.public_loading_index.__helpers.get('close')();
        });
      }

      // 使用： uploadFile(/**/).done(function(value){}).fail(function(err){})
      uploadFile = function(callback, limit){
        Template.public_loading_index.__helpers.get('show')('图片上传中...');

        return uploadFileInCordova(callback, limit).done(function(value){
          Template.public_loading_index.__helpers.get('close')();
        }).fail(function(){
          Template.public_loading_index.__helpers.get('close')();
        });
      }
      uploadFiles = function(callback, limit){
              Template.public_loading_index.__helpers.get('show')('图片发送中...');

              return uploadFileInCordova(callback, limit).done(function(value){
                Template.public_loading_index.__helpers.get('close')();
              }).fail(function(){
                Template.public_loading_index.__helpers.get('close')();
              });
            }
    }

if(Meteor.isClient){
    //Meteor.startup(function(){
      /*Template.fileUpload.helpers({
        files: function () {
          return Session.get("upload_images");
        }
      });
      Template.fileUpload.events({
          'click #upload': function(event){
          uploadFile(function(result){
              if(result){
                  //小黑板上传图片;feiwu add.
                  var upload_images = Session.get("upload_images");
                  upload_images.push({url: result});
                  Session.set("upload_images",upload_images);
                  console.log('upload success: url is ' + result);
              }
          });
          return false;
        }
      });*/
    //});
}

// 测试用
if(!Meteor.isCordova){
  uploadFile = function(callback, limit){
    var def = $.Deferred();
    var filename = 'http://localhost:3000/' + (new Mongo.ObjectID)._str + '.png';
    //callback('http://localhost.com/jc73WcijugBX3tKJv_1435822877599.jpg');

    def.resolve([{url: filename}]);
    callback(filename);

    return def.promise();
  }
}
