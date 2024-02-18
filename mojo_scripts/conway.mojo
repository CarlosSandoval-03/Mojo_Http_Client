from python import Python
from random import randint
from memory import memset_zero, memcpy
from time import sleep

let show_change = True

struct Grid:
    var data: DTypePointer[DType.uint8]
    var rows: Int
    var cols: Int

    # Initialize taking a pointer
    fn __init__(inout self, rows: Int, cols: Int, data: DTypePointer[DType.uint8]):
        self.data = data
        self.rows = rows
        self.cols = cols

    fn __copyinit__(inout self, existing: Self):
        self.data = DTypePointer[DType.uint8].alloc(existing.rows * existing.cols)
        memcpy(self.data, existing.data, existing.rows * existing.cols)
        self.rows = existing.rows
        self.cols = existing.cols

    fn __getitem__(self, row: Int, col: Int) -> Int:
        let r = row % self.rows if row >= 0 else self.rows + row
        let c = col % self.cols if col >= 0 else self.cols + col
        return 1 if self.data.load((r * self.cols) + c) == 1 else 0 

    fn __setitem__(inout self, row: Int, col: Int, val: Int):
        self.data.store((row * self.cols) + col, val)

    fn _del_old(self):
        self.data.free()

    ## Initialize with random values
    @staticmethod
    fn rand(rows: Int, cols: Int) -> Self:
        let data = DTypePointer[DType.uint8].alloc(rows * cols)
        randint(data, rows * cols, 0, 1)
        return Self(rows, cols, data)

    @staticmethod
    fn zero(rows: Int, cols: Int) -> Self:
        let data = DTypePointer[DType.uint8].alloc(rows * cols)
        memset_zero(data, rows * cols)
        return Self(rows, cols, data)

    @staticmethod
    fn glider(rows: Int, cols: Int) -> Self:
        let data = DTypePointer[DType.uint8].alloc(rows * cols)
        memset_zero(data, rows * cols)
        var ret = Self(rows, cols, data)
        ret[10,12] = 1
        ret[11,10] = 1
        ret[11,12] = 1
        ret[12,11] = 1
        ret[12,12] = 1
        return ret

def main():
    let curses = Python.import_module("curses")
    let textpad = Python.import_module("curses.textpad")
    stdscr = curses.initscr()
    curses.start_color()
    curses.use_default_colors()
    for i in range(0, curses.COLORS):
        curses.init_pair(i, i, -1)


    let ret = stdscr.getmaxyx()
    let rows:Int = ret[0].__index__() - 2 # height
    let cols:Int = ret[1].__index__() - 5 # width

    # paint the initial grid
    def paint_grid(inout grid: Grid):
        curses.curs_set(0)
        textpad.rectangle(stdscr, 0,0, 1+rows, 1+cols)
        for row in range(0,rows):
            for col in range(0,cols):
                if grid[row, col]:
                    stdscr.addstr(row+1, col+1,  "█", curses.color_pair(1))
                else:
                    stdscr.addstr(row+1, col+1,  "░", curses.color_pair(3))
                
    var grid = Grid.rand(rows,cols)

    paint_grid(grid)
    while True:
        #sleep(.05)  
        var grid_old = grid
        for row in range(0,rows):
            for col in range(0,cols):
                let neighbors = \
                    grid_old[row-1, col-1] + \
                    grid_old[row-1, col] + \
                    grid_old[row-1, col+1] + \
                    grid_old[row, col-1] + \
                    grid_old[row, col+1] + \
                    grid_old[row+1, col-1] + \
                    grid_old[row+1, col] + \
                    grid_old[row+1, col+1]
                
                if grid_old[row, col] == 1:
                    grid[row, col] = 1 if neighbors == 2 or neighbors == 3 else 0
                else:
                    grid[row, col] = 1 if neighbors == 3 else 0

                if grid[row, col] != grid_old[row, col]:
                    if grid[row, col]:
                        stdscr.addstr(row+1, col+1,  "█", curses.color_pair(1))
                    else:
                        stdscr.addstr(row+1, col+1,  "░", curses.color_pair(5))
                elif show_change:
                    if grid[row, col]:
                        stdscr.addstr(row+1, col+1,  "█", curses.color_pair(0))

        stdscr.refresh()