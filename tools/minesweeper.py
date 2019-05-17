##左クリックもしくはEnterでセルを開く
##右クリックもしくはBackSpaceで旗を立てる、落とす
##f5でリスタート
##左クリックをしながら右クリックもしくはCtrl-Enterで周りのセルを条件付きで開く。詳しくは後述
##カーソルキーでカーソルの移動
##Ctrl-BackSpaceで周りのセルに条件付きで旗を立てる。詳しくは後述
##x,y,z,z,y,Shift,Enterを順に押すことでセルの中身を表示。詳しくは後述
##下の AutoFlag を True にするとオートモードがオンに、False でオフになる。
##オートモードをオンにすると、自明な部分がなくなるまで自動で操作してくれる。
##例えば、周囲に 2 つ爆弾があるセルの周囲にセルが 2 つしかない場合、それらのセルには旗が立てられる。
##また、周囲に 1 つ爆弾があるセルの周囲に旗がちょうど 1 つ立っている場合、立っていないセルは開かれる。
##python 側の不具合なのか、Ctrl キーが押しっぱなしになることがある。再度押すことによって解消されることを覚えておいていただきたい。


import tkinter, random, math, time
AutoFlag = True##オートモードの有効無効を決めるフラグ
FF = True##初手かどうかのフラグ
ef = True##終了時のフラグ
sf = False##中身表示のフラグ
f = [False for K in range(6)]##中身表示のフラグの一部
cellbw = 2##セル描画時に使用する変数
B1 = False##右クリックがされているかどうかのフラグ
B3 = False##左クリックがされているかどうかのフラグ
NoM = 0##爆弾の数が入る変数
NoF = 0##旗の数の変数
lineh = 20##行の高さ
tk = tkinter.Tk()
marg = 100##余白の幅
NoCX = 65##セルの横の数
NoCY = 30##セルの縦の数
cellsize = 20##セルの大きさ
NoO = NoCX * NoCY##開いていないセルの総数
##フィールドの描画
canvas = tkinter.Canvas(tk, width=marg*2+cellsize*NoCX, height=marg*2+cellsize*NoCY, bg="#eeeeee")
canvas.pack()
canvas.focus_set()

cur = [0, 0]##カーソル位置
minerate = 0.22##セルに爆弾が設置される確率
cells = None##セルの集合
class timer:##経過時間を測るためのクラス
    def starttimer(self):##タイマースタート
        import time
        self.STARTT = time.time()
        return(self.STARTT)
    def returntime(self):##スタートしてからの経過時間を返す
        import time
        self.FINISHT = time.time()
        self.ELAPSEDT = (self.FINISHT - self.STARTT)
        return(self.ELAPSEDT)
