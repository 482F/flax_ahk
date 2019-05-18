import tkinter, time, math
marg = 10
FrangeX = 600
FrangeY = 300
NoP = 64
# NoP = 10
HoP = int(FrangeY / (NoP + 2))
RoPmin = HoP if marg < HoP else marg
RoPmax = FrangeX / 6 - marg
RoPdelta = (RoPmax - RoPmin) / (NoP - 1)
RoB = 5
delay = 1/120


class Bars:
    def __init__(self, plates):
        self.ToB = [0, 0, 0]
        for plate in plates:
            self.ToB[plate.coordinate[1]] += 1
        
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

def calc_plate_pos_according_to_step(IoP, step):
    return int((math.floor((step + 2 ** IoP) / 2 ** (IoP + 1)) * ((-1) ** IoP)) % 3)

def restore_plates_state(o_plates, state):
    plates = o_plates[:]
    NoP = len(plates)
    obar = 1
    NoPs = [0, 0, 0]
    for index in range(NoP):
        IoB = calc_plate_pos_according_to_step(index, state)
        plates[index].coordinate = [NoPs[IoB], IoB]
        NoPs[IoB] += 1
    return plates

plates = [Plate([k, 0]) for k in range(NoP)]

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

def culc_current_state():
    return state



plates = restore_plates_state(plates, int((62167392000 + time.time()) / delay))
bars = Bars(plates)
drawfield()
plates[0].moveto(1)
