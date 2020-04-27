#include <stdlib.h>
#include <stdbool.h>

volatile int pixel_buffer_start;

void plot_pixel(int x, int y, short int line_color) {
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

void clear_screen() {
    for (int x = 0; x < 320; x++) {
        for (int y = 0; y < 240; y++) {
            plot_pixel(x, y, 0x0000);
        }
    }
}

void swap(int* val1, int* val2) {
    int temp = *val1;
    *val1 = *val2;
    *val2 = temp;
}

void draw_line(int x0, int y0, int x1, int y1, short int color) {
    bool is_steep = abs(y1-y0) > abs(x1-x0);
    if (is_steep) {
        swap(&x0, &y0);
        swap(&x1, &y1);
    }
    if (x0 > x1) {
        swap(&x0, &x1);
        swap(&y0, &y1);
    }
    
    int deltax = x1 - x0;
    int deltay = abs(y1-y0);
    int error = -(deltax / 2);
    int y_step = 0;
    int y = y0;
    
    if (y0 < y1) {
        y_step = 1;
    }
    else {
        y_step = -1;
    }
    
    for (int x = x0; x < x1; x++) {
        if (is_steep) {
            plot_pixel(y, x, color);
        }
        else {
            plot_pixel(x, y, color);
        }
        error+=deltay;
        if (error >= 0) {
            y = y + y_step;
            error-=deltax;
        }
    }
}

void wait(){
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    volatile int * status =(int *)0xFF20302C;

    *pixel_ctrl_ptr = 1;

    while(*status & 0x01)
		continue;
    
    return;
}  

int main(void) {
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	pixel_buffer_start = *pixel_ctrl_ptr;
	
    clear_screen();
	
	int y = 0;
	bool going_down = true;
	
	while(true) {
		draw_line(0, y, 320, y, 0x001F);
		wait();
		
		if (going_down) {
			y++;
			if (y == 240) {
				going_down = false;
			}
			draw_line(0, y-1, 320, y-1, 0x0000);
		} else {
			y--;
			if (y == 0) {
				going_down = true;
			}
			draw_line(0, y+1, 320, y+1, 0x0000);
		}
	}
    
    return 0;
}