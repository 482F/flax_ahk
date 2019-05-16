# はじめに

- 好き勝手なホットキー登録により随所で意図せぬ挙動が見られると思われる。何かおかしなことがあったらこれを疑うこと。
- config フォルダ内にサンプルファイルがあるため、`_sample` を除去し、それを拡張する形で使用していただくのが吉。

# メイン機能

## ランチャー

- Ctrl + Alt + Shift + w で起動
	- 設定は config/launcher.fd に記述
    - 表示位置の設定は config/config.fd に記述
        - launcher.pos を center にすると画面中央に表示される
        - launcher.pos.x, launcher.pos.y を数値にするとその x, y 座標に表示される
        - それ以外の場合は画面右下に表示される
    - 候補検索方法の設定は config/config.fd に記述
        - launcher.search_method を変更。prefix で前方一致。partial で部分一致
	- エクスプローラ上で Ctrl + r -> [Launcher に登録 (R)] を選択で登録 GUI が起動
		- Name
			- そのままの意味。キーワード。
		- Command
			- パスや URL。
        - working directory
            - 作業ディレクトリ
		- Type
			- 登録対象がフォルダならば LocalPath、ファイルやアプリケーションならば Application。URL, Label も登録できるがブラウザ上で GUI は表示されないので、Command に URL, Label を張り付ける必要がある。
		- Computer
			- 登録しているコンピュータにのみ登録する際には ThisComputer、すべてのコンピュータに同一のコマンドを登録するならば AllComputer。同じ設定ファイルでコンピュータ毎に挙動を変更できる。
## マウスジェスチャー
- Windows + (オプションキー) + マウスボタンで起動
- ホットストリング flaxeditgesture で設定追加
	- [マウスボタン][修飾キー][マウスの移動経路]
	- マウスボタン
		- LB: 左クリック
		- MB: ホイールクリック
		- RB: 右クリック
	- オプションキー
		- ^: Crtl
		- !: Alt
		- +: Shift
	- マウスの移動経路
		- L: 左
		- R: 右
		- D: 下
		- U: 上
		- BUR: 右上
		- BUL: 左上
		- BDR: 右下
		- BDL: 左下
- REC を押下し、マウスを動かすと gesture が記録される。記録終了は ESC キー。
- Command にパスや URL、Launcher のキーワード、flax.ahk 内のラベルを入力
## 連打モード
- 無変換 + r で連打モードの切り替え
    - モードは普通、押下中連打、永続連打、永続押下の四種類
- 左クリックに関して行いたい場合、左クリックを先に押しつつ右クリック>を押す。右クリックなら逆
- 永続連打、押下は左右クリックや Esc によって解除される
## エクスプローラ関係
- ファイル / フォルダを Ctrl + c して、
	- Ctrl + Shift + v でショートカット作成
	- Alt + v でシンボリックリンク作成
- ファイル / フォルダを Ctrl + Shift + x して、
    - Ctrl + Shift + v でファイル / フォルダの元の位置にショートカットを残して移動
    - Alt + v でファイル / フォルダの元の位置にシンボリックリンクを残して移動
    - Ctrl + Shift + v / Alt + v を押したパスにショートカット / シンボリックリンクを作成して、実体と交換する、と考えると理解しやすいかも。実際にはそうではないが
- ファイル / フォルダを Ctrl + Shift + v でパスをクリップボードにコピー
- ファイル / フォルダを Ctrl + r して、エクスプローラメニューの表示
    - フォルダに関して、[フォルダ内の MP3 のタグを編集]
        - MP3 のタグ編集を一括で行える GUI を表示
        - Enter キーで変更を保存
    - ファイルに関して、[MP3 のタグを編集]
        - MP3 のタグ編集を行える GUI を表示
    - ファイル / フォルダに関して、[launcher に登録]
        - Launcher 登録 GUI を表示。詳細は launcher の項で
    - ファイル / フォルダに関して、[プログラムから開く]
        - 未実装
## レジスタ
- Win + c, x -> キーワード入力で選択範囲をキーワードと紐付ける
- Win + v -> キーワードでキーワードと紐付けられている文字列をペースト
- Win + e -> キーワード入力でクリップボード内の値とキーワードを紐づける
- Win + r -> キーワードでキーワードと紐づけられている文字列をクリップボードに
## 時間割表示
- ホットストリング flaxtimetable で起動
- アローキー、wasd、hjkl で選択セルを移動
    - 選択セルの初期位置は現在時刻と曜日によって決まる。
    - 現在時刻によるセルの位置決定の基準は config.fd に記述。記述例は config_sample.fd を参照
