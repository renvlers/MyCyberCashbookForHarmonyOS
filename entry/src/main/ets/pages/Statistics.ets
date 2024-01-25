import resourceManager from '@ohos.resourceManager'
import Bill from '../bill/Bill'

@Entry
@Component
struct Statistics {
  //用来配置CanvasRenderingContext2D对象和OffscreenCanvasRenderingContext2D对象的参数，包括是否开启抗锯齿。true表明开启抗锯齿
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private weeklyIncomeContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private weeklyExpenseContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private monthlyIncomeContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private monthlyExpenseContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private yearlyIncomeContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private yearlyExpenseContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State message: string = 'Hello World'
  @State weeklyTotal: number = 0
  @State monthlyTotal: number = 0
  @State yearlyTotal: number = 0
  @State weeklyIncomeProportion: number[] = []
  @State weeklyExpenseProportion: number[] = []
  @State monthlyIncomeProportion: number[] = []
  @State monthlyExpenseProportion: number[] = []
  @State yearlyIncomeProportion: number[] = []
  @State yearlyExpenseProportion: number[] = []
  date: Date = new Date(Date.now())
  resMgr: resourceManager.ResourceManager = getContext(this).resourceManager;
  @State incomeStrings: string[] = []
  @State expenseStrings: string[] = []

  calculateTotal(bills: Bill[]): number {
    let sum = 0;

    for (let i of bills) {
      if (i.type === Bill.TYPE_INCOME)
        sum += i.amount;
      else
        sum -= i.amount;
    }

    return sum;
  }

  calculateProportion(bills: Bill[]): {
    incomePortion: number[],
    expensePortion: number[]
  } {
    let income: number[] = [];
    for (let i = Bill.CATEGORY_INCOME_SALARY; i <= Bill.CATEGORY_INCOME_OTHER_INCOME; i++) {
      income.push(0);
    }

    for (let i of bills) {
      if (i.type === Bill.TYPE_INCOME)
        income[i.category - 1] += i.amount;
    }

    let incomeLength = 0;
    income.forEach((val) => {
      incomeLength += val
    });
    if (incomeLength !== 0)
      income = income.map((val) => val / incomeLength);

    let expense: number[] = [];
    for (let i = Bill.CATEGORY_EXPENSE_CLOTHES; i <= Bill.CATEGORY_EXPENSE_OTHER_EXPENSES; i++) {
      expense.push(0);
    }

    for (let i of bills) {
      if (i.type === Bill.TYPE_EXPENSE)
        expense[i.category - 7] += i.amount;
    }

    let expenseLength = 0;
    expense.forEach((val) => {
      expenseLength += val
    });
    if (expenseLength !== 0)
      expense = expense.map((val) => val / expenseLength);

    return { incomePortion: income, expensePortion: expense }
  }

  async aboutToAppear() {
    const weeklyBill: Bill[] = await Bill.queryByWeek(this.date);
    this.weeklyTotal = this.calculateTotal(weeklyBill);
    const {
      incomePortion: weeklyIncomePortion,
      expensePortion: weeklyExpensePortion
    } = this.calculateProportion(weeklyBill);
    this.weeklyIncomeProportion = weeklyIncomePortion;
    this.weeklyExpenseProportion = weeklyExpensePortion;

    const monthlyBill: Bill[] = await Bill.queryByMonth(this.date);
    this.monthlyTotal = this.calculateTotal(monthlyBill);
    const {
      incomePortion: monthlyIncomePortion,
      expensePortion: monthlyExpensePortion
    } = this.calculateProportion(monthlyBill);
    this.monthlyIncomeProportion = monthlyIncomePortion;
    this.monthlyExpenseProportion = monthlyExpensePortion;

    const yearlyBill: Bill[] = await Bill.queryByYear(this.date);
    this.yearlyTotal = this.calculateTotal(yearlyBill);
    const {
      incomePortion: yearlyIncomePortion,
      expensePortion: yearlyExpensePortion
    } = this.calculateProportion(yearlyBill);
    this.yearlyIncomeProportion = yearlyIncomePortion;
    this.yearlyExpenseProportion = yearlyExpensePortion;

    this.incomeStrings = await this.resMgr.getStringArrayValue($r("app.strarray.income_category"));
    this.expenseStrings = await this.resMgr.getStringArrayValue($r("app.strarray.expense_category"))
  }

