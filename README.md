![image](https://user-images.githubusercontent.com/45725145/209348362-5ce4aed9-87d3-4e7a-9c0d-3472869361f9.png)


## 修改部分
2022/12/18 李倬安
1. 把視窗標題更改為forest jam
2. 將文字對正視窗
3. 更改初始介面/顏色
4. 有關introduction全部刪除
5. 把一些偵測 'g' 改為 's'

22/12/21 黃俞臻
1. 令其碰到敵軍扣血，並讓敵軍回到最上方繼續執行
2. 讓友軍不會超過邊界
3. 設計了新的飛機圖形，直接套用會有殘影等問題

22/12/22 黃俞臻

2PM
1. 修正新的飛機殘影問題
2. 修正新的飛機邊界問題
3. 修正讓敵軍重新往下掉時，只修改敵軍顏色讓它消失會在飛機經過後顯示的 BUG

11PM
1. 新增友軍發射子彈功能 (全自動，等到一顆子彈打到最上方才會發射下一顆)
2. 修正子彈判定範圍
3. 修正生命值為零不會結束遊戲 (將判定並呈現結束畫面拉出來成一個function)
4. 新增 'n' 快捷鍵，一次加 10000 分 (測試用)

發現問題：
1. 在敵軍數量大於等於二時出現BUG，已修正
2. 有時敵軍卡在畫面上方，已修正

22/12/23 黃俞臻

1AM

1. 新增醫療包功能，吃到一個加 100 HP
2. 落下不再加分，射中才會加分

22/12/23 林晉宇
1. 猴子移動超過邊界 ([已修](https://github.com/AssemblyFinalProject/forest-jam/commit/776da09d941a5854bd910da38b196349044269a6))
2. 猴子殘影 ([已修](https://github.com/AssemblyFinalProject/forest-jam/commit/3e41e29f3ff7ca7848e3c82ebde7d2751f27f400))
3. 修改logo -> [Monkey Revenge](https://github.com/AssemblyFinalProject/monky-revenge/commit/0969c521f925007f1af3aef2fb91575d5c373397)

## 已知Bug
1. HP包閃爍
2. 分數超過65000就會沒敵人
3. 猴子移動超過邊界 ([已修](https://github.com/AssemblyFinalProject/forest-jam/commit/776da09d941a5854bd910da38b196349044269a6))
4. 猴子殘影 ([已修](https://github.com/AssemblyFinalProject/forest-jam/commit/3e41e29f3ff7ca7848e3c82ebde7d2751f27f400))
5. 佛祖殘影