- Alt + up, down でプロファイルを変更
- 左クリックでクリックしたセルの、Enter, Space で選択セルの授業フォルダを開く
- 右クリックでクリックしたセルの、Ctrl + Enter, Space で選択セルの URL を開く
- ホットストリング flaxedittimetable で設定
	- 入力欄に文字列を入力して [OK]
        - 1 行目の入力は URL を入力する欄なので注意
    - ドロップダウンリストからプロファイル名を選択
        - new を選ぶと新規プロファイルが作成できる
- セルをクリックして開かれるパスの定義は config/path.fd に記述
    - 例: class=D:\document\授業\
        - この例だとセルをクリックしたときに [D:\document\授業\プロファイル名\授業名] フォルダが開かれる。フォルダが存在しない場合は作成するか否かを問うダイアログが表示される
## ホットキー編集
- config/config.fd の ChangeHotKey セクションで設定を変更

```
ChangeHotKey=[
	A=[
		IfWinActive=ahk_exe B.exe
		Key=C
	]
]
```

- で IfWinActive, ahk_exe B.exe のホットキー A を C に変更できる。C を Off にするとホットキーを無効化できる
- Ctrl は ^, Alt は !, Shift は +, Windows は # に対応しているので、例えばランチャー起動 (Ctrl + Alt + Shift + W) を Ctrl + L キーに割り当てたいなら、
```
+!^W=[
    Key=^L
]
```
- となる。ただし、変更前の値はソースコード準拠となるため、上の例の場合 !^+W=[ ではエラーとなる
- IfWinActive の設定関係は複雑なので、作った方もよくわかってないです。変えたいときは問い合わせてみてください

## FIFO
- ホットストリング flaxfifo でモード切替
- Ctrl + c, x, v に関して FIFO モードになる
# 端機能
## ホットストリング
- flaxtest
	- テストコマンド。新機能の確認とかに使われたりする。副作用がある場合も多いので、使用しないが吉。
- flaxcalc
	- 計算結果を入力してくれる。バグがあるかも。
- flaxrapidlb
	- ひたすら左クリックを連打。ESC キーで止まる。
- flaxwindowalwaysontop
	- アクティブウィンドウを常時最前面表示にする。
- flaxgetprocessname
	- アクティブウィンドウのプロセス名をクリップボードに保存
- flaxmonitoroff
	- ブランクのスクリーンセーバーを起動
- flaxreload
	- スクリプトを再読み込みする。困ったときはこれ。
- flaxmakecodegui
	- Clear Text に平文、Seed にシード値 (文字列) を入れると暗号文が出力される。暗号文は暗号化時に使用したシード値で複合できる。
- flaxsendclip
	- クリップボードの中身が出力される。コピー禁止の入力欄などに用いる。
- flaxcolorviewer
	- カラーパレットが表示される
- flaxpickcolor
	- マウスカーソル下の色がクリップボードに保存される。
- flaxcountstrlen
	- クリップボードにある文字列の文字数をメッセージボックスで表示する。
- flaxfifo
	- コピーペーストを FIFO にする。トグル式。
- flaxvirtualfolder
	- 仮想フォルダが表示される
        - Make Link モードではファイルをドラッグアンドドロップして、Dist Path にパスを入力、Confirm でドロップされたファイルフォルダのショートカットが Dist Path 下に作られる
        - Rename モードでは Rule に正規表現のパターン、Replacement に置換後の文字を入れることでファイル/ディレクトリの名前を一括で置換できる
        - Modify Shortcut モードでは Rule に正規表現のパターン、Replacement に置換後の文字を入れることでショートカットの参照先を一括で置換できる
- flaxconnectratwifi
	- RAT-WIRELESS-A に接続される。
- flaxtimetable
	- 時間割が表示される。セルをクリックで config/path.fd の class のパス + セルの 1 行目のディレクトリに飛ぶ。
- flaxtransparent
	- アクティブウィンドウを薄くする。
- flaxeditgesture
	- ジェスチャー設定 GUI。使い方はメイン機能の項を参照。
- flaxedittimetable
	- 時間割設定 GUI。使い方はメイン機能の項を参照。
- flaxregtest
    - 正規表現の挙動を確認できる GUI を表示。autohotkey の正規表現なので他と仕様が異なる部分があるため注意。
- flaxremotedesktop
    - リモートデスクトップを設定に基づいて行うホットストリング
    - 起動後、プロファイル名を入力し Enter で登録されたコマンドを実行し、リモートデスクトップで接続する
    - flaxregisterremotedesktop でプロファイルの設定ができる
        - name: プロファイル名。好きなものを入力
        - target: リモートデスクトップで接続するアドレスとポート
        - command mode: command がどの種類かを設定する
        - command: コマンドプロンプトのコマンドや、wsl の .ssh/config で設定されたホスト名、putty のセッション名などを記入
        - computer: 対象コンピュータの設定
## ホットキー
- Ctrl + Alt + Shift + w
	- ランチャーを起動。使い方はメイン機能の項を参照。
- Ctrl + Enter
	- 下に空行を挿入して移動。所構わず起動するので若干使いづらい。
- Ctrl + Shift + Enter
	- 上に空行を挿入して移動。所構わず起動するので若干使いづらい。
- Ctrl + Alt + m
	- アクティブウィンドウのミュート、アンミュートを切り替え
- Alt + Volume_Up
    - アクティブウィンドウをアンミュート
- Alt + Volume_Down
    - アクティブウィンドウをミュート
- Ctrl + Win + c, x
	- レジスタにコピー, 切り取り
- Ctrl + Win + v
	- レジスタから貼り付け
- 無変換 + h, j, k, l
	- アローキーに対応
- 無変換 + Space
	- Enter
- 無変換 + 1, 2, 3, 4, 5
	- 6, 7, 8, 9, 0
- 無変換 + PrintScreen
    - screenshot ディレクトリにスクリーンショットを保存
- Ctrl + Win + h, l
	- 仮想デスクトップの移動
- Win + (修飾キー) + マウスクリック
	- マウスジェスチャー起動。使い方はメイン機能の項を参照。
- Win + Enter
	- Ctrl + Shift + Enter
- Ctrl + Alt + Shift + c, d, r
	- Alt + Shift + ,, ., l
## ウィンドウ毎の機能
- excel.exe
	- Ctrl + (Shift) + Tab
		- シートの切り替え
- LINE.exe
	- Ctrl + e
		- Shift + 右アローキー
- eclipse.exe
	- flaxexclude
		- 現在編集中のファイルをビルド対象から外す。というかトグル。
	- Ctrl + (Shift) + Tab
		- タブを移動
	- F5
		- Alt + r -> s -> Enter
- explorer.exe
	- Ctrl + Shift + c
		- ファイルのパスをコピー
	- Ctrl + c -> Ctrl + Shift + v
		- ショートカットを作成
	- Ctrl + c -> Alt + v
			- シンボリックリンクを作成
	- Ctrl + n
		- CreateNew フォルダ内のファイルに即した新規ファイルを作成。サンプル作成予定。
	- Ctrl + r
		- メニュー表示。プログラムから開くは未実装。Launcher に登録についてはメイン機能の項を参照。
## config.fd
- Font

```
Font=[
    Name=ＭＳ　ゴシック
    Size=10
    launcher=[
        Name=Meiryo UI
        Size=15
    ]
]
```

    - 上記の設定をすると GUI のデフォルトフォントを ＭＳ　ゴシックのサイズ 10、launcher のフォントのみ Meiryo UI のサイズ 20 に変更できる。変更用の名前は以下の通り
        - ホットキー ^+!W (ランチャー): launcher
        - ホットストリング flaxmakecodegui: makecodegui
        - ホットストリング flaxvirtualfolder: virtualfolder
        - ホットストリング flaxtimetable: timetable
        - ホットストリング flaxeditgesture: editgesture
        - ホットストリング flaxedittimetable: edittimetable
        - ホットストリング flaxmakeonetimepass: makeonetimepass
        - ホットストリング flaxregisteronetimepass: registeronetimepass
        - ホットストリング flaxregisterlauncher: registerlauncher
        - エクスプローラメニューの `フォルダ内の MP3 のタグを編集`: editmp3stags
        - エクスプローラメニューの `MP3 のタグを編集`:editmp3tags
