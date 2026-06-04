import { router } from '@kit.ArkUI'
import { ScriptManager } from '../manager/ScriptManager'
import { SettingsManager } from '../manager/SettingsManager'
import { UserScript } from '../model/UserScript'

/**
 * 油猴脚本管理页面
 * 
 * 功能：
 * - 查看已安装脚本列表，开关 / 左滑删除
 * - 手动新建脚本（名称 + @match + 代码）
 * - 导入 Tampermonkey 格式脚本（自动解析 ==UserScript== 头部）
 */
@Entry
@Component
struct ScriptPage {
  @State dark: boolean = false
  @State scripts: UserScript[] = []
  @State showAdd: boolean = false
  @State showImport: boolean = false

  // 新建脚本表单
  @State formName: string = ''
  @State formMatch: string = '*://*/*'
  @State formCode: string = ''

  // 导入脚本
  @State importText: string = ''

  private mgr: ScriptManager = ScriptManager.shared
  private settings: SettingsManager = SettingsManager.shared

  async aboutToAppear() {
    this.dark = this.settings.darkMode
    await this.mgr.init(getContext(this))
    this.scripts = [...this.mgr.all()]
    this.mgr.onChange(() => { this.scripts = [...this.mgr.all()] })
  }

  build() {
    Column() {
      // ─── 顶部栏 ────────────────────────
      Row() {
        Button() {
          Text('← 返回')
            .fontSize(15)
            .fontColor(this.dark ? '#C5D4C6' : '#4A7C59')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back())

        Text('🐒 油猴脚本')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('+ 新建')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(14)
          .height(28)
          .padding({ left: 12, right: 12 })
          .onClick(() => { this.showAdd = true })
      }
      .width('100%')
      .height(54)
      .padding({ left: 4, right: 12 })
      .backgroundColor(this.dark ? '#111613' : '#FFFFFF')

      // ─── 脚本列表 / 空状态 ─────────────
      if (this.scripts.length === 0) {
        this.EmptyState()
      } else {
        List() {
          ForEach(this.scripts, (s: UserScript) => {
            ListItem() {
              this.ScriptRow(s)
            }
            .swipeAction({ end: this.SwipeDelete(s.id) })
          }, (s: UserScript) => s.id)
        }
        .width('100%')
        .layoutWeight(1)
        .divider({ strokeWidth: 0.5, color: this.dark ? '#1E2620' : '#EAF0EC' })
      }

      // ─── 底部导入按钮 ──────────────────
      Row() {
        Button('📥 导入 Tampermonkey 脚本')
          .width('88%')
          .height(42)
          .fontSize(14)
          .fontColor('#4A7C59')
          .backgroundColor(this.dark ? '#1E2620' : '#E8F2EB')
          .borderRadius(21)
          .onClick(() => { this.showImport = true })
      }
      .width('100%')
      .padding({ top: 10, bottom: 18 })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.dark ? '#111613' : '#FAFDF7')
    .bindContentCover(this.showAdd, this.AddSheet())
    .bindContentCover(this.showImport, this.ImportSheet())
  }

  // ─── 空状态 ───────────────────────────────

