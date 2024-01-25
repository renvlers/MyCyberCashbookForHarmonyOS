import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import Bill from "../bill/Bill"

@Entry
@Component
struct Index {
  selectedDate: Date = new Date(Date.now());

  @State bills: Array<Bill> = []
  @State currentDate: string = Bill.formatDate(this.selectedDate)
  @State monthlyBills: Array<Bill> = []
  @State dailyTotal: number = 0
  @State monthlyTotal: number = 0

  async updatePageInfo() {
    this.bills = await Bill.queryByDay(this.selectedDate);
    this.dailyTotal = 0;
    for(let i of this.bills) {
      if(i.category <= 6)
        this.dailyTotal += i.amount;
      else
        this.dailyTotal -= i.amount;
    }

    this.monthlyBills = await Bill.queryByMonth(this.selectedDate);
    this.monthlyTotal = 0;
    for(let i of this.monthlyBills) {
      if(i.category <= 6)
        this.monthlyTotal += i.amount;
      else
        this.monthlyTotal -= i.amount;
    }
  }

  onPageShow() {
    this.updatePageInfo();
  }

  // async aboutToAppear(){
  //   console.error("aboutToAppear()");
  //   this.bills = await Bill.queryAll(this.selectedDate);
  //   console.error(JSON.stringify(this.bills));
  // }

  @Builder
  itemEnd(item: Bill) {
    // 侧滑后尾端出现的组件
    Row() {
      Button($r("app.string.edit"), { type: ButtonType.Normal })
        .width("78vp")
        .height("100%")
        .backgroundColor(0x5A5AFF)
        .onClick(() => {
          router.pushUrl({
            url: "pages/EditBill",
            params: {
              id: item.id,
              type: item.type,
              category: item.category,
              time: item.time,
              amount: item.amount,
              usage: item.usage
            }
          })
        })
      Button($r("app.string.delete"), { type: ButtonType.Normal })
        .width("78vp")
        .height("100%")
        .backgroundColor(0xFF5A5A)
        .onClick(() => {
          promptAction.showDialog({
            title: $r("app.string.delete_ask"),
            message: $r("app.string.delete_warning"),
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
            if(data.index == 1) {
              console.info("You've pressed the OK button");
              item.deleteFromDb();
              setTimeout(() => {
                promptAction.showToast({
                  message: $r("app.string.successfully_deleted"),
                  duration: 1000
                });
                this.updatePageInfo();
              }, 1000);
            }
          })
        })
    }
    .height("100%")
  }

