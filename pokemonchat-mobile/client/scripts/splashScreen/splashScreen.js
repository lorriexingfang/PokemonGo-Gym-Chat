  checkIfUseData = function(){
    if ((navigator.connection.type == Connection.CELL_2G)
        || (navigator.connection.type == Connection.CELL_3G)
        || (navigator.connection.type == Connection.CELL_4G)
        || (navigator.connection.type == 'cellular')) {
        return true;
    } else {
        return false;
    }
  }

Template.splashScreen.rendered=function(){
    $('#wrap').css('height','100%');
    var swiper = new Swiper('.swiper-container', {
        pagination: '.swiper-pagination',
        paginationClickable: true,
        direction: 'horizontal',
        onTouchEnd: function(swiper){
           if(swiper.isEnd){
                window.localStorage.setItem("firstLog", "first");
                Session.set('isFlag', false);

                if(checkIfUseData() &&
                (parseInt(window.localStorage.getItem("LTE_hint_flag")) < 3) ) {
                  Session.set('view','wifiIndex');
                  Blaze.render(Template.lteGuide, document.getElementsByTagName('body')[0]);
                }
                else {
                  Session.set('view','wifiIndex');
                }
            }
        }
    });
};

Template.splashScreen.events({
    "click #lastImg": function() {
        window.localStorage.setItem("firstLog", "first");
        Session.set('isFlag', false);

        if(checkIfUseData() &&
        (parseInt(window.localStorage.getItem("LTE_hint_flag")) < 3) ) {
            Session.set('view','wifiIndex');
            Blaze.render(Template.lteGuide, document.getElementsByTagName('body')[0]);
        }
        else {
                Session.set('view','wifiIndex');
        }
    }
});