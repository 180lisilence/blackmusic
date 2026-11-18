/**
 * 首页（教材 9.2 首页-Tab 栏）
 * 底部 4 个页签：推荐 / 发现 / 动态 / 我的；内容视图与页签一一对应。
 */
import { TabItemType } from '../models/MusicModels';
import { COLOR_ACCENT, COLOR_INACTIVE, COLOR_TABBAR, COLOR_TEXT } from '../common/Theme';
import { RecommendView } from '../views/RecommendView';
import { FindView } from '../views/FindView';
import { MomentView } from '../views/MomentView';
import { MineView } from '../views/MineView';
import { preloadAll } from '../common/DataStore';

@Entry
@Component
struct Index {
  @StorageProp('bottomSafe') bottomSafe: number = 0;
  @State currentIndex: number = 0;

  aboutToAppear(): void {
    preloadAll();
  }

  onPageShow(): void {
    preloadAll();
  }
  @State tabList: TabItemType[] = [
    { name: '推荐', icon: $r('app.media.ic_tab_recommend') },
    { name: '发现', icon: $r('app.media.ic_tab_find') },
    { name: '动态', icon: $r('app.media.ic_tab_moment') },
    { name: '我的', icon: $r('app.media.ic_tab_mine') }
  ];

  @Builder
  TabBarItem(index: number, item: TabItemType) {
    Column() {
      Image(item.icon)
        .width(22)
        .height(22)
        .fillColor(this.currentIndex === index ? COLOR_ACCENT : COLOR_INACTIVE)
        .objectFit(ImageFit.Contain)
      Text(item.name)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? COLOR_ACCENT : COLOR_INACTIVE)
        .margin({ top: 3 })
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        RecommendView()
      }
      .tabBar(this.TabBarItem(0, this.tabList[0]))

      TabContent() {
        FindView()
      }
      .tabBar(this.TabBarItem(1, this.tabList[1]))

      TabContent() {
        MomentView()
      }
      .tabBar(this.TabBarItem(2, this.tabList[2]))

      TabContent() {
        MineView()
      }
      .tabBar(this.TabBarItem(3, this.tabList[3]))
    }
    .width('100%')
    .height('100%')
    .barBackgroundColor(COLOR_TABBAR)
    .barHeight(48 + this.bottomSafe)
    .barMode(BarMode.Fixed)
    .scrollable(false)
    .animationDuration(0)
    .divider({ strokeWidth: 0.5, color: '#232329' })
    .backgroundColor('#0d0d10')
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}
