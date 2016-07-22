/**
 * @TimZhang
 * 
 */
$(document).bind("pageinit","#partner_detail",function(){
	$("#partner_detail_main").hide();
	$("#revert_temp").hide();
});
$(document).on("pageshow","#partner_detail",function(){ 
	var detail_url = remote.website+'/pick_msg/'+$.urlGet().partner_detail_id;
	$.getJSON(detail_url, function(detaildata){
		remote.utils.setParam("current_date_partner",JSON.stringify(detaildata));
		var listD = detaildata;
		var temp = $("#partner_detail_main");
		//temp.find("#namelogo").attr("src",listD.userLogo);
		temp.find("#username").html(listD.userName);
		temp.find("#userCity").html("我在"+listD.userCity);
		/*temp.find("#changeToDetail").bind("click",function (){partner_list.enter_partner_detail($(this).attr("partner_detail_id"));});
		temp.find("#changeToDetail").attr("partner_detail_id",listD[i].value._id );*/
		var line = listD.line;
		temp.find("#route").html(line.join("--"))
		temp.find("#start_time").html(listD.startTime);
		temp.find("#description").html(listD.description);
		var attachments=[];
		var att=listD.attachments;
		if(att){
			var attL=att.length;
			for(var l=0;l<attL;l++){
				attachments[l]='<img src="'+att[l]+'" style="margin-right: 10px;">';
			}
			temp.find("#attachments").html(attachments.join(''));
		}
		temp.find("#createTime").html(DateFormat.format.prettyDate(new Date(listD.createTime)));
		temp.find("#like").html(listD.like);
		var length = listD.comment.length;
		for(var j=0;j<length;j++){
			var obj = listD.comment[j];
			var temp_comm = $("#revert_temp").clone();
//			temp_comm.find("#userlogo").attr("src",obj.userLogo);
			temp_comm.find("#username").html(obj.userName+"：");
			temp_comm.find("#content").html(obj.content);
			temp_comm.find("#createTime").html(DateFormat.format.prettyDate(new Date(obj.createTime)));
			temp_comm.find("#revert").on('click',function(){partner_detail.enter_partner_comment()});
			temp_comm.show();
			$("#revert_list").append(temp_comm);
		}
		temp.find("#comment").html(length);
		$("#partner_list_main").show();
		temp.show();
		
	});
	
});
var partner_detail = {
		enter_partner_detail : function(id,changeHash) {
			$.mobile.changePage(root_ + "/partner/partner_detail.html", {
				transition : "slide",
				"changeHash" : changeHash
			});
		},
		enter_partner_detail_back : function(){
			partner_list.enter_partner_detail(id,false);
		},
		enter_partner_comment : function() {
			$.mobile.changePage(root_ + "/partner/partner_comment.html", {
				transition : "slide"
			});
		}
	}