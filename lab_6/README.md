# Lab6: Snake Game in Microsoft Assembly

This is a simple snake game implemented in Microsoft Assembly language. The program displays '*' characters during clock interrupts in real mode on an x86 processor or a virtual machine. The game ends when the 'x' key is pressed.

## Prerequisites
To assemble and run this program, you need:
- MASM 4.0 for assembly
- LINK 3.60 for linking

## How to Run
1. Assemble the program using MASM: `masm snake.asm,,,;`
2. Link the object file using LINK: `link snake.obj`
3. Execute the program. The game will start immediately, and you can control the snake using arrow keys (left, right, up, down).
4. Press 'x' to exit the game.

## Game Controls
- Left Arrow Key: Move left
- Right Arrow Key: Move right
- Up Arrow Key: Move up
- Down Arrow Key: Move down
- 'x' Key: Exit the game

## Implementation Details
- The game utilizes clock interrupts to display '*' characters on the screen.
- The snake moves continuously in the direction specified by the arrow keys.
- The game ends when the snake hits the border or when the 'x' key is pressed.

## Credits
This project was developed as part of a laboratory exercise.

## License
This project is licensed under the [MIT License](LICENSE).

