- メイン機能
	- ランチャー
		- Ctrl + Alt + Shift + r で起動
		- 設定は config/launcher.fd に記述
		- エクスプローラ上で Ctrl + r -> [Launcher に登録 (R)] を選択で登録 GUI が起動
			- Name
				- そのまま。キーワード。
			- Command
				- パスや URL。
			- Type
				- 登録対象がフォルダならば LocalPath、ファイルやアプリケーションならば Application。URL も登録できるがブラウザ上で GUI は表示されないので、Command に URL を張り付ける必要がある。
			- Computer
				- 登録しているコンピュータにのみ登録する際には ThisComputer、すべてのコンピュータに同一のコマンドを登録するならば AllComputer。同じ設定ファイルでコンピュータ毎に挙動を変更できる。
	- マウスジェスチャー
		- Windows + (オプションキー) + マウスボタンで起動
		- 設定は config/gesture.fd に記述
			- [マウスボタン][オプションキー][マウスの移動経路]
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
		- GUI で設定する機能を追加する予定
	- エクスプローラ関係
		- ファイル / フォルダを Ctrl + c して、
			- Ctrl + Shift + v でショートカット作成
			- Alt + v でシンボリックリンク作成
		- ファイル / フォルダを Ctrl + Shift + v でパスをクリップボードにコピー
	- 時間割表示
		- ホットストリング flaxtimetable で起動
		- 設定は config/timetable.fd に記述
		- GUI で設定する機能を追加する予定
