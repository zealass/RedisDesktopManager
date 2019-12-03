import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import "./../../common/platformutils.js" as PlatformUtils
import "."
import "./../../common/"

RowLayout {
    id: root

    focus: true

    state: "menu"

    states: [
        State {
            name: "menu"
            PropertyChanges { target: dbMenu; visible: true;}
            PropertyChanges { target: bulkMenu; visible: false;}
            PropertyChanges { target: filterMenu; visible: false;}            
        },
        State {
            name: "bulk_menu"
            PropertyChanges { target: dbMenu; visible: false;}
            PropertyChanges { target: bulkMenu; visible: true;}
            PropertyChanges { target: filterMenu; visible: false;}
        },
        State {
            name: "filter"
            PropertyChanges { target: dbMenu; visible: false;}
            PropertyChanges { target: bulkMenu; visible: false;}
            PropertyChanges { target: filterMenu; visible: true;}
        }
    ]

    Keys.onPressed: {
        if (state == "filter" && event.key == Qt.Key_Escape) {
            state = "menu"
        }
    }

    InlineMenu {
        id: dbMenu

        Layout.fillWidth: true

        callbacks: {
            "filter": function() {
                root.state = "filter"
            },
            "live_update": function () {
                if (styleData.value["live_update"]) {
                    connectionsManager.setMetadata(styleData.index, "live_update", '')
                } else {
                    connectionsManager.setMetadata(styleData.index, "live_update", true)
                }
            },
            "bulk_menu": function() {
                root.state = "bulk_menu"
            },
        }

        model: {
            if (styleData.value["locked"] === true) {
                return [
                            {
                                'icon': "qrc:/images/offline.svg", 'event': 'cancel', "help": qsTranslate("RDM","Disconnect"),
                            },
                        ]
            } else {
                return [
                            {
                                'icon': "qrc:/images/filter.svg", 'callback': 'filter', "help": qsTranslate("RDM","Open Keys Filter"),
                                "shortcut": PlatformUtils.isOSX()? "Meta+F" : "Ctrl+F",
                            },
                            {
                                'icon': "qrc:/images/refresh.svg", 'event': 'reload', "help": qsTranslate("RDM","Reload Keys in Database"),
                                "shortcut": PlatformUtils.isOSX()? "Meta+R" : "Ctrl+R",
                            },
                            {
                                'icon': "qrc:/images/add.svg", 'event': 'add_key', "help": qsTranslate("RDM","Add New Key"),
                                "shortcut": PlatformUtils.isOSX()? "Meta+N" : "Ctrl+N",
                            },
                            {
                                'icon': styleData.value["live_update"]? "qrc:/images/live_update_disable.svg" : "qrc:/images/live_update.svg",
                                'callback': 'live_update',
                                "help": styleData.value["live_update"]? qsTranslate("RDM","Disable Live Update") : qsTranslate("RDM","Enable Live Update"),
                                "shortcut": PlatformUtils.isOSX()? "Meta+L" : "Ctrl+L",
                            },
                            {
                                'icon': "qrc:/images/console.svg", 'event': 'console', "help": qsTranslate("RDM","Open Console"),
                                "shortcut": Qt.platform.os == "osx"? "Meta+T" : "Ctrl+T",
                            },
                            {'icon': "qrc:/images/memory_usage.svg", "event": "analyze_memory_usage", "help": qsTranslate("RDM","Analyze Used Memory")},
                            {
                                'icon': "qrc:/images/bulk_operations.svg", 'callback': 'bulk_menu', "help": qsTranslate("RDM","Bulk Operations"),
                            },
                        ]
            }
        }
    }

    InlineMenu {
        id: bulkMenu

        Layout.fillWidth: true

        callbacks: {
            "db_menu": function() {
                root.state = "menu"
            },
        }

        model: {
            return [
                        {
                            'icon': "qrc:/images/cleanup.svg", 'event': 'flush', "help": qsTranslate("RDM","Flush Database"),                            
                        },
                        {
                            'icon': "qrc:/images/cleanup_filtered.svg", 'event': 'delete_keys', "help": qsTranslate("RDM","Delete keys with filter"),
                        },
                        {
                            'icon': "qrc:/images/ttl.svg", 'event': 'ttl', "help": qsTranslate("RDM","Set TTL for multiple keys"),
                        },
                        {
                            'icon': "qrc:/images/db_copy.svg", 'event': 'copy_keys', "help": qsTranslate("RDM","Copy keys from this database to another"),
                        },
                        {
                            'icon': "qrc:/images/import.svg", 'event': 'rdb_import', "help": qsTranslate("RDM","Import keys from RDB file"),
                        },
                        {
                            'icon': "qrc:/images/back.svg", 'callback': 'db_menu', "help": qsTranslate("RDM","Back"),
                        },

                    ]
        }

    }

    RowLayout {
        id: filterMenu

        spacing: 0

        Layout.fillWidth: true

        TextField {
            id: filterText

            Layout.fillWidth: true

            placeholderText: qsTranslate("RDM","Enter Filter")
            objectName: "rdm_inline_menu_filter_field"

            text: styleData.value["filter"]

            onAccepted: {
                filterOk.setFilter()
                focus = false
            }
        }

        ImageButton {
            id: filterOk
            iconSource: "qrc:/images/ok.svg"
            objectName: "rdm_inline_menu_button_apply_filter"

            onClicked: setFilter()

            function setFilter() {
                if (!connectionsManager)
                    return

                connectionsManager.setMetadata(styleData.index, "filter", filterText.text)
                root.state = "menu"
            }
        }

        ImageButton {
            id: filterHelp

            imgWidth: PlatformUtils.isOSXRetina(Screen)? 20 : 25
            imgHeight: PlatformUtils.isOSXRetina(Screen)? 20 : 25
            iconSource: "qrc:/images/help.svg"
            onClicked: Qt.openUrlExternally("http://docs.redisdesktop.com/en/latest/features/#search-in-connection-tree")
        }

        ImageButton {
            id: filterCancel

            imgWidth: PlatformUtils.isOSXRetina(Screen)? 20 : 25
            imgHeight: PlatformUtils.isOSXRetina(Screen)? 20 : 25
            iconSource: "qrc:/images/clear.svg"
            objectName: "rdm_inline_menu_button_reset_filter"

            onClicked: {
                if (!connectionsManager)
                    return

                connectionsManager.setMetadata(styleData.index, "filter", "")
                root.state = "menu"
            }
        }
    }
}
