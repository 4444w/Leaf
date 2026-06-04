import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'
import { ScriptManager } from '../manager/ScriptManager'
import { SettingsManager } from '../manager/SettingsManager'

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('[LeafBrowser] Ability onCreate')
    // 初始化管理器
    await SettingsManager.shared.init(this.context)
    await ScriptManager.shared.init(this.context)
  }

  onDestroy(): void {
    console.info('[LeafBrowser] Ability onDestroy')
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.info('[LeafBrowser] onWindowStageCreate')
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error('[LeafBrowser] loadContent failed:', JSON.stringify(err))
        return
      }
      console.info('[LeafBrowser] loadContent success')
    })
  }

  onWindowStageDestroy(): void {}

  onForeground(): void {}

  onBackground(): void {}
}
