# Verilog Maze

A maze game with a random walker using the FPGA. Works on [Xilinx Nexys 3 board](https://digilent.com/reference/programmable-logic/nexys-3/start). Made with [Zihan Liu](https://www.linkedin.com/in/zihan-liu-a6071817b)!

![Maze](https://raw.githubusercontent.com/utsavm9/VerilogMaze/main/maze.jpg)

## Modules
* Joystick
* SevenSegment
* Debouncer
* RandomNumGen
* VGA and Top-level module


## References

* Maze image generated from https://keesiemeijer.github.io/maze-generator/
* VGA: https://embeddedthoughts.com/2016/12/09/yoshis-nightmare-fpga-based-video-game/, https://github.com/AndreasKaratzas/graphics-driver/blob/main/vga_controller.v
* Random Number Generator: https://www.nandland.com/vhdl/modules/lfsr-linear-feedback-shift-register.html
* Joystick Module: https://digilent.com/reference/_media/reference/pmod/pmodjstk/pmodjstk_demo_verilog.zip
