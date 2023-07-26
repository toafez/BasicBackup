Ext.namespace("SYNO.SDS.BasicBackup.Utils");

Ext.define("SYNO.SDS.BasicBackup.Application", {
    extend: "SYNO.SDS.AppInstance",
    appWindowName: "SYNO.SDS.BasicBackup.MainWindow",
    constructor: function() {
        this.callParent(arguments);
    }
});

Ext.define("SYNO.SDS.BasicBackup.MainWindow", {
    extend: "SYNO.SDS.AppWindow",
    constructor: function(a) {
        this.appInstance = a.appInstance;
        SYNO.SDS.BasicBackup.MainWindow.superclass.constructor.call(this, Ext.apply({
            layout: "fit",
            resizable: true,
            cls: "syno-app-win",
            maximizable: true,
            minimizable: true,
            width: 1024,
            height: 768,
            html: SYNO.SDS.BasicBackup.Utils.getMainHtml()
        }, a));
        SYNO.SDS.BasicBackup.Utils.ApplicationWindow = this;
    },

    onOpen: function() {
        SYNO.SDS.BasicBackup.MainWindow.superclass.onOpen.apply(this, arguments);
    },

    onRequest: function(a) {
        SYNO.SDS.BasicBackup.MainWindow.superclass.onRequest.call(this, a);
    },

    onClose: function() {
        clearTimeout(SYNO.SDS.BasicBackup.TimeOutID);
        SYNO.SDS.BasicBackup.TimeOutID = undefined;
        SYNO.SDS.BasicBackup.MainWindow.superclass.onClose.apply(this, arguments);
        this.doClose();
        return true;
    }
});

Ext.apply(SYNO.SDS.BasicBackup.Utils, function() {
    return {
        getMainHtml: function() {
            // Timestamp must be inserted here to prevent caching of iFrame
            return '<iframe src="webman/3rdparty/BasicBackup/index.cgi?timestamp=' + new Date().getTime() + '" title="react-app" style="width: 100%; height: 100%; border: none; margin: 0"/>';
        },
    }
}());