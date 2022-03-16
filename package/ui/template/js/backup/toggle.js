$(function () {
	$(".a_toggle").click(function () {
		if ($(this).html() == "&nbsp;-")
			$(this).html("+");
		else
			$(this).html("&nbsp;-");
	});
});