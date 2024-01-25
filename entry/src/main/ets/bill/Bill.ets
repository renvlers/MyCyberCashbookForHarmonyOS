import relationalStore from '@ohos.data.relationalStore'

export default class Bill {
  static TYPE_INCOME: boolean = false;
  static TYPE_EXPENSE: boolean = true;
  static CATEGORY_INCOME_SALARY: number = 1;
  static CATEGORY_INCOME_PARTTIME_INCOME: number = 2;
  static CATEGORY_INCOME_INVESTMENT_EARNINGS: number = 3;
  static CATEGORY_INCOME_BUSINESS_INCOME: number = 4;
  static CATEGORY_INCOME_GIFTS: number = 5;
  static CATEGORY_INCOME_OTHER_INCOME: number = 6;
  static CATEGORY_EXPENSE_CLOTHES: number = 7;
  static CATEGORY_EXPENSE_FOOD: number = 8;
  static CATEGORY_EXPENSE_HOUSING: number = 9;
  static CATEGORY_EXPENSE_TRANSPORTATION: number = 10;
  static CATEGORY_EXPENSE_HEALTH: number = 11;
  static CATEGORY_EXPENSE_ENTERTAINMENT: number = 12;
  static CATEGORY_EXPENSE_EDUCATION: number = 13;
  static CATEGORY_EXPENSE_DEBT_REPAYMENT: number = 14;
  static CATEGORY_EXPENSE_INVESTMENTS: number = 15;
  static CATEGORY_EXPENSE_INSURANCE: number = 16;
  static CATEGORY_EXPENSE_CHARITABLE_DONATIONS: number = 17;
  static CATEGORY_EXPENSE_OTHER_EXPENSES: number = 18;
  static STORE_CONFIG = {
    name: 'MyCashbook', // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全级别
  };
  static rdb: relationalStore.RdbStore;

  static formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0'); //月份从0开始，所以要加1
    const day = date.getDate().toString().padStart(2, '0');

