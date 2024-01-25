import i18n from '@ohos.i18n'
import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import Bill from '../bill/Bill'

@Entry
@Component
struct Settings {
  @State message: string = 'Hello World'

  @Builder
  NavigationTitle() {
    Text($r("app.string.settings"))
      .fontColor('#182431')
      .fontSize(16)
      .textAlign(TextAlign.Center)
  }

  build() {
    Column() {
      Navigation() {
        Scroll() {
          Column() {
            List() {
              ListItem() {
                Row() {
                  Text($r("app.string.language"))
                  Row() {
                    Text(i18n.System.getDisplayLanguage(i18n.System.getSystemLanguage(), i18n.System.getSystemLanguage()))
                  }
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50dp")

              ListItem() {
                Row() {
                  Text($r("app.string.about"))
                }
                .width("100%")
                .justifyContent(FlexAlign.Start)
              }
              .width("auto")
              .height("50dp")
              .onClick(() => {
                router.pushUrl({
                  url: "pages/About"
                })
              })
            }
            .backgroundColor(Color.White)
            .borderRadius(15)
            .padding({
              left: 15,
              right: 15
            })
            .alignSelf(ItemAlign.Center)
            .divider({
              strokeWidth: 1,
              startMargin: 0,
              endMargin: 0,
              color: '#ffe9f0f0'
            })

            Text($r("app.string.language_changing_tip"))
              .fontSize(14)
              .width("100%")
              .padding({
                left: 15,
                right: 15
              })
              .margin({
                top: 5
              })

            Button($r("app.string.clear_all_data"), { type: ButtonType.Normal })
              .borderRadius(15)
              .height("50vp")
              .alignSelf(ItemAlign.Start)
              .width("100%")
              .backgroundColor(Color.Red)
              .margin({
                top: 15
              })
              .onClick(() => {
                promptAction.showDialog({
                  title: $r("app.string.clear_warning"),
                  message: $r("app.string.clear_ask"),
                  buttons: [
                    {
                      text: $r("app.string.cancel"),
                      color: '#0000FF'
                    },
                    {
                      text: $r("app.string.ok"),
                      color: '#FF0000'
                    }
                  ]
                }, (err, data) => {
                  if (err) {
                    console.info('showDialog err: ' + err);
                    return;
                  }
                  console.info('showDialog success callback, click button: ' + data.index);
                  if (data.index == 1) {
                    console.info("You've pressed the OK button");
                    Bill.deleteAll();
                    setTimeout(() => {
                      promptAction.showToast({
                        message: $r("app.string.successfully_cleared"),
                        duration: 1000
                      });
                    }, 1000);
                  }
                })
              })
          }
        }
        .width("100%")
        .height("auto")
        .margin(0)
        .padding({
          left: 15,
          right: 15
        })
      }
      .title(this.NavigationTitle())
      .titleMode(NavigationTitleMode.Mini)
      .mode(NavigationMode.Stack)
      .backgroundColor("#ececec")
    }
    .width("100%")
    .height("100%")
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}

