// Script um die clientseitige Validierung bei einem Rückschritt zu deaktivieren
$(function () {
    $('.disable_validation').click(function() {
        $(this).parents("form").attr('novalidate', 'novalidate');
    });
});
