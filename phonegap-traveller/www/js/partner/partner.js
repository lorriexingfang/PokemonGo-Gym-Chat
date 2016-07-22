/**
 * @bishen.org
 * 文件配置
 */
var partnerConf = {
		json:remote.website+'/traveller/partner_column', //旅游列表json
		colors:['#fff','#ff7575','#AAAAFF','#93FF93','#ffaad5','#80FFFF','#FFFF6F','#DCB5FF','#FFC78E','#CDCD9A'] //跑马灯字色系
};

$(document).on("pageinit","#partner_home",function(){
	$("#travelist").hide();
});

$(document).on("pagebeforecreate","#partner_home",function(){

});

$(document).on("pageshow","#partner_home",function(){ // 当进入页面二时
//	var temple = $("#travelist").css("visibility","hidden");
	// 跑马灯
	$('#marquee1').kxbdMarquee({isEqual: false});
	$('#marquee2').kxbdMarquee({isEqual: false});
	$('#marquee3').kxbdMarquee({isEqual: false});

	var temple = $("#travelist").html(); // 模版
	var temple2 = temple.substring(temple.indexOf('<!-- photolists -->')+19,temple.indexOf('<!-- /photolists -->'));
	var w = $(window).width();
	var h = Math.ceil(w/2);
	// 旅游列表
	
//	$.getJSON(partnerConf.json, function(data){
	   var data={
			   "_id": "partner_column",
			   "_rev": "1-229c8fd2ca9f95ae1563214384f22e58",
			   "data": [
			     {
			       "columnName": "文化旅游",
			       "columnID": "1000",
			       "items": [
			         {
			           "img": "../../img/partner/1.jpg",
			           "name": "摄影旅游",
			           "itemID": "1"
			         },
			         {
			           "img": "../../img/partner/2.jpg",
			           "name": "绘画写生游",
			           "itemID": "2"
			         },
			         {
			           "img": "../../img/partner/3.jpg",
			           "name": "民俗文化游",
			           "itemID": "3"
			         },
			         {
			           "img": "../../img/partner/4.jpg",
			           "name": "自然探险游",
			           "itemID": "4"
			         }
			       ]
			     },
			     {
			       "columnName": "主题旅游",
			       "columnID": "2000",
			       "items": [
			         {
			           "img": "../../img/partner/21.jpg",
			           "name": "自驾游",
			           "itemID": "21"
			         },
			         {
			           "img": "../../img/partner/22.jpg",
			           "name": "租车游",
			           "itemID": "22"
			         }
			       ]
			     },
			     {
			       "columnName": "国内热门目的地",
			       "columnID": "3000",
			       "items": [
			         {
			           "img": "../../img/partner/31.jpg",
			           "name": "迪庆藏区",
			           "itemID": "31"
			         },
			         {
			           "img": "../../img/partner/32.jpg",
			           "name": "云南",
			           "itemID": "32"
			         },
			         {
			           "img": "../../img/partner/33.jpg",
			           "name": "厦门",
			           "itemID": "33"
			         },
			         {
			           "img": "../../img/partner/34.jpg",
			           "name": "绍兴",
			           "itemID": "34"
			         }
			       ]
			     },
			     {
			       "columnName": "海外热门目的地",
			       "columnID": "4000",
			       "items": [
			         {
			           "img": "../../img/partner/41.jpg",
			           "name": "巴黎",
			           "itemID": "41"
			         },
			         {
			           "img": "../../img/partner/42.jpg",
			           "name": "大板",
			           "itemID": "42"
			         },
			         {
			           "img": "../../img/partner/43.jpg",
			           "name": "新加坡",
			           "itemID": "43"
			         },
			         {
			           "img": "../../img/partner/44.jpg",
			           "name": "尼泊尔",
			           "itemID": "44"
			         }
			       ]
			     }
			   ]
			 };
	   var j = data.data;
		var l = j.length;
		var travelist = '';
		for(var i=0;i<l;i++){
			var tmp2='',tmp = temple.replace(/\${title}/g,j[i].columnName).replace(/\${i}/g,i);
			for(var n=0,nlen=j[i].items.length;n<nlen;n++)
				tmp2 += temple2.replace('${img}',j[i].items[n].img).replace('${name}',j[i].items[n].name).replace('${title_name}',j[i].items[n].name);
			travelist += tmp.replace(temple2,tmp2);
		}
		$("#travelist").show();
		$('#travelist').html(travelist);
		$('.swiper-container').width(w);
		$('.swiper-container').height(h);
		$('.swiper-slide').height(h);
		$('.swiper-title').height(h);
		for(var i=0;i<l;i++)
			new Swiper('#swiper-container'+i,{
				resistance : '100%',
				createPagination:false,
				slidesPerView: 2,
				loop: true
			}).reInit();
//	});
});
var partner = {
		enter_partner_add : function() {
			$.mobile.changePage(root_ + "/partner/partner_add.html", {
				transition : "slide"
			});
		},
		enter_partner_tags : function() {
			$.mobile.changePage(root_ + "/partner/partner_tags.html", {
				transition : "slide"
			});
		},
		enter_partner_list : function(name) {
			remote.utils.setParam("title_name",name);
			$.mobile.changePage(root_ + "/partner/partner_list.html", {
				transition : "slide"
			});
		},
		enter_partner_detail : function(changeHash) {
			$.mobile.changePage(root_ + "/partner/partner_detail.html", {
				transition : "slide",
				"changeHash" : changeHash
			});
		},
		enter_partner_detail_back : function(){
			this.enter_partner_detail(false);
		},
		enter_partner_comment : function() {
			$.mobile.changePage(root_ + "/partner/partner_comment.html", {
				transition : "slide"
			});
		}
	}