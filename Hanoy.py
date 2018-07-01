import tkinter, time
marg = 10
FrangeX = 600
FrangeY = 300
NoP = 64
HoP = int(FrangeY / (NoP + 2))
RoPmin = HoP if marg < HoP else marg
RoPmax = FrangeX / 6 - marg
RoPdelta = (RoPmax - RoPmin) / (NoP - 1)
RoB = 5
delay = 1/120


class Bars:
    def __init__(self):
        self.ToB = [NoP, 0, 0]
        
class Plate:
    def __init__(self, coordinate):
        self.coordinate = coordinate
        self.index = coordinate[0]
        self.size = int(RoPmax - RoPdelta * coordinate[0])
    def draw(self):
        r, c = self.coordinate
        canvas.create_rectangle(int(FrangeX / 6 * (1 + c * 2) - self.size + marg), FrangeY - marg - HoP * (r + 1), int(FrangeX / 6 * (1 + c * 2) + self.size + marg), FrangeY - marg - HoP * r, fill="#ffffff", tag="plate")
    def moveto(self, IoB):
        k = [IoB, self.coordinate[1]]
        if 0 not in k:nIoB = 0
        elif 1 not in k:nIoB = 1
        elif 2 not in k:nIoB = 2
        if NoP != self.index + 1:
            plates[self.index + 1].moveto(nIoB)
        bars.ToB[self.coordinate[1]] -= 1
        self.coordinate = [bars.ToB[IoB], IoB]
        bars.ToB[IoB] += 1
        drawfield()
        if NoP != self.index + 1:
            plates[self.index + 1].moveto(IoB)

plates = [Plate([k, 0]) for k in range(NoP)]
bars = Bars()

tk = tkinter.Tk()
canvas = tkinter.Canvas(tk, width=FrangeX + marg * 2, height = FrangeY + marg * 2, bg="#ffffff")
canvas.pack()
canvas.focus_set()

def drawbar():
    for k in range(3):
        canvas.create_rectangle(int(FrangeX / 6 * (1 + k * 2) - RoB + marg), marg, int(FrangeX / 6 * (1 + k * 2) + RoB + marg), FrangeY - marg, fill="#000000", tag="bar")

def drawfield():
    canvas.delete("plate")
    canvas.delete("bar")
    time.sleep(delay)
    drawbar()
    for plate in plates:
        plate.draw()
    canvas.update()

plates[0].moveto(2)