    return `${year}-${month}-${day}`;
  }

  id: number;
  type: boolean;
  category: number;
  time: Date;
  amount: number;
  usage: string;

  constructor(id?: number, type?: boolean, category?: number, time?: Date, amount?: number, usage?: string) {
    this.id = id;
    this.type = type;
    this.category = category;
    this.time = time;
    this.amount = amount;
    this.usage = usage;
  }

  getType() {
    if (this.type == Bill.TYPE_INCOME)
      return $r("app.string.income");
    else
      return $r("app.string.expense");
  }

  static getCategory(category: number) {
    switch (category) {
    // income
      case Bill.CATEGORY_INCOME_SALARY:
        return $r("app.string.salary");
      case Bill.CATEGORY_INCOME_PARTTIME_INCOME:
        return $r("app.string.parttime_income");
      case Bill.CATEGORY_INCOME_INVESTMENT_EARNINGS:
        return $r("app.string.investment_earnings");
      case Bill.CATEGORY_INCOME_BUSINESS_INCOME:
        return $r("app.string.business_income");
      case Bill.CATEGORY_INCOME_GIFTS:
        return $r("app.string.gifts");
      case Bill.CATEGORY_INCOME_OTHER_INCOME:
        return $r("app.string.other_income");

    // expense
      case Bill.CATEGORY_EXPENSE_CLOTHES:
        return $r("app.string.clothes");
      case Bill.CATEGORY_EXPENSE_FOOD:
        return $r("app.string.food");
      case Bill.CATEGORY_EXPENSE_HOUSING:
        return $r("app.string.housing");
      case Bill.CATEGORY_EXPENSE_TRANSPORTATION:
        return $r("app.string.transportation");
      case Bill.CATEGORY_EXPENSE_HEALTH:
        return $r("app.string.health");
      case Bill.CATEGORY_EXPENSE_ENTERTAINMENT:
        return $r("app.string.entertainment");
      case Bill.CATEGORY_EXPENSE_EDUCATION:
        return $r("app.string.education");
      case Bill.CATEGORY_EXPENSE_DEBT_REPAYMENT:
        return $r("app.string.debt_repayment");
      case Bill.CATEGORY_EXPENSE_INVESTMENTS:
        return $r("app.string.investments");
      case Bill.CATEGORY_EXPENSE_INSURANCE:
        return $r("app.string.insurance");
      case Bill.CATEGORY_EXPENSE_CHARITABLE_DONATIONS:
        return $r("app.string.charitable_donations");
      case Bill.CATEGORY_EXPENSE_OTHER_EXPENSES:
        return $r("app.string.other_expenses");

      default:
        return $r("app.string.choose");
    }
  }

  getCategory() {
    return Bill.getCategory(this.category);
  }

  getTime() {
    return this.time
  }

  getAmount() {
    return this.amount;
  }

  getUsage() {
    return this.usage;
  }

  saveToDb() {
    const billDto = {
      type: this.type == Bill.TYPE_INCOME ? 0 : 1,
      category: this.category,
      time: Bill.formatDate(this.time),
      amount: this.amount.toFixed(2),
      usage: this.usage
    };

    console.log(JSON.stringify(billDto))

    Bill.rdb.insert("bill", billDto, (err, rowId) => {
      if (err) {
        console.error(`Failed to insert data. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info(`Succeeded in inserting data. rowId:${rowId}`);
    });
  }

  deleteFromDb() {
    let predicates = new relationalStore.RdbPredicates('bill');
    predicates.equalTo('id', this.id);
    Bill.rdb.delete(predicates, (err, rows) => {
      if (err) {
        console.error(`Failed to delete data. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info(`Delete rows: ${rows}`);
    });
  }

  updateDataInDb() {
    const billDto = {
      type: this.type,
      category: this.category,
      time: Bill.formatDate(this.time),
      amount: this.amount,
      usage: this.usage
    };

    let predicates = new relationalStore.RdbPredicates('bill'); // 创建表'bill'的predicates
    predicates.equalTo('id', this.id); // 匹配表'bill'中'id'为this.id的字段
    Bill.rdb.update(billDto, predicates, (err, rows) => {
      if (err) {
        console.error(`Failed to update data. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info(`Succeeded in updating data. row count: ${rows}`);
    })
  }

  static async queryByDay(date: Date) {
    let predicates = new relationalStore.RdbPredicates('bill');
    predicates.equalTo('time', Bill.formatDate(date));
    let err, resultSet = await Bill.rdb.query(predicates);
    if (err) {
      console.error(`Failed to query data. Code:${err.code}, message:${err.message}`);
      return;
    }
    console.info(`ResultSet column names: ${resultSet.columnNames}`);
    console.info(`ResultSet column count: ${resultSet.columnCount}`);
    console.info(`ResultSet row count: ${resultSet.rowCount}`);
    console.info(`ResultSet row index: ${resultSet.rowIndex}`);

    resultSet.goToFirstRow();

    let returnSet = [];
    while (!resultSet.isEnded) {
      returnSet.unshift(new Bill(
        resultSet.getLong(0),
        resultSet.getLong(1) == 0 ? Bill.TYPE_INCOME : Bill.TYPE_EXPENSE,
        resultSet.getLong(2),
        new Date(resultSet.getString((3))),
        resultSet.getDouble(4),
        resultSet.getString(5)
      ));
      resultSet.goToNextRow();
    }
    resultSet.close();
    return returnSet;
  }

  static getFirstAndLastDayOfMonth(year: number, month: number): { firstDay: Date, lastDay: Date } {
    // 构造一个表示指定年月的Date对象，月份是从0开始的，所以要减去1
    const firstDay = new Date(year, month - 1, 1);

    // 获取下个月的第一天，然后减去一天得到当前月的最后一天
    const lastDay = new Date(year, month, 0);

    return { firstDay, lastDay };
  }

  static getFirstAndLastDayOfYear(year: number): { firstDay: Date, lastDay: Date } {
    const firstDay = new Date(year, 0, 1);
    const lastDay = new Date(year + 1, 0, 1);
    lastDay.setDate(lastDay.getDate() - 1);

    return { firstDay, lastDay };
  }

  static async queryByMonth(date: Date) {
    const { firstDay, lastDay } = Bill.getFirstAndLastDayOfMonth(date.getFullYear(), date.getMonth() + 1);

    let predicates = new relationalStore.RdbPredicates('bill');
    predicates.between("time", Bill.formatDate(firstDay), Bill.formatDate(lastDay));
    let err, resultSet = await Bill.rdb.query(predicates);
    if (err) {
      console.error(`Failed to query data. Code:${err.code}, message:${err.message}`);
      return;
    }
    console.info(`ResultSet column names: ${resultSet.columnNames}`);
    console.info(`ResultSet column count: ${resultSet.columnCount}`);
    console.info(`ResultSet row count: ${resultSet.rowCount}`);
    console.info(`ResultSet row index: ${resultSet.rowIndex}`);

    resultSet.goToFirstRow();

    let returnSet = [];
    while (!resultSet.isEnded) {
      returnSet.unshift(new Bill(
        resultSet.getLong(0),
        resultSet.getLong(1) == 0 ? Bill.TYPE_INCOME : Bill.TYPE_EXPENSE,
        resultSet.getLong(2),
        new Date(resultSet.getString((3))),
        resultSet.getDouble(4),
        resultSet.getString(5)
      ));
      resultSet.goToNextRow();
    }
    resultSet.close();
    return returnSet;
  }

  static deleteAll() {
    let predicates = new relationalStore.RdbPredicates('bill');
    Bill.rdb.delete(predicates, (err, rows) => {
      if (err) {
        console.error(`Failed to delete data. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info(`Delete rows: ${rows}`);
    });
  }

  static async queryByYear(date: Date) {
    const { firstDay, lastDay } = Bill.getFirstAndLastDayOfYear(date.getFullYear());

    let predicates = new relationalStore.RdbPredicates('bill');
    predicates.between("time", Bill.formatDate(firstDay), Bill.formatDate(lastDay));
    let err, resultSet = await Bill.rdb.query(predicates);
    if (err) {
      console.error(`Failed to query data. Code:${err.code}, message:${err.message}`);
      return;
    }
    console.info(`ResultSet column names: ${resultSet.columnNames}`);
    console.info(`ResultSet column count: ${resultSet.columnCount}`);
    console.info(`ResultSet row count: ${resultSet.rowCount}`);
    console.info(`ResultSet row index: ${resultSet.rowIndex}`);

    resultSet.goToFirstRow();

    let returnSet = [];
    while (!resultSet.isEnded) {
      returnSet.unshift(new Bill(
        resultSet.getLong(0),
        resultSet.getLong(1) == 0 ? Bill.TYPE_INCOME : Bill.TYPE_EXPENSE,
        resultSet.getLong(2),
        new Date(resultSet.getString((3))),
        resultSet.getDouble(4),
        resultSet.getString(5)
      ));
      resultSet.goToNextRow();
    }
    resultSet.close();
    return returnSet;
  }

  static getWeekStartAndEnd(inputDate: Date): { weekStart: Date; weekEnd: Date } {
    const dayOfWeek = inputDate.getDay(); // 获取当前日期是星期几
    const difference = inputDate.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1); // 计算星期一的日期
    const weekStart = new Date(inputDate.setDate(difference));

    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekEnd.getDate() + 6); // 计算星期日的日期

    return { weekStart, weekEnd };
  }

  static async queryByWeek(date: Date) {
    const { weekStart, weekEnd } = Bill.getWeekStartAndEnd(date);

    let predicates = new relationalStore.RdbPredicates('bill');
    predicates.between("time", Bill.formatDate(weekStart), Bill.formatDate(weekEnd));
    let err, resultSet = await Bill.rdb.query(predicates);
    if (err) {
      console.error(`Failed to query data. Code:${err.code}, message:${err.message}`);
      return;
    }
    console.info(`ResultSet column names: ${resultSet.columnNames}`);
    console.info(`ResultSet column count: ${resultSet.columnCount}`);
    console.info(`ResultSet row count: ${resultSet.rowCount}`);
    console.info(`ResultSet row index: ${resultSet.rowIndex}`);

    resultSet.goToFirstRow();

    let returnSet = [];
    while (!resultSet.isEnded) {
      returnSet.unshift(new Bill(
        resultSet.getLong(0),
        resultSet.getLong(1) == 0 ? Bill.TYPE_INCOME : Bill.TYPE_EXPENSE,
        resultSet.getLong(2),
        new Date(resultSet.getString((3))),
        resultSet.getDouble(4),
        resultSet.getString(5)
      ));
      resultSet.goToNextRow();
    }
    resultSet.close();
    return returnSet;
  }

  static getIcon(category) {
    switch (category) {
    // income
      case Bill.CATEGORY_INCOME_SALARY:
        return $rawfile("salary.svg");
      case Bill.CATEGORY_INCOME_PARTTIME_INCOME:
        return $rawfile("part_time-income.svg");
      case Bill.CATEGORY_INCOME_INVESTMENT_EARNINGS:
        return $rawfile("investment-income.svg");
      case Bill.CATEGORY_INCOME_BUSINESS_INCOME:
        return $rawfile("business.svg");
      case Bill.CATEGORY_INCOME_GIFTS:
        return $rawfile("gift-redpacket.svg");
      case Bill.CATEGORY_INCOME_OTHER_INCOME:
        return $rawfile("other-income.svg");

    // expense
      case Bill.CATEGORY_EXPENSE_CLOTHES:
        return $rawfile("clothes.svg");
      case Bill.CATEGORY_EXPENSE_FOOD:
        return $rawfile("food.svg");
      case Bill.CATEGORY_EXPENSE_HOUSING:
        return $rawfile("housing.svg");
      case Bill.CATEGORY_EXPENSE_TRANSPORTATION:
        return $rawfile("transportation.svg");
      case Bill.CATEGORY_EXPENSE_HEALTH:
        return $rawfile("health.svg");
      case Bill.CATEGORY_EXPENSE_ENTERTAINMENT:
        return $rawfile("entertainment.svg");
      case Bill.CATEGORY_EXPENSE_EDUCATION:
        return $rawfile("education.svg");
      case Bill.CATEGORY_EXPENSE_DEBT_REPAYMENT:
        return $rawfile("debt-repayment.svg");
      case Bill.CATEGORY_EXPENSE_INVESTMENTS:
        return $rawfile("investment-expense.svg");
      case Bill.CATEGORY_EXPENSE_INSURANCE:
        return $rawfile("insurance.svg");
      case Bill.CATEGORY_EXPENSE_CHARITABLE_DONATIONS:
        return $rawfile("donations.svg");
      case Bill.CATEGORY_EXPENSE_OTHER_EXPENSES:
        return $rawfile("other-expense.svg");
    }
  }

  static getColor(category) {
    switch (category) {
    // income
      case Bill.CATEGORY_INCOME_SALARY:
        return "#0080FF";
      case Bill.CATEGORY_INCOME_PARTTIME_INCOME:
        return "#33EE66";
      case Bill.CATEGORY_INCOME_INVESTMENT_EARNINGS:
        return "#CC5522";
      case Bill.CATEGORY_INCOME_BUSINESS_INCOME:
        return "#66EECC";
      case Bill.CATEGORY_INCOME_GIFTS:
        return "#EE3322";
      case Bill.CATEGORY_INCOME_OTHER_INCOME:
        return "#66CCFF";

    // expense
      case Bill.CATEGORY_EXPENSE_CLOTHES:
        return "#99FFFF";
      case Bill.CATEGORY_EXPENSE_FOOD:
        return "#EE3388";
      case Bill.CATEGORY_EXPENSE_HOUSING:
        return "#44CC77";
      case Bill.CATEGORY_EXPENSE_TRANSPORTATION:
        return "#AA22CC";
      case Bill.CATEGORY_EXPENSE_HEALTH:
        return "#779933";
      case Bill.CATEGORY_EXPENSE_ENTERTAINMENT:
        return "#66FF66";
      case Bill.CATEGORY_EXPENSE_EDUCATION:
        return "#55BB11";
      case Bill.CATEGORY_EXPENSE_DEBT_REPAYMENT:
        return "#CCBB22";
      case Bill.CATEGORY_EXPENSE_INVESTMENTS:
        return "#8877DD";
      case Bill.CATEGORY_EXPENSE_INSURANCE:
        return "#44AABB";
      case Bill.CATEGORY_EXPENSE_CHARITABLE_DONATIONS:
        return "#AE324C";
      case Bill.CATEGORY_EXPENSE_OTHER_EXPENSES:
        return "#139969";
    }
  }
}