  @Builder EmptyState() {
    Column() {
      Text('🐒')
        .fontSize(52)
        .margin({ bottom: 16 })
      Text('还没有安装脚本')
        .fontSize(16)
        .fontColor(this.dark ? '#6B7C6C' : '#8A9E8B')
        .margin({ bottom: 6 })
      Text('点击「+ 新建」手动创建\n或点击底部「导入」粘贴 Tampermonkey 脚本')
        .fontSize(13)
        .fontColor(this.dark ? '#4F5F50' : '#A0B0A1')
        .textAlign(TextAlign.Center)
        .lineHeight(22)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // ─── 脚本行 ───────────────────────────────

  @Builder ScriptRow(s: UserScript) {
    Row() {
      Column() {
        Text(s.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text(`v${s.version}`)
            .fontSize(11)
            .fontColor(this.dark ? '#4F5F50' : '#A0B0A1')
            .margin({ right: 8 })
          Text(s.match)
            .fontSize(11)
            .fontColor(this.dark ? '#4F5F50' : '#A0B0A1')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .margin({ top: 3 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Toggle({ type: ToggleType.Switch, isOn: s.enabled })
        .selectedColor('#4A7C59')
        .width(42)
        .height(22)
        .onChange(() => { this.mgr.toggle(s.id) })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.dark ? '#1A1F1B' : '#FFFFFF')
  }

  @Builder SwipeDelete(id: string) {
    Button('删除')
      .fontSize(13)
      .fontColor('#FFFFFF')
      .backgroundColor('#D94F4F')
      .borderRadius(6)
      .width(60)
      .height(48)
      .margin({ top: 6, bottom: 6 })
      .onClick(async () => {
        await this.mgr.remove(id)
        this.scripts = [...this.mgr.all()]
      })
  }

  // ─── 新建脚本面板 ─────────────────────────

  @Builder AddSheet() {
    Column() {
      // 标题栏
      Row() {
        Text('新建脚本')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
          .layoutWeight(1)
        Button('✕')
          .fontSize(18)
          .fontColor(this.dark ? '#6B7C6C' : '#8A9E8B')
          .backgroundColor(Color.Transparent)
          .onClick(() => { this.showAdd = false })
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column() {
          this.FormLabel('脚本名称')
          TextInput({ text: this.formName, placeholder: '如：百度美化' })
            .width('100%')
            .height(42)
            .fontSize(14)
            .backgroundColor(this.dark ? '#1E2620' : '#F5F8F6')
            .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
            .borderRadius(8)
            .onChange(v => { this.formName = v })

          this.FormLabel('@match 规则')
          TextInput({ text: this.formMatch, placeholder: '*://*/*' })
            .width('100%')
            .height(42)
            .fontSize(14)
            .backgroundColor(this.dark ? '#1E2620' : '#F5F8F6')
            .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
            .borderRadius(8)
            .onChange(v => { this.formMatch = v })

          this.FormLabel('JavaScript 代码')
          TextArea({ text: this.formCode, placeholder: '// 输入 JavaScript 代码' })
            .width('100%')
            .height(220)
            .fontSize(12)
            .fontFamily('monospace')
            .backgroundColor(this.dark ? '#1E2620' : '#F5F8F6')
            .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
            .borderRadius(8)
            .onChange(v => { this.formCode = v })
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)

      // 底部按钮
      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(42)
          .fontSize(15)
          .fontColor(this.dark ? '#C5D4C6' : '#5F7560')
          .backgroundColor(this.dark ? '#1E2620' : '#E8F2EB')
          .borderRadius(21)
          .onClick(() => { this.showAdd = false })

        Button('保存')
          .layoutWeight(1)
          .height(42)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(21)
          .margin({ left: 10 })
          .onClick(async () => {
            const s = new UserScript(this.formName, this.formCode, this.formMatch)
            await this.mgr.add(s)
            this.scripts = [...this.mgr.all()]
            this.showAdd = false
            this.formName = ''
            this.formCode = ''
            this.formMatch = '*://*/*'
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.dark ? '#111613' : '#FAFDF7')
  }

  // ─── 导入脚本面板 ─────────────────────────

  @Builder ImportSheet() {
    Column() {
      Row() {
        Text('导入脚本')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
          .layoutWeight(1)
        Button('✕')
          .fontSize(18)
          .fontColor(this.dark ? '#6B7C6C' : '#8A9E8B')
          .backgroundColor(Color.Transparent)
          .onClick(() => { this.showImport = false })
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })

      Column() {
        Text('粘贴完整的 Tampermonkey 脚本（含 ==UserScript== 头部）')
          .fontSize(12)
          .fontColor(this.dark ? '#4F5F50' : '#8A9E8B')
          .margin({ bottom: 8 })

        TextArea({
          text: this.importText,
          placeholder: '// ==UserScript==\n// @name         My Script\n// @match        *://*/*\n// ==/UserScript==\n\n// Your code here...'
        })
          .width('100%')
          .height(320)
          .fontSize(11)
          .fontFamily('monospace')
          .backgroundColor(this.dark ? '#1E2620' : '#F5F8F6')
          .fontColor(this.dark ? '#C5D4C6' : '#2C3E2D')
          .borderRadius(8)
          .onChange(v => { this.importText = v })
      }
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)

      Row() {
        Button('取消')
          .layoutWeight(1)
          .height(42)
          .fontSize(15)
          .fontColor(this.dark ? '#C5D4C6' : '#5F7560')
          .backgroundColor(this.dark ? '#1E2620' : '#E8F2EB')
          .borderRadius(21)
          .onClick(() => { this.showImport = false })

        Button('导入')
          .layoutWeight(1)
          .height(42)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#4A7C59')
          .borderRadius(21)
          .margin({ left: 10 })
          .onClick(async () => {
            if (this.importText.trim()) {
              await this.mgr.importCode(this.importText)
              this.scripts = [...this.mgr.all()]
              this.showImport = false
              this.importText = ''
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.dark ? '#111613' : '#FAFDF7')
  }

  // ─── 通用 ─────────────────────────────────

  @Builder FormLabel(text: string) {
    Text(text)
      .fontSize(12)
      .fontColor(this.dark ? '#4F5F50' : '#8A9E8B')
      .margin({ top: 16, bottom: 6 })
      .width('100%')
  }
}