  @Builder
  NavigationTitle() {
    Text($r("app.string.statistics"))
      .fontColor('#182431')
      .fontSize(16)
      .textAlign(TextAlign.Center)
  }

  build() {
    Column() {
      Navigation() {
        Scroll() {
          Column() {

            Text($r("app.string.weekly_statistics"))
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
                  Text($r("app.string.weekly_profit_and_loss"))
                  Text(this.weeklyTotal > 0 ? "+￥" + this.weeklyTotal.toFixed(2) : (this.weeklyTotal < 0 ? "-￥" + (-this.weeklyTotal).toFixed(2) : "￥0.00"))
                    .fontColor(this.weeklyTotal > 0 ? Color.Red : (this.weeklyTotal < 0 ? Color.Green : Color.Blue))
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50dp")

              ListItem() {
                Column() {
                  Text($r("app.string.weekly_income_proportion"))
                    .margin({ top: 15, bottom: 15 })
                  Canvas(this.weeklyIncomeContext)
                    .width("auto")
                    .height(240)
                    .backgroundColor("#ffffff")
                    .onReady(() => {
                      setTimeout(() => {
                        let lastArc = 0;
                        let offset = 0;
                        this.weeklyIncomeProportion.forEach((val, idx) => {
                          if (val !== 0) {
                            this.weeklyIncomeContext.fillStyle = Bill.getColor(idx + 1);

                            this.weeklyIncomeContext.beginPath();
                            this.weeklyIncomeContext.arc(100, 120, 100, lastArc, lastArc + 2 * Math.PI * val);
                            this.weeklyIncomeContext.lineTo(100, 120);
                            this.weeklyIncomeContext.fill();
                            this.weeklyIncomeContext.closePath();

                            this.weeklyIncomeContext.beginPath();
                            this.weeklyIncomeContext.rect(220, 20 + (16 * offset), 10, 10);
                            this.weeklyIncomeContext.fill();
                            this.weeklyIncomeContext.closePath();

                            this.weeklyIncomeContext.fillStyle = "#000000";
                            this.weeklyIncomeContext.font = '32px sans-serif';
                            this.weeklyIncomeContext.fillText(
                              this.incomeStrings[idx + 1],
                              235,
                              29.5 + (16 * offset)
                            );

                            lastArc += 2 * Math.PI * val;
                            offset++;
                          }
                        })
                      }, 500)
                    })
                    .margin({ bottom: 15 })
                }
                .width("100%")
                .alignItems(HorizontalAlign.Start)
              }
              .width("auto")
              .height("auto")

              ListItem() {
                Column() {
                  Text($r("app.string.weekly_expense_proportion"))
                    .margin({ top: 15, bottom: 15 })
                  Canvas(this.weeklyExpenseContext)
                    .width("auto")
                    .height(240)
                    .backgroundColor("#ffffff")
                    .onReady(() => {
                      setTimeout(() => {
                        let lastArc = 0;
                        let offset = 0;
                        this.weeklyExpenseProportion.forEach((val, idx) => {
                          if (val !== 0) {
                            this.weeklyExpenseContext.fillStyle = Bill.getColor(idx + 7);

                            this.weeklyExpenseContext.beginPath();
                            this.weeklyExpenseContext.arc(100, 120, 100, lastArc, lastArc + 2 * Math.PI * val);
                            this.weeklyExpenseContext.lineTo(100, 120);
                            this.weeklyExpenseContext.fill();
                            this.weeklyExpenseContext.closePath();

                            this.weeklyExpenseContext.beginPath();
                            this.weeklyExpenseContext.rect(220, 20 + (16 * offset), 10, 10);
                            this.weeklyExpenseContext.fill();
                            this.weeklyExpenseContext.closePath();

                            this.weeklyExpenseContext.fillStyle = "#000000";
                            this.weeklyExpenseContext.font = '32px sans-serif';
                            this.weeklyExpenseContext.fillText(
                              this.expenseStrings[idx + 1],
                              235,
                              29.5 + (16 * offset)
                            );

                            lastArc += 2 * Math.PI * val;
                            offset++;
                          }
                        })
                      }, 500)
                    })
                    .margin({ bottom: 15 })
                }
                .width("100%")
                .alignItems(HorizontalAlign.Start)
              }
              .width("auto")
              .height("auto")
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

            Text($r("app.string.monthly_statistics"))
              .fontSize(14)
              .width("100%")
              .padding({
                left: 15,
                right: 15
              })
              .margin({
                bottom: 5,
                top: 15
              })

            List() {
              ListItem() {
                Row() {
                  Text($r("app.string.monthly_profit_and_loss"))
                  Text(this.monthlyTotal > 0 ? "+￥" + this.monthlyTotal.toFixed(2) : (this.monthlyTotal < 0 ? "-￥" + (-this.monthlyTotal).toFixed(2) : "￥0.00"))
                    .fontColor(this.monthlyTotal > 0 ? Color.Red : (this.monthlyTotal < 0 ? Color.Green : Color.Blue))
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50dp")

              ListItem() {
                Column() {
                  Text($r("app.string.monthly_income_proportion"))
                    .margin({ top: 15, bottom: 15 })
                  Canvas(this.monthlyIncomeContext)
                    .width("auto")
                    .height(240)
                    .backgroundColor("#ffffff")
                    .onReady(() => {
                      setTimeout(() => {
                        let lastArc = 0;
                        let offset = 0;
                        this.monthlyIncomeProportion.forEach((val, idx) => {
                          if (val !== 0) {
                            this.monthlyIncomeContext.fillStyle = Bill.getColor(idx + 1);

                            this.monthlyIncomeContext.beginPath();
                            this.monthlyIncomeContext.arc(100, 120, 100, lastArc, lastArc + 2 * Math.PI * val);
                            this.monthlyIncomeContext.lineTo(100, 120);
                            this.monthlyIncomeContext.fill();
                            this.monthlyIncomeContext.closePath();

                            this.monthlyIncomeContext.beginPath();
                            this.monthlyIncomeContext.rect(220, 20 + (16 * offset), 10, 10);
                            this.monthlyIncomeContext.fill();
                            this.monthlyIncomeContext.closePath();

                            this.monthlyIncomeContext.fillStyle = "#000000";
                            this.monthlyIncomeContext.font = '32px sans-serif';
                            this.monthlyIncomeContext.fillText(
                              this.incomeStrings[idx + 1],
                              235,
                              29.5 + (16 * offset)
                            );

                            lastArc += 2 * Math.PI * val;
                            offset++;
                          }
                        })
                      }, 500)
                    })
                    .margin({ bottom: 15 })
                }
                .width("100%")
                .alignItems(HorizontalAlign.Start)
              }
              .width("auto")
              .height("auto")

              ListItem() {
                Column() {
                  Text($r("app.string.monthly_expense_proportion"))
                    .margin({ top: 15, bottom: 15 })
                  Canvas(this.monthlyExpenseContext)
                    .width("auto")
                    .height(240)
                    .backgroundColor("#ffffff")
                    .onReady(() => {
                      setTimeout(() => {
                        let lastArc = 0;
                        let offset = 0;
                        this.monthlyExpenseProportion.forEach((val, idx) => {
                          if (val !== 0) {
                            this.monthlyExpenseContext.fillStyle = Bill.getColor(idx + 7);

                            this.monthlyExpenseContext.beginPath();
                            this.monthlyExpenseContext.arc(100, 120, 100, lastArc, lastArc + 2 * Math.PI * val);
                            this.monthlyExpenseContext.lineTo(100, 120);
                            this.monthlyExpenseContext.fill();
                            this.monthlyExpenseContext.closePath();

                            this.monthlyExpenseContext.beginPath();
                            this.monthlyExpenseContext.rect(220, 20 + (16 * offset), 10, 10);
                            this.monthlyExpenseContext.fill();
                            this.monthlyExpenseContext.closePath();

                            this.monthlyExpenseContext.fillStyle = "#000000";
                            this.monthlyExpenseContext.font = '32px sans-serif';
                            this.monthlyExpenseContext.fillText(
                              this.expenseStrings[idx + 1],
                              235,
                              29.5 + (16 * offset)
                            );

                            lastArc += 2 * Math.PI * val;
                            offset++;
                          }
                        })
                      }, 500)
                    })
                    .margin({ bottom: 15 })
                }
                .width("100%")
                .alignItems(HorizontalAlign.Start)
              }
              .width("auto")
              .height("auto")
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

            Text($r("app.string.yearly_statistics"))
              .fontSize(14)
              .width("100%")
              .padding({
                left: 15,
                right: 15
              })
              .margin({
                bottom: 5,
                top: 15
              })

            List() {
              ListItem() {
                Row() {
                  Text($r("app.string.yearly_profit_and_loss"))
                  Text(this.yearlyTotal > 0 ? "+￥" + this.yearlyTotal.toFixed(2) : (this.yearlyTotal < 0 ? "-￥" + (-this.yearlyTotal).toFixed(2) : "￥0.00"))
                    .fontColor(this.yearlyTotal > 0 ? Color.Red : (this.yearlyTotal < 0 ? Color.Green : Color.Blue))
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width("auto")
              .height("50dp")

              ListItem() {
                Column() {
                  Text($r("app.string.yearly_income_proportion"))
                    .margin({ top: 15, bottom: 15 })
                  Canvas(this.yearlyIncomeContext)
                    .width("auto")
                    .height(240)
                    .backgroundColor("#ffffff")
                    .onReady(() => {
                      setTimeout(() => {
                        let lastArc = 0;
                        let offset = 0;
                        this.yearlyIncomeProportion.forEach((val, idx) => {
                          if (val !== 0) {
                            this.yearlyIncomeContext.fillStyle = Bill.getColor(idx + 1);

                            this.yearlyIncomeContext.beginPath();
                            this.yearlyIncomeContext.arc(100, 120, 100, lastArc, lastArc + 2 * Math.PI * val);
                            this.yearlyIncomeContext.lineTo(100, 120);
                            this.yearlyIncomeContext.fill();
                            this.yearlyIncomeContext.closePath();

                            this.yearlyIncomeContext.beginPath();
                            this.yearlyIncomeContext.rect(220, 20 + (16 * offset), 10, 10);
                            this.yearlyIncomeContext.fill();
                            this.yearlyIncomeContext.closePath();

                            this.yearlyIncomeContext.fillStyle = "#000000";
                            this.yearlyIncomeContext.font = '32px sans-serif';
                            this.yearlyIncomeContext.fillText(
                              this.incomeStrings[idx + 1],
                              235,
                              29.5 + (16 * offset)
                            );

                            lastArc += 2 * Math.PI * val;
                            offset++;
                          }
                        })
                      }, 500)
                    })
                    .margin({ bottom: 15 })
                }
                .width("100%")
                .alignItems(HorizontalAlign.Start)
              }
              .width("auto")
              .height("auto")

              ListItem() {
                Column() {
                  Text($r("app.string.yearly_expense_proportion"))
                    .margin({ top: 15, bottom: 15 })
                  Canvas(this.yearlyExpenseContext)
                    .width("auto")
                    .height(240)
                    .backgroundColor("#ffffff")
                    .onReady(() => {
                      setTimeout(() => {
                        let lastArc = 0;
                        let offset = 0;
                        this.yearlyExpenseProportion.forEach((val, idx) => {
                          if (val !== 0) {
                            this.yearlyExpenseContext.fillStyle = Bill.getColor(idx + 7);

                            this.yearlyExpenseContext.beginPath();
                            this.yearlyExpenseContext.arc(100, 120, 100, lastArc, lastArc + 2 * Math.PI * val);
                            this.yearlyExpenseContext.lineTo(100, 120);
                            this.yearlyExpenseContext.fill();
                            this.yearlyExpenseContext.closePath();

                            this.yearlyExpenseContext.beginPath();
                            this.yearlyExpenseContext.rect(220, 20 + (16 * offset), 10, 10);
                            this.yearlyExpenseContext.fill();
                            this.yearlyExpenseContext.closePath();

                            this.yearlyExpenseContext.fillStyle = "#000000";
                            this.yearlyExpenseContext.font = '32px sans-serif';
                            this.yearlyExpenseContext.fillText(
                              this.expenseStrings[idx + 1],
                              235,
                              29.5 + (16 * offset)
                            );

                            lastArc += 2 * Math.PI * val;
                            offset++;
                          }
                        })
                      }, 500)
                    })
                    .margin({ bottom: 15 })
                }
                .width("100%")
                .alignItems(HorizontalAlign.Start)
              }
              .width("auto")
              .height("auto")
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