progtime = timer()##タイマー設定
class cell:##セルを表すクラス
    def __init__(self, x, y):
        self.x = x##x座標
        self.y = y##y座標
        self.mine = [False, True][random.random()<minerate]##爆弾の存在
        self.of = False##既に開かれているか
        self.mc = 0##周りの爆弾の数
        self.flag = False##旗が立っているかどうか
    def aroundcells(self):##周囲のセルを返す関数
        global cells
        hb, ht, vb, vt = -1, 2, -1, 2##水平の下限、上限、垂直の下限、上限。この先の if に引っかからなければ共に下限は自身 - 1、上限は自身 + 2 となる
        if self.x == NoCX-1:ht = 1##自身の x 座標が最大だったら > 上限値を自身 + 1 に
        elif self.x == 0:hb = 0##自身の x 座標が 0 だったら > 下限値を自身と同じ値に
        if self.y == NoCY-1:vt = 1## y に関して上と同じ操作
        elif self.y == 0:vb = 0
        return([cells[self.x + K][self.y + L] for K in range(hb, ht) for L in range(vb, vt) if K != 0 or L != 0])##自身以外の、下限値から上限値 - 1 の範囲のセルをリストにして返す
    def aroundNoF(self):##周囲の旗の数を返す関数
        global cells
        return(len([K for K in self.aroundcells() if K.flag]))
    def aroundNoO(self):##周囲の開いていないセルを返す関数
        global cells
        return(len([K for K in self.aroundcells() if not(K.of)]))
    def dcell(self, status="", fcol=""):##セルの描画関数
        X = self.x
        Y = self.y
        dposx = marg + cellsize * X
        dposy = marg + cellsize * Y
        canvas.delete(str(X)+","+str(Y))
        if not(self.of):##閉じたセルを描画
            if fcol == "":fcol = ["#d2d2d2", "#dddddd", "#bbbbbb"]
            canvas.create_rectangle((dposx, dposy), (dposx+cellsize, dposy+cellsize), fill=fcol[0], tag=str(X)+","+str(Y))
            canvas.create_polygon((dposx, dposy), (dposx+cellbw, dposy+cellbw), (dposx+cellsize-cellbw, dposy+cellbw), (dposx+cellsize-cellbw, dposy+cellsize-cellbw), (dposx+cellsize, dposy+cellsize), (dposx+cellsize, dposy), outline=fcol[1], fill=fcol[1], tag=str(X)+","+str(Y))
            canvas.create_polygon((dposx, dposy), (dposx+cellbw, dposy+cellbw), (dposx+cellbw, dposy+cellsize-cellbw), (dposx+cellsize-cellbw, dposy+cellsize-cellbw), (dposx+cellsize, dposy+cellsize), (dposx, dposy+cellsize), outline=fcol[2], fill=fcol[2], tag=str(X)+","+str(Y))
        elif self.of:##開いたセルを描画
            if fcol == "":fcol = [["#dddddd", "#eeeeee"], ["#eeeeee", "#e0e0e0"]][self.aroundNoF() == self.mc]##周囲の旗の数と周囲の爆弾の数が一致しているか (周囲の旗が正しい位置に立っている必要はない) どうかで色を決める
            canvas.create_rectangle((dposx, dposy), (dposx + cellsize, dposy + cellsize), outline=fcol[0], fill=fcol[1], tag=str(X)+","+str(Y))
            if self.mc and not(self.mine):##周囲に爆弾があり、自身が爆弾でなければ、
                canvas.create_text(dposx + cellsize / 2, dposy + cellsize / 2, text=str(self.mc), tag=("NoM", str(X)+","+str(Y)), fill=["#33ade9", "#008800", "#cc0000", "#004DB9", "#aa7722", "#008080", "#000000", "#999999"][self.mc - 1])##周囲の爆弾の数を表示
        curdr(cur)##カーソルが上書きされるためカーソルを再描画
    def minechange(self, mode="add"):
        global NoM
        self.mine = True if mode == "add" else False
        K = [-1, 1][self.mine]
        NoM += K
        for Acell in self.aroundcells():
            cells[Acell.x][Acell.y].mc += K
def cfield(event=None):##フィールドの生成
    global ef, cells, canvas, FF, NoM, NoF, NoO
    if not(ef):return(None)##終わっていなければ無を返す
    NoM = 0##爆弾の数の初期化
    NoF = 0##旗の数の初期化
    cells = [[cell(X, Y) for Y in range(NoCY)] for X in range(NoCX)]##セルの生成
    for K in range(NoCX):
        for L in range(NoCY):
            cells[K][L].dcell()##閉じたセルの描画
    K = [cells[XN][YN] for XN in range(NoCX) for YN in range(NoCY) if cells[XN][YN].mine]##爆弾を持つセルのリスト
    NoM = len(K)##爆弾の総数
    for L in K:
        for Acell in L.aroundcells():
            cells[Acell.x][Acell.y].mc += 1##周囲の mc を 1 増やす

    ##上に時間、爆弾の総数、立っている旗の総数を描画
    cx, cy = marg + cellsize * NoCX / 2, marg / 2
    infox, infoy = cellsize*(NoCX-1)/2, marg*2/5
    canvas.delete("info")
    canvas.delete("flaginfo")
    canvas.delete("timeinfo")
    canvas.create_rectangle((cx-infox, cy-infoy), (cx+infox, cy+infoy), tag="info")
    canvas.create_text((cx-30, cy-infoy+lineh), text="mine = ", tag=("info", "NoM"), anchor="w")
    canvas.create_text((cx, cy-infoy+lineh*2), text="flag = 0", tag="flaginfo")
    canvas.create_text((cx, cy-infoy+lineh*3), text="time = 00:00:00", tag="timeinfo")

    FF = True##初手フラグを立てる
    ef = False##終了フラグを落とす
    canvas.delete("pop")##終了時のポップアップのグラフィックを削除
    curdr(cur)##カーソルの描画。初期位置には戻さない
def curdr(cur):##カーソル描画関数
    canvas.delete("cur")##古いカーソルのグラフィックを削除
    canvas.create_rectangle((marg+cellsize*cur[0], marg+cellsize*cur[1]), (marg+cellsize*(cur[0]+1), marg+cellsize*(cur[1]+1)),width=3, tag="cur")##新しいカーソルを描画

