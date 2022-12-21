# forest-jam  



2022/12/18 李倬安
1. 把視窗標題更改為forest jam
2. 將文字對正視窗
3. 更改初始介面/顏色
4. 有關introduction全部刪除
5. 把一些偵測 'g' 改為 's'

22/12/21 黃俞臻
1. 令其碰到敵軍扣血，並讓敵軍回到最上方繼續執行
2. 讓友軍不會超過邊界
3. 設計了新的飛機圖形，直接套用會有殘影等問題，如果要用可以告訴我，我試試看處理

以下為飛機圖形：

 ! A ! 
<TTXTT>
   I   
  <T>  

程式碼：
allyPlaneUp BYTE " ! A ! "
allyPlaneMid1 BYTE "<TTXTT>"
allyPlaneMid2 BYTE "   I   "
allyPlaneDown BYTE "  <T>  "
