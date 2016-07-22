if (Meteor.isCordova){
    var showDebug = false;

    var uploadToAliyun_new = function(filename,URI, callback){      
        Meteor.call('getAliyunWritePolicy',filename,URI,function(error,result){
            if(error) {
                DEBUG && console.log('getAliyunWritePolicy error: ' + error);
                if(callback){
                    callback(null);
                }
            }
            DEBUG && console.log('File URI is ' + result.orignalURI);
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
                if (progressEvent && progressEvent.lengthComputable) {
                    if (callback){
                        DEBUG && console.log('Loaded ' + progressEvent.loaded + ' Total ' + progressEvent.total);
                        callback('uploading',progressEvent)
                    }
                } else {
                    DEBUG && console.log('Upload ++');
                }
            };
            ft.upload(result.orignalURI, uri, function(e){
                var filename = result.acceccURI.replace(/^.*[\\\/]/, '');
                var cdnFileName = "http://data.youzhadahuo.com/" + filename;
                DEBUG && console.log("cdnFileName = "+cdnFileName);
                //def.resolve({url: cdnFileName});
                if(callback){
                    callback('done', cdnFileName);
                }
            }, function(e){
                DEBUG && console.log('upload error' + e.code );
                if (callback) {
                    callback('error',null);
                }
            }, options,true);

            return ft;
        });
    }

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
            var cdnFileName = "http://data.youzhadahuo.com/" + filename;
            DEBUG && console.log("cdnFileName = "+cdnFileName);
            def.resolve({url: cdnFileName});
            if(callback){
                //computeProgressBar(filename, 100);
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

    var FileDownloadOptions = function(fileKey, fileName, mimeType, params, headers, httpMethod) {
        this.headers = headers || null;
    };
    downloadFromBCS = function(source, callback){
        function fail(error) {
            showDebug && console.log(error)
            if(callback){
                callback(null, source);
            }
        }
        function onFileSystemSuccess(fileSystem) {
            var timestamp = new Date().getTime();
            //var hashOnUrl = Math.abs(source.hashCode());
            var filename = Meteor.userId()+'_'+timestamp+ '_' + source.replace(/^.*[\\\/]/, '');
            fileSystem.root.getFile(filename, {create: true, exclusive: false},
                function(fileEntry){
                    showDebug && console.log("filename = "+filename+", fileEntry.toURL()="+fileEntry.toURL());
                    //var target = "cdvfile://localhost/temporary/"+filename
                    var target = fileEntry.toURL();
                    showDebug && console.log("target = "+target);

                    var options = new FileDownloadOptions();
                    var headers = {
                      "x-bs-acl": "public-read",
                      "Content-Type": "image/jpeg"
                      //"Authorization": "Basic dGVzdHVzZXJuYW1lOnRlc3RwYXNzd29yZA=="
                    };
                    options.headers = headers;
                    var ft = new FileTransfer();
                    ft.download(source, target, function(theFile){
                        //showDebug && console.log('download suc, theFile.toURL='+theFile.toURL());
                        if(callback){
                            callback(theFile.toURL(),source,theFile);
                        }
                    }, function(e){
                        showDebug && console.log('download error: ' + e.code)
                        if(callback){
                          callback(null, source);
                        }
                    }, true, options);

                }, fail);
        }
        window.requestFileSystem(LocalFileSystem.TEMPORARY, 0, onFileSystemSuccess, fail);
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
            quality: 20,
            targetWidth: 1900,
            targetHeight: 1900,
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
            width: 1900,
            height: 1900,
            quality: 20
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
        quality: 20,
        destinationType: destinationType.FILE_URI,
        sourceType: pictureSource.CAMERA,
        targetWidth: 1900,
        targetHeight: 1900,
        correctOrientation: true,
        saveToPhotoAlbum: true
      });

      return def.promise();
    }
    
    takePictureFromCamera = function(callback) {
        var result = {};
        var pictureSource = navigator.camera.PictureSourceType;
        var destinationType = navigator.camera.DestinationType;
        
        navigator.camera.getPicture((function(imageURI) {
            console.log('take photo suc');
            console.log('img URI value is: ' + imageURI);
            var timestamp = new Date().getTime();
            var filename = Meteor.userId()+'_'+timestamp+ '_' + imageURI.replace(/^.*[\\\/]/, '');
            console.log('File name ' + filename);
            result.filename = filename;
            result.URI = imageURI;
            if (device.platform === 'Android'){
                //returnURI = replaceAll("file:///storage/emulated/0", 'cdvfile://localhost/persistent',imageURI);
                window.resolveLocalFileSystemURL(imageURI, function(fileEntry) {
                    fileEntry.file(function(file) {
                        var reader = new FileReader();
                        reader.onloadend = function(event) {
                            result.smallImage = event.target.result;
                            if(callback){
                                callback(null, result);
                            }
                        };
                        reader.readAsDataURL(file);
                    }, function(e) {
                        console.log('fileEntry.file Error = ' + e);
                    });
                }, function(e) {
                    console.log('resolveLocalFileSystemURL Error = ' + e);
                });
            } else if (device.platform === 'iOS') {
                //"file:///var/mobile/Containers/Data/Application/748449D2-3F45-4057-9630-F12065B1C0C8/tmp/cdv_photo_002.jpg"
                console.log('image uri is ' + imageURI);
                result.smallImage = 'cdvfile://localhost/temporary/' + imageURI.replace(/^.*[\\\/]/, '');
                if(callback){
                    callback(null, result);
                }
            }
        }), (function(err) {
            console.log('take photo failed');
            callback('take photo failed');
        }), {
            quality: 20,
            destinationType: destinationType.FILE_URI,
            sourceType: pictureSource.CAMERA,
            targetWidth: 1900,
            targetHeight: 1900,
            correctOrientation: true,
            saveToPhotoAlbum: true
        });
    };

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

    var fileUploader = function (item,callback){
        DEBUG && console.log('uploading ' + JSON.stringify(item));

        if (Session.get('terminateUpload')) {
            return callback(new Error('aboutUpload'),item)
        }
        var self = this;
        var ft = uploadToAliyun_new(item.filename, item.URI, function(status,param){
            if (Session.get('terminateUpload')) {
                return callback(new Error('aboutUpload'),item)
            }
            if (status === 'uploading' && param){
                var percentage = parseInt(100*(self.uploaded/self.total + (param.loaded / param.total)/self.total));
            	DEBUG && console.log("uploading: progressBarWidth="+percentage);
                if (percentage > Session.get('progressBarWidth')) {
                    Session.set('progressBarWidth', percentage);
                    if(self.progressCallback){
                      self.progressCallback(item, percentage);
                    }
                }
            } else if (status === 'done'){
                self.uploaded++;
                Session.set('progressBarWidth', parseInt(100*self.uploaded/self.total));
                item.url = param;
                item.uploaded = true;
                callback(null,item)
            } else if (status === 'error'){
                item.uploaded = false;
                Meteor.setTimeout( function() {
                    fileUploader(item, callback)
                },1000);
            }
        });
    };
    var asyncCallback = function (err,result){
        DEBUG && console.log('async processing done ' + JSON.stringify(result));
        if (err){
            if (this.finalCallback) {
                this.finalCallback('error', result);
            }
        } else {
            if (this.finalCallback) {
                this.finalCallback(null, result);
            }
        }
        //Template.progressBar.__helpers.get('close')();
    };
    multiThreadUploadFile_new = function(draftData, maxThreads, callback, progress) {
        progress = progress || function(){};
        var uploadObj = {
            fileUploader : fileUploader,
            draftData : draftData,
            finalCallback: callback,
            asyncCallback: asyncCallback,
            progressCallback: progress,
            uploaded : 0,
            total : draftData.length
        };
        console.log('draft data is ' + JSON.stringify(draftData));

        Session.set('aboutUpload', false);
        async.mapLimit(draftData,maxThreads,uploadObj.fileUploader.bind(uploadObj),uploadObj.asyncCallback.bind(uploadObj));
    };
    multiThreadUploadFileWhenPublishInCordova = function(draftData, callback){
        //DEBUG && console.log("draftData="+JSON.stringify(draftData));
        if (draftData.length > 0) {
            Template.progressBar.__helpers.get('show')();
        } else {
            callback('failed');
        }

        var multiThreadUploadFileCallback = function(err,result){
          if (!err) {
              callback(null, result);
              Meteor.setTimeout(function() {
              	Template.progressBar.__helpers.get('close')();
              }, 350);
          } else {
              DEBUG && console.log("Jump to post page...");
              //PUB.pagepop();//Pop addPost page, it was added by PUB.page('/progressBar');
              callback('failed', result);
              DEBUG && console.log("multiThreadUploadFile, failed");
              Template.progressBar.__helpers.get('close')();
          }
        };

        multiThreadUploadFile_new(draftData, 2, multiThreadUploadFileCallback);
        return;
    };

    var processImageInAndroid = function(i,results,callback){
        var length = results.length;
        var timestamp = new Date().getTime();
        var originalFilename = results[i].replace(/^.*[\\\/]/, '');
        var filename = Meteor.userId()+'_'+timestamp+ '_' + originalFilename.replace(/%/g, '');
        var toProcessURI = results[i];
        DEBUG && console.log('File name ' + filename);

        var params = {filename:filename, originalFilename:originalFilename, URI:toProcessURI, smallImage:''};
        var fileExt = filename.split('.').pop();
        if(fileExt.toUpperCase()==='GIF'){
            ImageBase64.base64({
                    uri: results[i],
                    quality: 20,
                    width: 1900,
                    height: 1900
                },
                function(a) {
                    params.smallImage = "data:image/jpg;base64,"+a.base64;
                    callback(null, params, i+1, length);
                },
                function(e) {
                    DEBUG && console.log("error" + e);
                    callback('error');
                });
        }else{
            window.resolveLocalFileSystemURL(results[i], function(fileEntry) {
                fileEntry.file(function(file) {
                    var reader = new FileReader();
                    reader.onloadend = function(event) {
                        params.smallImage = event.target.result;
                        callback(null, params, (i+1),length);
                    };
                    reader.readAsDataURL(file);
                }, function(e) {
                    DEBUG && console.log('fileEntry.file Error = ' + e);
                    callback('error');
                });
            }, function(e) {
                DEBUG && console.log('resolveLocalFileSystemURL Error = ' + e);
                callback('error');
            });
        }
    };

    selectMediaFromAblum = function(max_number, callback){
        window.imagePicker.getPictures(
          function(results) {
            if(results === undefined) {
                return;
            }

            var length = 0;
            try{
              length=results.length;
            }
            catch (error){
              length=results.length;
            }
            if (length === 0) {
              callback('cancel');
              return;
            }

            if(device.platform === 'Android' ){
                var obj = {};
                obj.currentCount = 0;
                obj.totalCount = length;
                var processImageInAndroidCallback = function(error, data, currentCount, totalCount){
                    if (error){
                        DEBUG && console.log('Got error');
                    }
                    if (callback){
                        callback(null, data, currentCount, totalCount);
                    }
                    if (++obj.currentCount < obj.totalCount){
                        processImageInAndroid(obj.currentCount, results, processImageInAndroidCallback);
                    }
                };
                processImageInAndroid(obj.currentCount,results,processImageInAndroidCallback);
            } else {
                for (var i = 0; i < length; i++) {
                  var timestamp = new Date().getTime();
                  var originalFilename = results[i].replace(/^.*[\\\/]/, '');
                  var filename = Meteor.userId()+'_'+timestamp+ '_' + originalFilename;
                  DEBUG && console.log('File name ' + filename);
                  DEBUG && console.log('Original full path ' + results[i]);
                  var params = '';
                  /*if(device.platform === 'Android'){
                      params = {filename:filename, URI:results[i], smallImage:'cdvfile://localhost/cache/' + originalFilename};
                  }
                  else */{
                      params = {filename:filename, URI:results[i], smallImage:'cdvfile://localhost/temporary/' + originalFilename};
                  }
                  callback(null, params,(i+1),length);
                }
            }
          }, function (error){
              DEBUG && console.log('Pick Image Error ' + error);
              if(callback){
                  callback(null);
              }
          }, {
            maximumImagesCount: max_number,
            width: 1900,
            height: 1900,
            quality: 20,
            storage: 'temporary'
        });
    }
}

if(Meteor.isClient){
    //Meteor.startup(function(){
      Template.fileUpload.helpers({
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
      });
    //});
}

// 测试用
if(!Meteor.isCordova){
  uploadFile = function(callback, limit){
    var def = $.Deferred();
    var filename = 'http://localhost:3000/' + (new Mongo.ObjectID)._str + '.png';
    //callback('http://data.youzhadahuo.com/jc73WcijugBX3tKJv_1435822877599.jpg');

    def.resolve([{url: filename}]);
    callback(filename);

    return def.promise();
  }
}
