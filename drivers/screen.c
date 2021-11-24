#include "screen.h"
#include "ports.h"

int get_cursor_position();
void set_cursor_position(int offset);
int print_char(char c, int col, int row, char attr);
int get_position(int col, int row);
int get_row(int offset);
int get_col(int offset);


void kprint_at(char *message, int col, int row) {
    int offset;
    if (col >= 0 && row >= 0) {
        offset = get_position(col, row);
    } else {
        offset = get_cursor_position();
        row = get_row(offset);
        col = get_col(offset);
    }

    int i = 0;
    while (message[i] != 0) {
        offset = print_char(message[i++], col, row, WHITE_ON_BLACK);
        row = get_row(offset);
        col = get_col(offset);
    }
}

void kprint(char *message) {
    kprint_at(message, -1, -1);
}

void kprintln(char *message) {
    kprint_at(message, -1, -1);
    kprint_at("\n", -1, -1);
}

int print_char(char c, int col, int row, char attr) {
    unsigned char *vidmem = (unsigned char*) VIDEO_ADDRESS;
    if(!attr) attr = WHITE_ON_BLACK;
    
    if(col >= MAX_COLS) col = MAX_COLS - 1;
    if(row >= MAX_ROWS) row = MAX_ROWS - 1;

    int offset;
    if(col >= 0 && row >= 0) {
        offset = get_position(col, row);
    } else {
        offset = get_cursor_position();
    }

    if(c == '\n') {
        row = get_row(offset);
        offset = get_position(0, row + 1);
    } else {
        vidmem[offset] = c;
        vidmem[offset+1] = attr;
        offset += 2;
    }
    set_cursor_position(offset);
    return offset;

}

int get_cursor_position() {
    port_byte_out(REG_SCREEN_CTRL, 14);
    int offset = port_byte_in(REG_SCREEN_DATA) << 8;
    port_byte_out(REG_SCREEN_CTRL, 15);
    offset += port_byte_in(REG_SCREEN_DATA);
    return offset*2;
}

void set_cursor_position(int offset) {
    offset /= 2;
    port_byte_out(REG_SCREEN_CTRL, 14);
    port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
    port_byte_out(REG_SCREEN_CTRL, 15);
    port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0xff));
}

void clear_screen() {
    int screen_size = MAX_COLS * MAX_ROWS;
    int i;
    char *vidmem = (unsigned char*) VIDEO_ADDRESS;

    for(i = 0; i < screen_size; i++) {
        vidmem[i*2] = ' ';
        vidmem[i*2+1] = WHITE_ON_BLACK;
    }
    set_cursor_position(get_position(0, 0));
}

int get_position(int col, int row) {
    return 2 * (row * MAX_COLS + col);
}

int get_row(int offset) { 
    return offset / (2 * MAX_COLS); 
}

int get_col(int offset) { 
    return (offset - (get_row(offset) * 2 * MAX_COLS)) / 2; 
}