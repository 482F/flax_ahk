機能
	関数
		RevStr(Str)
			Str を反転させて返す
		EvalForm(Formula)
			引数 Formula に計算式 (四則演算と冪乗) を渡すと計算結果を返す (特定の式の結果が誤っている)
		ShowVol(marg)
			画面右下から marg だけ離れた位置に現在の音量を表示 (未完成)
		alarmcheck()
			alarm.ini を読み、設定された動作を実行
		retpath(name)
			A_ComputerName に基づき、name のパスを返す
			A_ComputerName が WINDOWS-O3L7BIO、name が document の場合、E:\document\ を返す
		screenshot(SX,SY,EX,EY,destination,Flag=2)
			座標 (SX, SY) から、座標 (EX, EY) の範囲のスクリーンショットを、SnapCrab によって撮る。SnapCrab 側の [指定範囲のキャプチャ] のホットキーは Ctrl + Shift + F12
			撮ったスクリーンショットは destination に配置される
			Flag は FileMove の Flag の設定
	ホットストリング
		flaxcalc
			画面右下にテキスト入力欄を出し、そこに計算式 (四則演算と冪乗) を入力すると結果を Send する。関数 EvalForm によって動作しているため、一部の式に対して不正確な値を返す
		flaxrapidlb
			左クリックの連打。Esc で終了
		flaxwindowsetgame
			アクティブウィンドウを 1280x720 にし、画面右上に移動
		flaxwindowsetmovie
			アクティブウィンドウをモニタサイズ - 1280x720 にし、画面左下に移動
		flaxwindowalwaysontop
			アクティブウィンドウを常時最前面表示化
		flaxwindowdisable
			アクティブウィンドウを操作不可能に
		flaxwindowenable
			アクティブウィンドウを操作可能に
		flaxwindowmoviemode
			アクティブウィンドウに対して flaxwindowsetmovie、flaxwindowalwaysontopを施し、タイトルバーなどを非表示にする
		flaxtime
			現在時刻を Send
		flaxdate
			現在の日付を yyyy/mm/dd 形式で Send
		flaxday
			現在の曜日を Send
		flaxspy
			AU3_Spy.exe を起動
		flaxgetprocessname
			アクティブウィンドウのプロセスネームをクリップボードに保存
		flaxmonitoroff
			スクリーンセーバー ブランクを起動
		flaxreload
			スクリプトの再読み込み
		flaxexit
			スクリプトの終了
		flaxeditscript
			スクリプトの編集を既定のテキストエディターで開始
		flaxkeyhistory
			キーヒストリーを表示
		flaxlisthotkeys
			登録されているホットキーの一覧を表示
		flaxlistvars
			スクリプト中の変数とその値を表示
		flaxmakecodegui
			GUI を表示し、 Clear Text と Seed、その他のチェックボックスに基づいた暗号文を Send
			生成された暗号文を Clear Text に入力し、生成時の Seed を与えることで復号ができる
		flaxmakecode
			flaxmakecodegui の非 GUI 版。複合プロセスが不正確。
		flaxsendclip
			クリップボードの中身を Send
		flaxrestartexplorer
			エクスプローラのプロセスを終了し、再起動する
		flaxalc
			ALC NetAcademy 2 のユニット一覧へのアクセスを簡便化する
		flaxcopyreg
			選択範囲をコピーし、キーワードと対応付けて register.ini に書き込む
		flaxpastereg
			キーワードに対応した内容を Send
	ホットキー
		Ctrl + Alt + Shift + W
			汎用プログラムランチャー。同じキーワードに対して PC 毎に異なる動作をさせることができる
		Ctrl + Enter
			カーソル位置の次の行に空行を挿入。文章入力中のみ動作
		Ctrl + VolUp、Ctrl + VolDown
			ボリュームを 5 上下
		Shift + VolUp、Shift + VolDown
			ボリュームを 1 上下
		Alt + Shift + M、Ctrl + Volume_Mute
			アクティブウィンドウをミュート、非ミュート
		無変換 + j
			↓
		無変換 + k
			↑
		無変換 + h
			←
		無変換 + l
			→
		無変換 + u
			Ctrl + z
		無変換 + Space
			Enter
		無変換 + x
			Delete