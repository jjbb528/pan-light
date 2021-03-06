import QtQuick 2.0
import "../comps"
import "../js/util.js" as Util
FixedWindow {
    title: '登录百度账号'
    id: root
    property bool success: false
    property var promise: null
    property bool cancel: false
    Rectangle {
        anchors.fill: parent
        Text {
            id: msg
            text: "请稍后"
            y: 10
            anchors.horizontalCenter: parent.horizontalCenter
            onLinkActivated: {
               Qt.openUrlExternally(link)
            }
            wrapMode: Text.WrapAnywhere
            width: parent.width * 0.8
        }
        Image {
            id: qrCode
            width: parent.width * 0.9
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.width * 0.05
            height: width
            source: ""
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                id: loading
                anchors.fill: parent
                color: Qt.rgba(1, 1, 1, .8)
                IconFont {
                    type: 'loading'
                    width: parent.width * 0.5
                    anchors.centerIn: parent
                }
            }
        }
    }

    onVisibleChanged: {
        if (!visible && !success && promise) {
            cancel = true
            Util.notifyPromise(promise, 'cancel')
        }
    }

    function start() {
        visible = true
        msg.text = '请稍后'
        msg.color = 'black'
        loading.visible = true
        promise = Util.callGoAsync('login.baidu', {}, true)
            .then(function(){
                success = true
                Util.event.fire('login.success', 'baidu')
            })
            .progress(function(data){
                if (data.type === 'qrCode') {
                    loading.visible = false
                    msg.text = '请使用百度旗下app扫码，或<a href="'+ data.pageUrl +'">点此</a>在浏览器中登录'
                    qrCode.source = data.img
                } else if (data.type === 'scan.ok') {
                    msg.text = '请点击确认完成授权'
                } else if (data.type === 'confirm') {
                    loading.visible = true
                    msg.text = '正在获取用户信息'
                }
            })
        return new Util.Promise(function(resolve, reject) {
            promise.then(resolve)
                .catch(function(err){
                    if (cancel) return reject('cancel')
                    msg.color = 'red'
                    msg.text = '登录出错'
                    Util.alert({parent: root, msg: err, title: '登录失败'})
                        .finally(function () {
                            reject(err)
                        })
                })
        })
    }
}