##カーソル移動関数
##1行目:終わっていたら無を返す
##3行目:カーソルが移動方向の端にいたら無を返す
##4行目:カーソル位置を変更
##5行目:カーソルの描画
def curup(event):
    if ef:return(None)
    global cur
    if cur[1]==0:return(None)
    cur = [cur[0], cur[1]-1]
    curdr(cur)
def curdown(event):
    if ef:return(None)
    global cur
    if cur[1]==NoCY-1:return(None)
    cur = [cur[0], cur[1]+1]
    curdr(cur)
def curleft(event):
    if ef:return(None)
    global cur
    if cur[0]==0:return(None)
    cur = [cur[0]-1, cur[1]]
    curdr(cur)
def curright(event):
    if ef:return(None)
    global cur
    if cur[0]==NoCX-1:return(None)
    cur = [cur[0]+1, cur[1]]
    curdr(cur)

def opencell(event, acur=None, ofscur=[0, 0]):##セルを開く関数
    global FF, ef, B1, B3, f, sf, NoM, AutoFlag, NoO, cx, cy, infoy, lineh
    if event != None and event.keysym == "Return" and f[5]:##後述のコマンド用の部分
        sf = not(sf)
        f = [0, 0, 0, 0, 0, 0]
    else:
        f = [0, 0, 0, 0, 0, 0]
    acur = [cur[0]+ofscur[0], cur[1]+ofscur[1]] if acur == None else [acur[0]+ofscur[0], acur[1]+ofscur[1]]##acurが指定されていた場合その値を使う。そうでなければcurの値を参照
    if NoCX<acur[0] or NoCY<acur[1] or cells[acur[0]][acur[1]].of or cells[acur[0]][acur[1]].flag or ef:return(None)##acurが領域外か開かれているか旗が立っているか終了していれば無を返す
    if FF:##初手の場合
        Acells = cells[acur[0]][acur[1]].aroundcells()
        Acells.append(cells[acur[0]][acur[1]])
        for Acell in Acells:##開いたセル自身を含む周囲のセルについて、
            if Acell.mine:##爆弾があれば、
                cells[Acell.x][Acell.y].minechange("remove")##除去
                ##これにより、初手に開いたセルとその周囲 8 セルの爆弾を削除
        progtime.starttimer()##時間計測開始
        canvas.delete("NoM")
        cx, cy = marg + cellsize * NoCX / 2, marg / 2
        infox, infoy = cellsize*(NoCX-1)/2, marg*2/5
        canvas.create_text((cx-30, cy-infoy+lineh), text="mine = {}".format(NoM), tag=("info", "NoM"), anchor="w")
        FF = False##初手フラグを落とす
    cells[acur[0]][acur[1]].of = True
    cells[acur[0]][acur[1]].dcell()
    if cells[acur[0]][acur[1]].mine:##開いたセルに爆弾があったら
        for XN in range(len(cells)):
            for YN in range(len(cells[0])):
                if cells[XN][YN].mine:canvas.create_text(marg+(XN+0.5)*cellsize, marg+(YN+0.5)*cellsize, text="T", fill="red", tag="mine")##全ての爆弾を表示して
        ef = True##終了フラグを立て
        

        ##ポップアップを描画して
        popx = 100
        cx = marg + cellsize * NoCX / 2
        cy = marg * (3 / 2) + cellsize * NoCY
        canvas.create_rectangle((cx - popx, cy - marg*1/3), (cx + popx, cy + marg*1/3), tag="pop")
        canvas.create_text(cx, cy, text="retry : [F5]", tag="pop")
        
        return(None)##終了
    elif not(cells[acur[0]][acur[1]].mc):##周りのセルに爆弾がなかったら
        ##周囲のセルを開く
        Acells = cells[acur[0]][acur[1]].aroundcells()
        cells[acur[0]][acur[1]].of = True
        for Acell in Acells:
            opencell(None, [Acell.x, Acell.y])
    cells[acur[0]][acur[1]].of = True##ofを立てる
    NoO -= 1##開いていないセルの数を 1 減らす
    if AutoFlag:##オートモードがオンになっていたら
        LNoO = 0##開いていないセルの総数を入れる変数。while 文の最初の 1 回を通過できるように値を代入。
        LNoF = -1##旗の総数を入れる変数。
        AutoFlag = False##AutoFlag が True だと、後に呼ばれる adopencell によって無限ループに入るため、いったん落とす。
        while (LNoO != NoO or LNoF != NoF):
            LNoO = NoO##開始前の開いていないセルの総数を代入
            LNoF = NoF##開始前の旗の総数を代入
            ##すべてのセルに関して、
            for X in range(NoCX):
                for Y in range(NoCY):
                    if not(cells[X][Y].of) or not(cells[X][Y].mc):continue##開いていないか、周囲に爆弾がなければ飛ばす
                    if not(cells[X][Y].mc == cells[X][Y].aroundNoF()):##周囲の爆弾の数と周囲の旗の数が一致していなければ、
                        ##つまり、灰色になっていないセルだったら、
                        adbuiltflag(None, [X, Y])##adbuiltflag を呼ぶ
                    else:
                        if cells[X][Y].mc != cells[X][Y].aroundNoO():##周囲の爆弾の数と周囲の旗の数が一致しており、かつ周囲の爆弾の数と周囲の開いていないセルの数が一致していなければ、
                            ##つまり、灰色かつ開いていないセルを周囲に持つセルだったら
                            adopencell(None, [X, Y])##adopencell を呼ぶ
                    canvas.update()##キャンバスの更新。これはオートモードの挙動がデフラグっぽくなるのが面白いという理由でつけている。速度は大幅に落ちるため、好みでコメントアウトを推奨
        AutoFlag = True##AutoFlag を建て直す
    curdr(acur)##カーソルの描画
    B3 = False##左クリックが離されている事を明示
    
