import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import Bill from "../bill/Bill"

@Entry
@Component
struct NewBill {
  date: Date = new Date(Date.now());

  @State type: boolean = false;
  @State category: number = 0;
  @State amount: number = 0;
  @State usage: string = "";
  @State amountTextValue: string = "";
  @State dateString: string = Bill.formatDate(this.date);

  @State usageTemp: string = ""

  amountController: CustomDialogController = new CustomDialogController({
    builder: AmountDialog({
      textValue: this.amountTextValue,
      confirm: () => {
        if(Number.isNaN(Number.parseFloat(this.amountTextValue))) {
          promptAction.showToast({
            message: $r("app.string.invalid_input"),
            duration: 1000
          })
          return;
        }
        this.amount = Number.parseFloat(this.amountTextValue);
        this.amountTextValue = "";
        this.amountController.close();
      },
      cancel: () => {
        this.amountTextValue = "";
      }
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: false,
  })

  usageController: CustomDialogController = new CustomDialogController({
    builder: UsageDialog({
      textValue: this.usageTemp,
      confirm: () => {
        if (this.usageTemp.trim() == "") {
          promptAction.showToast({
            message: $r("app.string.usage_cannot_be_empty"),
            duration: 1000
          })
          return;
        }
        this.usage = this.usageTemp;
        this.usageTemp = "";
        this.usageController.close();
      },
      cancel: () => {
        this.usageTemp = "";
      }
    }),
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: false,
  })

  aboutToAppear() {
  }

  createNewBill() {
    if(this.category == 0) {
      promptAction.showToast({
        message: $r("app.string.category_not_selected"),
        duration: 1000
      });
      return;
    }
    else if(this.amount == 0) {
      promptAction.showToast({
        message: $r("app.string.invalid_input"),
        duration: 1000
      });
      return;
    }
    else if(this.usage.trim() == "") {
      promptAction.showToast({
        message: $r("app.string.usage_cannot_be_empty"),
        duration: 1000
      });
      return;
    }
    else {
      let bill = new Bill(
        0,
        this.type,
        this.category,
        this.date,
        this.amount,
        this.usage
      );

      bill.saveToDb();
      promptAction.showToast({
        message: $r("app.string.successfully_created"),
        duration: 1000
      });
      setTimeout(() => {router.back()}, 1000);
    }
  }

  @Builder
  NavigationTitle() {
    Text($r("app.string.new_bill"))
      .fontColor('#182431')
      .fontSize(16)
      .textAlign(TextAlign.Center)
  }

  build() {
    Column() {
      Navigation() {
        Scroll() {
          Column() {

            Text($r("app.string.bill_info"))
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
                  Text($r("app.string.income_or_expense"))
                  Row() {
                    Radio({group: "income_or_expense", value: "income"}).checked(!this.type)
                      .onChange((val: boolean) => {
                        if(val) {
                          this.type = Bill.TYPE_INCOME;
                        }
                        this.category = 0;
                      })
                    Text($r("app.string.income")).margin({right:5})
                    Radio({group: "income_or_expense", value: "expense"}).checked(this.type)
                      .onChange((val: boolean) => {
                        if(val) {
                          this.type = Bill.TYPE_EXPENSE;
                        }
                        this.category = 0;
                      })
                    Text($r("app.string.expense"))
                  }
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50dp")
              ListItem() {
                Row() {
                  Text($r("app.string.category"))
                  Row() {
                    Text(Bill.getCategory(this.category))
                  }
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50dp")
              .onClick(() => {
                TextPickerDialog.show({
                  range: this.type == Bill.TYPE_INCOME ? $r("app.strarray.income_category") : $r("app.strarray.expense_category"),
                  selected: this.type === Bill.TYPE_EXPENSE && this.category !== 0 ? this.category - 6 : this.category,
                  onAccept: (val) => {
                    if(this.type == Bill.TYPE_EXPENSE && val.index != 0) {
                      this.category = val.index as number + 6;
                    }
                    else {
                      this.category = val.index as number;
                    }
                  }
                })
              })
              ListItem() {
                Row() {
                  Text($r("app.string.date"))
                  Row() {
                    Text(this.dateString)
                  }
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50dp")
              .onClick(() => {
                DatePickerDialog.show({
                  start: new Date("2000-01-01"),
                  end: new Date(Date.now()),
                  selected: this.date,
                  onAccept: (val) => {
                    this.date.setFullYear(val.year, val.month, val.day);
                    this.dateString = Bill.formatDate(this.date);
                  }
                })
              })
              ListItem() {
                Row() {
                  Text($r("app.string.amount"))
                  Row() {
                    Text("￥" + this.amount.toFixed(2))
                  }
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50dp")
              .onClick(() => {
                this.amountController.open();
              })
              ListItem() {
                Row() {
                  Text($r("app.string.usage"))
                  Row() {
                    Text(this.usage)
                  }
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50vp")
              .onClick(() => {
                this.usageController.open();
              })
            }
            .backgroundColor(Color.White)
            .borderRadius(15)
            .margin({
              bottom: 15
            })
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

            Button($r("app.string.save"), {type: ButtonType.Normal})
              .borderRadius(15)
              .height("50vp")
              .alignSelf(ItemAlign.Start)
              .width("100%")
              .onClick(() => {
                this.createNewBill();
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

  aboutToDisappear() {
    delete this.amountController; // 删除dialogController
    this.amountController = null; // 将dialogController置空
    delete this.usageController; // 删除dialogController
    this.usageController = null; // 将dialogController置空
  }
}

@CustomDialog
struct AmountDialog {
  @Link textValue: string
  controller: CustomDialogController
  // 若尝试在CustomDialog中传入多个其他的Controller，以实现在CustomDialog中打开另一个或另一些CustomDialog，那么此处需要将指向自己的controller放在最后
  confirm: Function
  cancel: Function

  build() {
    Column() {
      Text($r("app.string.amount")).fontSize(20).margin({ top: 10, bottom: 10 })
      TextInput({ placeholder: '', text: this.textValue }).height(48).width('90%')
        .onChange((value: string) => {
          this.textValue = value
        })
        .borderRadius(15)
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button($r("app.string.cancel"))
          .borderRadius(15)
          .onClick(() => {
            this.cancel();
            this.controller.close()
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button($r("app.string.ok"))
          .borderRadius(15)
          .onClick(() => {
            this.confirm()
          }).backgroundColor(0xffffff).fontColor(Color.Red)
      }.margin({ bottom: 10 })
    }
    // dialog默认的borderRadius为24vp，如果需要使用border属性，请和borderRadius属性一起使用。
  }
}

@CustomDialog
struct UsageDialog {
  @Link textValue: string
  controller: CustomDialogController
  // 若尝试在CustomDialog中传入多个其他的Controller，以实现在CustomDialog中打开另一个或另一些CustomDialog，那么此处需要将指向自己的controller放在最后
  confirm: () => void
  cancel: Function

  build() {
    Column() {
      Text($r("app.string.usage")).fontSize(20).margin({ top: 10, bottom: 10 })
      TextInput({ placeholder: '', text: this.textValue }).height(48).width('90%')
        .onChange((value: string) => {
          this.textValue = value
        })
        .borderRadius(15)
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button($r("app.string.cancel"))
          .onClick(() => {
            this.cancel();
            this.controller.close()
          }).backgroundColor(0xffffff).fontColor(Color.Black)
        Button($r("app.string.ok"))
          .borderRadius(15)
          .onClick(() => {
            this.confirm()
          }).backgroundColor(0xffffff).fontColor(Color.Red)
      }.margin({ bottom: 10 })
    }
    // dialog默认的borderRadius为24vp，如果需要使用border属性，请和borderRadius属性一起使用。
  }
}