  build() {
    Column() {
      RelativeContainer() {
        Text($r("app.string.my_cashbook"))
          .fontColor(Color.White)
          .fontSize("28vp")
          .alignRules({
            top: { anchor: "__container__", align: VerticalAlign.Top },
            left: { anchor: "__container__", align: HorizontalAlign.Start }
          })
          .id("title-bar")
          .margin({
            left: "15vp",
            top: "15vp"
          })
        Row() {
          Button({ type: ButtonType.Normal }) {
            Image($rawfile("calendar.svg"))
              .height("100%")
              .width("100%")
          }
          .height("28vp")
          .width("28vp")
          .backgroundColor(Color.Transparent)
          .borderRadius("6vp")
          .margin({ right: "8vp" })
          .onClick(() => {
            try{
              DatePickerDialog.show({
                start: new Date("2000-01-01"),
                end: new Date(Date.now()),
                selected: this.selectedDate,
                onAccept: (value: DatePickerResult) => {
                  this.selectedDate.setFullYear(value.year, value.month, value.day)
                  this.currentDate = Bill.formatDate(this.selectedDate);
                  this.updatePageInfo();
                },
                onCancel: () => {
                  console.info("DatePickerDialog:onCancel()")
                }
              })
            } catch (e) {
              console.error("Failed to open DatePickerDialog");
            }
          })

          Button({ type: ButtonType.Normal }) {
            Image($rawfile("statistics.svg"))
              .height("100%")
              .width("100%")
          }
          .height("28vp")
          .width("28vp")
          .backgroundColor(Color.Transparent)
          .borderRadius("6vp")
          .margin({ right: "8vp" })
          .onClick(() => {router.pushUrl({url: "pages/Statistics"})})

          Button({ type: ButtonType.Normal }) {
            Image($rawfile("settings.svg"))
              .height("100%")
              .width("100%")
          }
          .height("28vp")
          .width("28vp")
          .backgroundColor(Color.Transparent)
          .borderRadius("6vp")
          .margin({ right: "8vp" })
          .onClick(() => {router.pushUrl({url: "pages/Settings"})})

          Button({ type: ButtonType.Normal }) {
            Image($rawfile("new.svg"))
              .height("100%")
              .width("100%")
          }
          .height("28vp")
          .width("28vp")
          .backgroundColor(Color.Transparent)
          .borderRadius("6vp")
          .onClick(() => {router.pushUrl({url: "pages/NewBill"})})
        }
        .height("28vp")
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        })
        .margin({
          top: "15vp",
          right: "15vp"
        })
        .id("top-buttons")

        Column() {
          Text(this.currentDate)
            .fontColor(Color.White)
            .fontSize("16vp")
            .margin({ bottom: "8vp" })
          Row() {
            Text($r("app.string.monthly_total_amount"))
              .fontColor(Color.White)
              .fontSize("22vp")
              .margin({ bottom: "8vp" })
            Text(this.monthlyTotal > 0 ? "+￥" + this.monthlyTotal.toFixed(2) : (this.monthlyTotal < 0 ? "-￥" + (-this.monthlyTotal).toFixed(2) : "￥0.00"))
              .fontColor(Color.White)
              .fontSize("22vp")
              .margin({ bottom: "8vp" })
          }

          Row() {
            Text($r("app.string.daily_total_amount"))
              .fontColor(Color.White)
              .fontSize("22vp")
            Text(this.dailyTotal > 0 ? "+￥" + this.dailyTotal.toFixed(2) : (this.dailyTotal < 0 ? "-￥" + (-this.dailyTotal).toFixed(2) : "￥0.00"))
              .fontColor(Color.White)
              .fontSize("22vp")
          }
        }
        .alignRules({
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })
        .margin({
          bottom: "15vp",
          left: "15vp"
        })
        .id("date-and-total")
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)

      }
      .width("100%")
      .height("225vp")
      .backgroundImage($rawfile("title-bar.jpg"))
      .backgroundImageSize(ImageSize.Cover)
      .backgroundImagePosition(Alignment.Center)
      .borderRadius(15)

      Scroll() {
        Column() {
          List() {
            ForEach(this.bills, (item: Bill) => {
              ListItem() {
                RelativeContainer() {
                  Image(Bill.getIcon(item.category))
                    .width("48vp")
                    .height("48vp")
                    .backgroundColor(Bill.getColor(item.category))
                    .alignRules({
                      top: { anchor: "__container__", align: VerticalAlign.Top },
                      left: { anchor: "__container__", align: HorizontalAlign.Start }
                    })
                    .id("category-icon")
                    .margin({
                      top: "15vp",
                      left: "15vp"
                    })
                    .padding("10vp")
                    .borderRadius("10vp")
                  Text(item.usage)
                    .fontSize("22vp")
                    .alignRules({
                      left: { anchor: "category-icon", align: HorizontalAlign.End }
                    })
                    .margin({
                      top: "15vp",
                      left: "10vp"
                    })
                    .id("category-text")
                  Text(item.getCategory())
                    .fontSize("14vp")
                    .alignRules({
                      left: { anchor: "category-icon", align: HorizontalAlign.End },
                      bottom: { anchor: "category-icon", align: VerticalAlign.Bottom }
                    })
                    .margin({
                      left: "10vp"
                    })
                    .id("date-time")
                  Text((item.type ? "-￥" : "+￥") + item.amount.toFixed(2))
                    .fontSize("20vp")
                    .alignRules({
                      bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
                      right: { anchor: "__container__", align: HorizontalAlign.End }
                    })
                    .margin({
                      bottom: "15vp",
                      right: "15vp"
                    })
                    .fontColor(item.type ? Color.Green : Color.Red)
                    .id("money")
                }
                .width("100%")
                .height("78vp")
              }
              .swipeAction({ end: this.itemEnd.bind(this, item) }) // 设置侧滑属性
            })
          }
          .backgroundColor(Color.White)
          .width("100%")
          .height("100%")
          .divider({
            strokeWidth: 1,
            startMargin: 73,
            endMargin: 15,
            color: '#ffe9f0f0'
          })
        }

      }
      .layoutWeight(1)
      .width("100%")
      .borderRadius(15)
      .margin({
        top: 15,
      })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .width("100%")
    .height("100%")
    .margin("0vp")
    .padding(15)
    .backgroundColor("#ececec")
  }
}