@Entry
@Component
struct Settings {
  @State message: string = 'Hello World'

  @Builder
  NavigationTitle() {
    Text($r("app.string.about"))
      .fontColor('#182431')
      .fontSize(16)
      .textAlign(TextAlign.Center)
  }

  build() {
    Column() {
      Navigation() {
        Scroll() {
          Column() {
            Image($rawfile("logo.jpeg"))
              .width(200)
              .height(200)
              .borderRadius(32)
              .margin(32)

            Text($r("app.string.app_info"))
              .fontSize(14)
              .width("100%")
              .padding({
                left: 15,
                right: 15
              })
              .margin({
                bottom: 5
              })

            List() {
              ListItem() {
                Row() {
                  Text($r("app.string.app_name"))
                  Text($r("app.string.cyber_cashbook"))
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50dp")
              ListItem() {
                Row() {
                  Text($r("app.string.version"))
                  Text("1.0.0")
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50dp")
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

