import { ScriptManager } from '../manager/ScriptManager'
import { UserScript } from '../model/UserScript'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct ScriptManagerPage {
  @State scripts: UserScript[] = []
  @State isDarkMode: boolean = false
  @State showAddDialog: boolean = false
  @State showImportDialog: boolean = false
  @State newScriptName: string = ''
  @State newScriptMatch: string = '*://*/*'
  @State newScriptCode: string = ''
  @State importCode: string = ''

  private scriptManager: ScriptManager = ScriptManager.getInstance()

  async aboutToAppear() {
    const prefs = await import('@kit.ArkData').then(m => m.preferences)
    const context = getContext(this)
    const pref = await prefs.getPreferences(context, 'browser_settings')
    this.isDarkMode = (await pref.get('dark_mode', false)) as boolean

    await this.scriptManager.init(context)
    this.scripts = this.scriptManager.getAllScripts()

    this.scriptManager.setOnScriptsChanged(() => {
      this.scripts = [...this.scriptManager.getAllScripts()]
    })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(15)
            .fontColor(this.isDarkMode ? '#C5D4C6' : '#4A7C59')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => { router.back() })

        Text('🐒 油猴脚本')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDarkMode ? '#C5D4C6' : '#2C3E2D')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('添加')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(16)
          .height(32)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.showAddDialog = true
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 16 })
      .backgroundColor(this.isDarkMode ? '#1A1F1B' : '#FFFFFF')

      // 脚本列表
      if (this.scripts.length === 0) {
        Column() {
          Text('🐒')
            .fontSize(48)
            .margin({ bottom: 16 })

          Text('还没有安装任何脚本')
            .fontSize(16)
            .fontColor(this.isDarkMode ? '#6B7C6C' : '#8A9E8B')
            .margin({ bottom: 8 })

          Text('点击右上角「添加」按钮手动添加\n或导入 Tampermonkey 格式的脚本')
            .fontSize(13)
            .fontColor(this.isDarkMode ? '#4F5F50' : '#A0B0A1')
            .textAlign(TextAlign.Center)
            .lineHeight(20)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        List() {
          ForEach(this.scripts, (script: UserScript) => {
            ListItem() {
              this.ScriptItemBuilder(script)
            }
            .swipeAction({ end: this.ScriptDeleteBuilder(script) })
          }, (script: UserScript) => script.id)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0.5, color: this.isDarkMode ? '#2A302C' : '#EAF0EC' })
      }

      // 底部导入按钮
      Row() {
        Button('📥 导入 Tampermonkey 脚本')
          .width('90%')
          .height(44)
          .fontSize(14)
          .fontColor('#4A7C59')
          .backgroundColor(this.isDarkMode ? '#222923' : '#E8F2EB')
          .borderRadius(22)
          .onClick(() => {
            this.showImportDialog = true
          })
      }
      .width('100%')
      .padding({ top: 12, bottom: 20 })
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.isDarkMode ? '#1A1F1B' : '#FAFDF7')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#1A1F1B' : '#FAFDF7')
    .bindContentCover(this.showAddDialog, this.AddScriptDialogBuilder())
    .bindContentCover(this.showImportDialog, this.ImportScriptDialogBuilder())
  }

  @Builder
  ScriptItemBuilder(script: UserScript) {
    Row() {
      Column() {
        Text(script.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDarkMode ? '#C5D4C6' : '#2C3E2D')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(`v${script.version}`)
            .fontSize(11)
            .fontColor(this.isDarkMode ? '#6B7C6C' : '#8A9E8B')
            .margin({ right: 8 })

          Text(script.match)
            .fontSize(11)
            .fontColor(this.isDarkMode ? '#4F5F50' : '#A0B0A1')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Toggle({ type: ToggleType.Switch, isOn: script.enabled })
        .selectedColor('#4A7C59')
        .width(44)
        .height(24)
        .onChange(() => {
          this.scriptManager.toggleScript(script.id)
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.isDarkMode ? '#222923' : '#FFFFFF')
  }

  @Builder
  ScriptDeleteBuilder(script: UserScript) {
    Button('删除')
      .fontSize(13)
      .fontColor('#FFFFFF')
      .backgroundColor('#D94F4F')
      .borderRadius(4)
      .width(64)
      .height('80%')
      .onClick(async () => {
        await this.scriptManager.removeScript(script.id)
        this.scripts = [...this.scriptManager.getAllScripts()]
      })
  }

  // ===== 添加脚本对话框 =====
  @Builder
  AddScriptDialogBuilder() {
    Column() {
      // 标题栏
      Row() {
        Text('新建脚本')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDarkMode ? '#C5D4C6' : '#2C3E2D')
          .layoutWeight(1)

        Button('✕')
          .fontSize(18)
          .fontColor(this.isDarkMode ? '#6B7C6C' : '#8A9E8B')
          .backgroundColor(Color.Transparent)
          .onClick(() => { this.showAddDialog = false })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column() {
          // 脚本名称
          Text('脚本名称')
            .fontSize(13)
            .fontColor(this.isDarkMode ? '#6B7C6C' : '#8A9E8B')
            .margin({ bottom: 6 })
            .width('100%')

          TextInput({ text: this.newScriptName, placeholder: '例如：百度美化' })
            .width('100%')
            .height(44)
            .fontSize(14)
            .backgroundColor(this.isDarkMode ? '#2A302C' : '#F5F8F6')
            .fontColor(this.isDarkMode ? '#C5D4C6' : '#2C3E2D')
            .borderRadius(8)
            .onChange((value) => { this.newScriptName = value })

          // 匹配规则
          Text('@match 匹配规则')
            .fontSize(13)
            .fontColor(this.isDarkMode ? '#6B7C6C' : '#8A9E8B')
            .margin({ top: 16, bottom: 6 })
            .width('100%')

          TextInput({ text: this.newScriptMatch, placeholder: '*://*/*' })
            .width('100%')
            .height(44)
            .fontSize(14)
            .backgroundColor(this.isDarkMode ? '#2A302C' : '#F5F8F6')
            .fontColor(this.isDarkMode ? '#C5D4C6' : '#2C3E2D')
            .borderRadius(8)
            .onChange((value) => { this.newScriptMatch = value })

          // 脚本代码
          Text('JavaScript 代码')
            .fontSize(13)
            .fontColor(this.isDarkMode ? '#6B7C6C' : '#8A9E8B')
            .margin({ top: 16, bottom: 6 })
            .width('100%')

          TextArea({ text: this.newScriptCode, placeholder: '// 在此输入 JavaScript 代码' })
            .width('100%')
            .height(200)
            .fontSize(12)
            .fontFamily('monospace')
            .backgroundColor(this.isDarkMode ? '#2A302C' : '#F5F8F6')
            .fontColor(this.isDarkMode ? '#C5D4C6' : '#2C3E2D')
            .borderRadius(8)
            .onChange((value) => { this.newScriptCode = value })
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)

      // 底部按钮
      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor(this.isDarkMode ? '#C5D4C6' : '#5F7560')
          .backgroundColor(this.isDarkMode ? '#2A302C' : '#E8F2EB')
          .borderRadius(22)
          .onClick(() => { this.showAddDialog = false })

        Button('保存')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(22)
          .margin({ left: 12 })
          .onClick(async () => {
            const script = new UserScript(this.newScriptName, this.newScriptCode, this.newScriptMatch)
            await this.scriptManager.addScript(script)
            this.scripts = [...this.scriptManager.getAllScripts()]
            this.showAddDialog = false
            this.newScriptName = ''
            this.newScriptCode = ''
            this.newScriptMatch = '*://*/*'
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#1A1F1B' : '#FAFDF7')
  }

  // ===== 导入 Tampermonkey 脚本对话框 =====
  @Builder
  ImportScriptDialogBuilder() {
    Column() {
      // 标题栏
      Row() {
        Text('导入脚本')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isDarkMode ? '#C5D4C6' : '#2C3E2D')
          .layoutWeight(1)

        Button('✕')
          .fontSize(18)
          .fontColor(this.isDarkMode ? '#6B7C6C' : '#8A9E8B')
          .backgroundColor(Color.Transparent)
          .onClick(() => { this.showImportDialog = false })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      Column() {
        Text('粘贴 Tampermonkey 格式的脚本代码（包含 ==UserScript== 头部）')
          .fontSize(13)
          .fontColor(this.isDarkMode ? '#6B7C6C' : '#8A9E8B')
          .margin({ bottom: 8 })

        TextArea({ text: this.importCode, placeholder: '// ==UserScript==\n// @name         My Script\n// @match        *://*/*\n// ==/UserScript==\n\n// Your code here...' })
          .width('100%')
          .height(300)
          .fontSize(11)
          .fontFamily('monospace')
          .backgroundColor(this.isDarkMode ? '#2A302C' : '#F5F8F6')
          .fontColor(this.isDarkMode ? '#C5D4C6' : '#2C3E2D')
          .borderRadius(8)
          .onChange((value) => { this.importCode = value })
      }
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)

      // 底部按钮
      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor(this.isDarkMode ? '#C5D4C6' : '#5F7560')
          .backgroundColor(this.isDarkMode ? '#2A302C' : '#E8F2EB')
          .borderRadius(22)
          .onClick(() => { this.showImportDialog = false })

        Button('导入')
          .layoutWeight(1)
          .height(44)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(22)
          .margin({ left: 12 })
          .onClick(async () => {
            if (this.importCode.trim()) {
              await this.scriptManager.importFromCode(this.importCode)
              this.scripts = [...this.scriptManager.getAllScripts()]
              this.showImportDialog = false
              this.importCode = ''
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isDarkMode ? '#1A1F1B' : '#FAFDF7')
  }
}