def adopencell(event, acur=""):##特殊なセルの開き方をする関数
    global B1, B3
    if acur == "":acur = cur
    if not(cells[acur[0]][acur[1]].of):return(None)##自身が開かれていなければ無を返す
    Acells = cells[acur[0]][acur[1]].aroundcells()
    if cells[acur[0]][acur[1]].mc == len([K for K in Acells if K.flag]):##周囲の旗の数と爆弾の数が一致していれば、
        for Acell in [K for K in Acells if not(K.flag) and not(K.of)]:##旗が立っておらず、開かれていない周囲のセルに関して、
            opencell(None, [Acell.x, Acell.y])##そのセルを開く
    B1 = False##B1を落とす
    B3 = False##B3を落とす
    curdr(acur)##カーソルの描画
    
def builtflag(event, acur=""):##旗を立てる
    global cells, B3, NoF
    if acur == "":acur = cur
    if ef or cells[acur[0]][acur[1]].of:return(None)##終了しているか自身が開かれていれば無を返す

    ##上の旗の数のグラフィックを削除
    canvas.delete("flaginfo")
    cx, cy = marg + cellsize * NoCX / 2, marg / 2
    infox, infoy = cellsize*(NoCX-1)/2, marg*2/5

    cells[acur[0]][acur[1]].flag = not(cells[acur[0]][acur[1]].flag)##旗の有無を反転
    if cells[acur[0]][acur[1]].flag:##旗を立てたなら、
        NoF += 1##旗の総数を増やして、
        dposx = marg+(acur[0]+0.5)*cellsize
        dposy = marg+(acur[1]+0.5)*cellsize
        canvas.create_line((marg+acur[0]*cellsize+cellbw, marg+acur[1]*cellsize+cellbw), (marg+(acur[0]+1)*cellsize-cellbw, marg+(acur[1]+1)*cellsize-cellbw), fill="#555555", tag="flag"+str(acur[0])+","+str(acur[1]))##旗を描画
    else:##旗を消したなら、
        NoF -= 1##旗の総数を減らして
        canvas.delete("flag"+str(acur[0])+","+str(acur[1]))##旗のグラフィックを削除
    canvas.create_text((cx, cy-infoy+lineh*2), text="flag = {}".format(NoF), tag="flaginfo")##上の旗の数を更新
    for Acell in [K for K in cells[acur[0]][acur[1]].aroundcells() if K.of]:##開かれている周囲のセルに関して
        Acell.dcell()##再描画 (色を適切なものにするため)
    B3 = False##B3を落とす
def adbuiltflag(event, acur=""):##適当に周囲のセルに旗を立てる
    global cur
    if acur == "":acur = cur
    if cells[acur[0]][acur[1]].aroundNoO() != cells[acur[0]][acur[1]].mc:return##周囲の開いていないセルの数と周囲の爆弾の数が一致していなければ、抜ける
    for Acell in [K for K in cells[acur[0]][acur[1]].aroundcells() if not(K.flag)]:##周囲の旗が立っていないセルに関して、
        builtflag(None, [Acell.x, Acell.y])##builtflag を呼ぶ
