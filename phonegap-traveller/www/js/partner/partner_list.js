/**
 * @TimZhang
 * 
 */
$(document).bind("pageinit","#partner_list",function(){
	$("#list_template").hide();
});
$(document).on("pageshow","#partner_list",function(){ 
	$("#title_name").html(remote.utils.getParam("title_name"));
	$.getJSON(partner_list.url, function(listdata){
		var listD = listdata.rows;
		var listDL=listdata.total_rows;
		for(var i=0;i<listDL;i++){
		var temp = $("#list_template").clone();
//		temp.find("#namelogo").attr("src",listD[i].value.userLogo);
		temp.find("#username").html(listD[i].value.userName);
		temp.find("#userCity").html("我在"+listD[i].value.userCity);
		temp.find("#changeToDetail").bind("click",function (){partner_list.enter_partner_detail($(this).attr("partner_detail_id"),true);});
		temp.find("#changeToDetail").attr("partner_detail_id",listD[i].value._id );
		var line = listD[i].value.line;
		temp.find("#line").html(line.join("--"))
		temp.find("#start_time").html(listD[i].value.startTime);
		temp.find("#description").html(listD[i].value.description);
		var attachments=[];
		var att=listD[i].value.attachments;
		if(att){
			var attL=att.length;
			for(var l=0;l<attL;l++){
				attachments[l]='<img src="'+att[l]+'" style="margin-right: 10px;">';
			}
			temp.find("#attachments").html(attachments.join(''));
		}
		temp.find("#createTime").html(DateFormat.format.prettyDate(new Date(listD[i].value.createTime)));
		temp.find("#like").html(listD[i].value.like);
		var comment = listD[i].value.comment.length;
		temp.find("#comment").html(comment);
		temp.show();
		//temp.css("display":"block");
		//temp.css("visibility":"visible");
		$("#partner_list_main").append(temp);
		}
	});
	
});
var partner_list = {
		url: remote.website + '/pick_msg/_design/document/_view/getFindPartnerList',
		enter_partner_detail : function(id,changeHash) {
			$.mobile.changePage(root_ + "/partner/partner_detail.html?partner_detail_id="+id, {
				transition : "slide",
				"changeHash" : changeHash
			});
		},
		enter_partner_detail_back : function(){
			this.enter_partner_detail(id,false);
		},
		enter_partner_comment : function() {
			$.mobile.changePage(root_ + "/partner/partner_comment.html", {
				transition : "slide"
			});
		}
	}