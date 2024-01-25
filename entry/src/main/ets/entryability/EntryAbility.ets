import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import hilog from '@ohos.hilog';
import UIAbility from '@ohos.app.ability.UIAbility';
import Want from '@ohos.app.ability.Want';
import relationalStore from '@ohos.data.relationalStore';
import Bill from "../bill/Bill"
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';

export default class EntryAbility extends UIAbility {
  static store: relationalStore.RdbStore;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.context.config.colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage) {
    const STORE_CONFIG = {
      name: 'MyCashbook.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全级别
    };

    const SQL_CREATE_TABLE = "create table if not exists bill (id integer primary key autoincrement, type integer not null, category integer not null, time date not null, amount decimal(10, 2) not null, usage text not null)"; // 建表Sql语句

    relationalStore.getRdbStore(this.context as Context, STORE_CONFIG, (err, store) => {
      if (err) {
        console.error(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info(`Succeeded in getting RdbStore.`);

      store.executeSql(SQL_CREATE_TABLE).then(() => {
        Bill.rdb = store;
        windowStage.loadContent("pages/Index", (err) => {
          if (err.code) {
            console.error('Failed to load the content. Cause:' + JSON.stringify(err));
            return;
          }
          console.info('Succeeded in loading the content.');
        });
      }).catch(() => {
        console.error("Failed to create table \"bill\"");
      })



    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