def chasepointer(event):##マウスカーソルの位置を検出してカーソルをそこへ移動させる
    if ef:return(None)##終了していたら無を返す
    global cur
    XN = math.floor((event.x - marg) / (cellsize))
    YN = math.floor((event.y - marg) / (cellsize))
    if 0 <= XN <= NoCX-1 and 0 <= YN <= NoCY-1:
        cur = [XN, YN]
        curdr(cur)
def b1fl(event):##B1を立てる。B3が立っていればadopencellを呼ぶ
    global B1, B3
    B1 = True
    if B3:
        adopencell(None)
def b3fl(event):##B3を立てる。B1が立っていればadopencellを呼ぶ
    global B1, B3
    B3 = True
    if B1:
        adopencell(None)
def showmine(event):##x,y,z,z,y,Shift,Enterの順で押された場合、爆弾の有無を表示
    global f
    K = event.keysym
    if K == "x":f = [1, 0, 0, 0, 0, 0]
    elif K == "y" and f[0]:f = [0, 1, 0, 0, 0, 0]
    elif K == "z" and f[1]:f = [0, 0, 1, 0, 0, 0]
    elif K == "z" and f[2]:f = [0, 0, 0, 1, 0, 0]
    elif K == "y" and f[3]:f = [0, 0, 0, 0, 1, 0]
    elif K in ["Shift_L", "Shift_R"] and f[4]:f = [0, 0, 0, 0, 0, 1]##Enterを押した際にf[5]がTrueになっていると中身表示のフラグが立つ
    else:f = [0, 0, 0, 0, 0, 0]##間違ったキーを押すとフラグを初期化
def AllSolve(event):
    pass
        
canvas.bind("<Key>", showmine)
canvas.bind("<Up>", curup)
canvas.bind("<Down>", curdown)
canvas.bind("<Left>", curleft)
canvas.bind("<Right>", curright)
canvas.bind("<Return>", opencell)
canvas.bind("<F5>", cfield)
canvas.bind("<Button-1>", b1fl)
canvas.bind("<Button-3>", b3fl)
canvas.bind("<ButtonRelease-1>", opencell)
canvas.bind("<ButtonRelease-3>", builtflag)
canvas.bind("<BackSpace>", builtflag)
canvas.bind("<Shift-Return>", builtflag)
canvas.bind("<Control-Shift-Return>", adbuiltflag)
canvas.bind("<Motion>", chasepointer)
canvas.bind("<Control-Return>", adopencell)
canvas.bind("<Control-BackSpace>", adbuiltflag)
cfield()
curdr(cur)
while True:
    canvas.update()##キャンバスの更新
    if FF:##始まっていなければ
        time.sleep(1/30)##1/30秒停止してループ
        continue
    elif ef:##終わっていれば
        time.sleep(1/6)##1/6秒停止してループ
        continue
    ##時間の更新
    canvas.delete("timeinfo")
    T = progtime.returntime()##Tは経過した秒数なので、
    S = str(int(T % 60))##60で割った余りが秒数
    M = str(int(T // 60 % 60))##60で割り、小数点以下切り捨ての値を60で割った商が分数
    H = str(int(T // (60*60)))##60*60で割り、小数点以下切り捨ての値が時数
    ##それぞれ一桁なら桁を追加して、
    if int(S) < 10:S = "0" + S
    if int(M) < 10:M = "0" + M
    if int(H) < 10:H = "0" + H
    canvas.create_text((marg+cellsize*NoCX/2, marg/2-marg*2/5+lineh*3), text="time = {}:{}:{}".format(H, M, S), tag="timeinfo")##描画

    if sf:##中身表示のフラグが立っていたら、
        col = ["white", "black"][cells[cur[0]][cur[1]].mine]##カーソル位置のセルの爆弾の有無によって色を設定し(有:黒、無:白)
        canvas.create_rectangle((1, 1), (1, 2), fill=col, outline=col, tag="showmine")##画面の左上の1pxに表示
    if NoO == NoM:##開いていないセルとフィールドの爆弾の総数が一致していたら、
        ef = True##終了フラグを立て
        ##ポップアップを描画
        popx = 100
        cx = marg + cellsize * NoCX / 2
        cy = marg * (3 / 2) + cellsize * NoCY
        canvas.create_rectangle((cx - popx, cy - marg*1/3), (cx + popx, cy + marg*1/3), tag="pop")
        canvas.create_text(cx, cy - 10, text="clear", tag="pop")
        canvas.create_text(cx, cy + 10, text="retry : [F5]", tag="pop")
    time.sleep(1/60)##1/60秒停止
    
