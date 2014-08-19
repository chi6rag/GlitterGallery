NProgress.configure({ showSpinner: false, speed: 700});

// Based on which page you're on,
// make relevant toolbar element active,
// remove navbar from login page

$("document").ready( function(){
	var articleContent = $(".wrapper article").attr("data");
	if(articleContent === "login"){
		$(".wrapper nav").css("display", "none");
	}
	var toolbarDivs = $("section.toolbar div, section.action div");
	toolbarDivs.each(function(){
			if($(this).attr("data") === articleContent){
				$(this).addClass("active");
			}
	});
});

//  Enable sidr

$("document").ready(function() {
	$('#responsive-menu-button').sidr({
	name: 'sidr-main',
	source: '#navigation'
	});
});

// Initialize colorbox for the slideshows
$("document").ready(function() {
	$('a.gallery').colorbox({rel:'gallery', transition:"none", width:"100%", height:"100%", inline:true});
});




