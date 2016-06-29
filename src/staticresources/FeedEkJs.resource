/*FeedEk jQuery RSS/ATOM Feed Plugin v2.0
* http://jquery-plugins.net/FeedEk/FeedEk.html  
* https://github.com/enginkizil/FeedEk
* Author : Engin KIZIL http://www.enginkizil.com */

(function($){$.fn.FeedEk=function(opt){var def=$.extend({FeedUrl:["http://rss.cnn.com/rss/edition.rss"],MaxCount:5,ShowDesc:true,ShowPubDate:true,CharacterLimit:0,TitleLinkTarget:"_blank",DateFormat:"",DateFormatLang:"en"},opt);var id=$(this).attr("id"),i,s="",dt;$("#"+id).empty().append('Please wait whilst we load the news');
$.each(def.FeedUrl, function(key, value){
$("#"+id).empty();
$("#"+id).append('<ul class="feedEkList"></ul>');
$.ajax({url:"https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num="+def.MaxCount+"&output=json&q="+encodeURIComponent(value)+"&hl=en&callback=?",dataType:"json",success:function(data){$.each(data.responseData.feed.entries,function(e,item){s+='<li><div class="itemTitle"><a href="'+item.link+'" target="'+def.TitleLinkTarget+'" >'+item.title+"</a></div>";if(def.ShowPubDate){dt=new Date(item.publishedDate);if($.trim(def.DateFormat).length>0){try{moment.lang(def.DateFormatLang);s+='<div class="itemDate">'+moment(dt).format(def.DateFormat)+"</div>"}catch(e){s+='<div class="itemDate">'+dt.toLocaleDateString()+"</div>"}}else{s+='<div class="itemDate">'+dt.toLocaleDateString()+"</div>"}}if(def.ShowDesc){if(def.DescCharacterLimit>0&&item.content.length>def.DescCharacterLimit){s+='<div class="itemContent">'+item.content.substr(0,def.DescCharacterLimit)+"...</div>"}else{s+='<div class="itemContent">'+item.content+"</div>"}}});$("#"+id+" .feedEkList").append(s);s='';if(key == def.FeedUrl.length - 1){displayNews();}}});

});
}})(jQuery);