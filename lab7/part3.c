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

void wait_for_vsync(){
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    volatile int * status =(int *)0xFF20302C;

    *pixel_ctrl_ptr = 1;

    while(*status & 0x01)
		continue;
    
    return;
}  

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    int x[8], y[8], x_diag[8], y_diag[8];

    /* set front pixel buffer to start of FPGA On-chip memory */
	for (int i=0; i < 8; i++) {
        x[i] = rand() % 319;
        y[i] = rand() % 239;
        x_diag[i] = rand() % 2 * 2 - 1;
        y_diag[i] = rand() % 2 * 2 - 1;
    }
	
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the 
                                        // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer

    while (1) {
		clear_screen();
		
		for (int i = 0; i < 8; i++) {
			// draw the square
            plot_pixel(x[i], y[i], 0xFFFF);
            plot_pixel(x[i] + 1 , y[i], 0xFFFF);
            plot_pixel(x[i], y[i] + 1, 0xFFFF);
            plot_pixel(x[i] + 1, y[i] + 1, 0xFFFF);

			// draw the line to the next square
            if (i < 7) {
				draw_line(x[i], y[i], x[i+1], y[i+1], 0xFFFF);
			} else if (i == 7) {
				draw_line(x[i], y[i], x[0], y[0], 0xFFFF);
			}

            // switch if theyre at the boundary
            if (x[i] == 0) {
				x_diag[i] = 1;
			}
            else if (x[i] == 319) {
				x_diag[i] = -1;
			}
            if (y[i] == 0) {
				y_diag[i] = 1;
			}
            else if (y[i] == 239){
				y_diag[i] = -1;
			}

			// update location
            x[i]+=x_diag[i];
            y[i]+=y_diag[i];
        }   

        wait_for_vsync(); // swap
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}