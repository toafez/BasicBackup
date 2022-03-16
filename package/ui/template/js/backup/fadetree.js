$(function () {
	$("a").click(function () {
		$("a:contains('Child')").siblings("ul").removeClass();
		$("a:contains('Child')").siblings("ul").addClass("hide");
		var ul = $(this).siblings("ul");
		$(ul).toggleClass("hide", "show");
	});
});
