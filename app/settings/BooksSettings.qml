/*
  Copyright (C) 2015-2018 Jolla Ltd.
  Copyright (C) 2015-2018 Slava Monich <slava.monich@jolla.com>

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Jolla Ltd nor the names of its contributors may
      be used to endorse or promote products derived from this software
      without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS
  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
  THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

Page {
    id: page
    property bool followOrientationChanges
    property alias title: pageHeader.title
    readonly property string rootPath: "/apps/" + appName() + "/"

    // Deduce package name from the path
    function appName() {
        var parts = Qt.resolvedUrl("dummy").split('/')
        if (parts.length > 2) {
            var name = parts[parts.length-3]
            if (name.indexOf("-books") >= 0) {
                return name
            }
        }
        return "harbour-books"
    }

    Loader {
        active: followOrientationChanges
        Connections {
            target: orientation
            onValueChanged: allowedOrientations =
                (orientation.value === 1) ? Orientation.Portrait :
                (orientation.value === 2) ? Orientation.Landscape :
                                            Orientation.All
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width

            PageHeader {
                id: pageHeader
                //: Settings page header
                //% "Books"
                title: qsTrId("harbour-books-settings-page-header")
            }

            // =============== Display ===============

            SectionHeader {
                //: Section header for display settings
                //% "Display"
                text: qsTrId("harbour-books-settings-page-display-section_header")
            }

            Slider {
                id: fontSizeSlider
                minimumValue: -5
                maximumValue: 15
                stepSize: 1
                //: Slider value label for the standard font size
                //% "Default"
                readonly property string normal: qsTrId("harbour-books-settings-page-font_size_label-default")
                //: Slider label
                //% "Font size"
                label: qsTrId("harbour-books-settings-page-font_size_label")
                valueText: (value === 0) ? normal : ((value > 0) ? ("+" + value) : value)
                width: page.width
                anchors.horizontalCenter: parent.horizontalCenter
                onSliderValueChanged: fontSize.value = value
                Component.onCompleted: value = fontSize.value

                ConfigurationValue {
                    id: fontSize
                    key: rootPath + "fontSize"
                    defaultValue: 0
                    onValueChanged: fontSizeSlider.value = value
                }
            }

            ComboBox {
                id: orientationComboBox
                //: Combo box label
                //% "Orientation"
                label: qsTrId("harbour-books-settings-page-orientation_label")
                value: currentItem ? currentItem.text : ""
                menu: ContextMenu {
                    id: orientationMenu
                    readonly property int defaultIndex: 0
                    MenuItem {
                        //: Combo box value for dynamic orientation
                        //% "Dynamic"
                        text: qsTrId("harbour-books-settings-page-orientation-dynamic")
                        onClicked: orientation.value = 0
                    }
                    MenuItem {
                        //: Combo box value for portrait orientation
                        //% "Portrait"
                        text: qsTrId("harbour-books-settings-page-orientation-portrait")
                        onClicked: orientation.value = 1
                    }
                    MenuItem {
                        //: Combo box value for landscape orientation
                        //% "Landscape"
                        text: qsTrId("harbour-books-settings-page-orientation-landscape")
                        onClicked: orientation.value = 2
                    }
                }
                Component.onCompleted: orientation.updateControls()
                ConfigurationValue {
                    id: orientation
                    key: rootPath + "orientation"
                    defaultValue: 0
                    onValueChanged: updateControls()
                    function updateControls() {
                        var n = orientationMenu.children.length
                        var index = orientationMenu.defaultIndex
                        for (var i=0; i<n; i++) {
                            if (orientationMenu.children[i].value === value) {
                                index = i
                                break
                            }
                        }
                        orientationComboBox.currentIndex = index
                    }
                }
            }

            ComboBox {
                id: layoutComboBox
                //: Combo box label
                //% "Page layout"
                label: qsTrId("harbour-books-settings-page-page_layout")
                value: currentItem ? currentItem.valueText : ""
                menu: ContextMenu {
                    id: layoutMenu
                    readonly property int defaultIndex: 0
                    BooksDetailMenuItem {
                        //: Combo box value for dynamic page layout
                        //% "Dynamic"
                        valueText: qsTrId("harbour-books-settings-page-layout-dynamic")
                        //: Combo box detail for dynamic page layout
                        //% "(toggle on tap)"
                        detailText: qsTrId("harbour-books-settings-page-layout-dynamic-detail")
                        onClicked: pageDetailsFixed.value = false
                    }
                    BooksDetailMenuItem {
                        //: Combo box value for clean page layout (just the content)
                        //% "Clean"
                        valueText: qsTrId("harbour-books-settings-page-layout-clean")
                        //: Combo box detail for clean page layout (just the content)
                        //% "(just the content)"
                        detailText: qsTrId("harbour-books-settings-page-layout-clean-detail")
                        onClicked: {
                            pageDetailsFixed.value = true
                            pageDetails.value = 0
                        }
                    }
                    BooksDetailMenuItem {
                        //: Combo box value for minimal page layout (title + page)
                        //% "Minimal"
                        valueText: qsTrId("harbour-books-settings-page-layout-minimal")
                        //: Combo box detail for minimal page layout (title + page)
                        //% "(title, page)"
                        detailText: qsTrId("harbour-books-settings-page-layout-minimal-detail")
                        onClicked: {
                            pageDetailsFixed.value = true
                            pageDetails.value = 1
                        }
                    }
                    BooksDetailMenuItem {
                        //: Combo box value for normal page layout (title + page + slider)
                        //% "Regular"
                        valueText: qsTrId("harbour-books-settings-page-layout-normal")
                        //: Combo box detail for normal page layout (title + page + slider)
                        //% "(title, page, slider)"
                        detailText: qsTrId("harbour-books-settings-page-layout-normal-detail")
                        onClicked: {
                            pageDetailsFixed.value = true
                            pageDetails.value = 2
                        }
                    }
                    BooksDetailMenuItem {
                        //: Combo box value for full page layout (title + page + slider)
                        //% "Full"
                        valueText: qsTrId("harbour-books-settings-page-layout-full")
                        //: Combo box detail for full page layout (title + page + slider)
                        //% "(everything)"
                        detailText: qsTrId("harbour-books-settings-page-layout-full-detail")
                        onClicked: {
                            pageDetailsFixed.value = true
                            pageDetails.value = 3
                        }
                    }
                }
                Component.onCompleted: updateSelectedItem()
                function updateSelectedItem() {
                    currentIndex = pageDetailsFixed.value ? (pageDetails.value + 1) : 0
                }
                ConfigurationValue {
                    id: pageDetails
                    key: rootPath + "pageDetails"
                    defaultValue: 0
                    onValueChanged: layoutComboBox.updateSelectedItem()
                }
                ConfigurationValue {
                    id: pageDetailsFixed
                    key: rootPath + "pageDetailsFixed"
                    defaultValue: false
                    onValueChanged: layoutComboBox.updateSelectedItem()
                }
            }

            TextSwitch {
                automaticCheck: false
                checked: keepDisplayOn.value
                //: Text switch label
                //% "Keep display on while reading"
                text: qsTrId("harbour-books-settings-page-keep_display_on")
                //: Text switch description
                //% "Prevent the display from blanking while reading the book."
                description: qsTrId("harbour-books-settings-page-keep_display_on_description")
                onClicked: keepDisplayOn.value = !keepDisplayOn.value

                ConfigurationValue {
                    id: keepDisplayOn
                    key: rootPath + "keepDisplayOn"
                    defaultValue: false
                }
            }

            // =============== Navigation ===============

            SectionHeader {
                //: Section header for media keys
                //% "Navigation"
                text: qsTrId("harbour-books-settings-page-navigation-section_header")
            }

            BooksActionSelector {
                //: Combo box label
                //% "Volume up"
                label: qsTrId("harbour-books-settings-page-volume_up-label")
                key: rootPath + "volumeUpAction"
                defaultValue: 2 // BooksSettings.ActionNextPage
            }

            BooksActionSelector {
                //: Combo box label
                //% "Volume down"
                label: qsTrId("harbour-books-settings-page-volume_down-label")
                key: rootPath + "volumeDownAction"
                defaultValue: 1 // BooksSettings.ActionPreviousPage
            }

            TextSwitch {
                automaticCheck: false
                checked: turnPageByTap.value
                //: Text switch label
                //% "Turn pages by tapping the screen"
                text: qsTrId("harbour-books-settings-page-turn_pages_by_tap")
                //: Text switch description
                //% "Tapping near the left edge of the screen returns to the previous page, tapping near the right edge gets you to the next page."
                description: qsTrId("harbour-books-settings-page-turn_pages_by_tap-description")
                onClicked: turnPageByTap.value = !turnPageByTap.value

                ConfigurationValue {
                    id: turnPageByTap
                    key: rootPath + "turnPageByTap"
                    defaultValue: false
                }
            }

            // =============== Memory card ===============

            SectionHeader {
                //: Section header for memory card settings
                //% "Memory card"
                text: qsTrId("harbour-books-settings-page-removable-section_header")
            }

            TextField {
                id: removableRootField
                width: parent.width
                labelVisible: false

                Component.onCompleted: text = removableRoot.value
                onActiveFocusChanged: removableRoot.value = text
                EnterKey.onClicked: page.focus = true
                EnterKey.iconSource: "image://theme/icon-m-enter-close"

                ConfigurationValue {
                    id: removableRoot
                    key: rootPath + "removableRoot"
                    defaultValue: "Books"
                    onValueChanged: removableRootField.text = value
                }
            }

            Label {
                id: removableRootLabel
                //: Settings field label
                //% "Books folder"
                text: qsTrId("harbour-books-settings-page-removable_root-label")
                x: removableRootField.textLeftMargin
                width: removableRootField.width - removableRootField.textLeftMargin - removableRootField.textRightMargin
                height: text.length ? (implicitHeight + Theme.paddingMedium) : 0
                anchors {
                    topMargin: -Theme.paddingSmall
                    bottomMargin: Theme.paddingMedium
                }
                color: removableRootField.activeFocus ? Theme.highlightColor : Theme.primaryColor
                opacity: removableRootField.activeFocus ? 1.0 : 0.6
                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                //: Settings field description
                //% "Leave the folder name empty to scan the entire memory card for books."
                text: qsTrId("harbour-books-settings-page-removable_root-description")
                height: text.length ? (implicitHeight + Theme.paddingMedium) : 0
                width: removableRootLabel.width
                x: removableRootLabel.x
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                wrapMode: Text.Wrap
            }
        }
    }
}
