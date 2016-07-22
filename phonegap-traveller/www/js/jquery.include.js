/**
 * IncludeHtml - jQuery plugin to include remote html within a custom
 *                   html <include> tag.
 *
 * Copyright (c) 2010 David Coallier <david.coallier@gmail.com>
 *
 * Example at http://github.com/davidcoallier/include-html/tree/master/example/
 */
(function($) {
    $.fn.include = function(settings) {
        this.each(function() {
            var container = $(this);
            var pageSrc   = $(this).attr('src');
            
            $.get(pageSrc, {}, function(data) {
                container.after(data);
            });
        });
        return this;
    };
    
    $(document).ready(function() {
        $('include').include();
    });
})(jQuery);