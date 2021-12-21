/*vram_stuff.c
 * text_mode_vga_color.c
 * Minimal driver for text mode VGA support
 * This is for Week 2, with color support
 *
 *  Created on: Oct 25, 2021
 *      Author: zuofu
 */

#include <system.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alt_types.h>
#include "vram_stuff.h"

void textVGAColorClr()
{
	for (int i = 0; i<(ROWS*COLUMNS) * 2; i++)
	{
		vga_ctrl->VRAM[i] = 0x00;
	}
}

void textVGADrawColorText(char* str, int x, int y, alt_u8 background, alt_u8 foreground)
{
	int i = 0;
	while (str[i]!=0)
	{
		vga_ctrl->VRAM[(y*COLUMNS + x + i) * 2] = foreground << 4 | background;
		vga_ctrl->VRAM[(y*COLUMNS + x + i) * 2 + 1] = str[i];
		i++;
	}
}

void setColorPalette (alt_u8 color, alt_u8 red, alt_u8 green, alt_u8 blue)
{
		//given 16 colors defined in the array colors, place in memory

	alt_u8 idx = color / 2;//automatically rounds down
		alt_u32* coloridx = (alt_u32*)(vga_ctrl) + 2048 + idx;
		alt_u32 temp = 0x0;

		if(!(color % 2)){ //resets
			printf("reset 45\n");
			*coloridx = temp;
		}
		//printf("color: %x\n", color);

		alt_32 redtemp = red << 9;
		alt_32 greentemp = green << 5;
		alt_32 bluetemp = blue << 1;
		temp = redtemp + greentemp + bluetemp;
		if(color % 2){
			temp = temp << 12; //if second value then left shift 12 times if this is the second
		}
		//printf("temp: %x\n", temp);
		*coloridx += temp; //the first 8 are
}


void drawGameScreen()
{
	//This is the function you call for your week 2 demo
	char score_color_string[80];
	char lives_color_string[80];
	char star_color_string[2400];
    int sfg, sbg, lfg, lbg, stfg, stbg, sx, sy, lx, ly, stx, sty;

	textVGAColorClr(); //makes screen all black
	//initialize palette
	for (int i = 0; i < 16; i++)
	{
		setColorPalette (i, colors[i].red, colors[i].green, colors[i].blue);
	}

		lfg = 15;
		lbg = 0;

		sfg = 15;
		sbg = 0;

		//stfg = 14;
		//stbg = 0;


		///draw score
		sprintf(score_color_string, "Score:");//, colors[fg].name, colors[bg].name);
		sx = 0;
		sy = 0;
		textVGADrawColorText (score_color_string, sx, sy, sbg, sfg);

		///draw lives
		sprintf(lives_color_string, "Lives:");//, colors[fg].name, colors[bg].name);
		lx = 74;
		ly = 0;
		textVGADrawColorText (lives_color_string, lx, ly, lbg, lfg);

}

void update_score(int score_val){
	char score_color_string[80];
	sprintf(score_color_string, "%d", score_val);
	int lfg = 15;
	int lbg = 0;
	int sfg = 15;
	int sbg = 0;
	int sx = 7;
	int sy = 0;
	textVGADrawColorText (score_color_string, sx, sy, sbg, sfg);
}

void reset_score(){
	char score_color_string[80];
	printf("resetting score");
	sprintf(score_color_string, "-");
	int lfg = 15;
	int lbg = 0;
	int sfg = 15;
	int sbg = 0;
	int sy = 0;
	for(int sx = 7; sx < 10; sx++){
		textVGADrawColorText (score_color_string, sx, sy, sbg, sfg);
	}
}

void drawstars(){
	char star_color_string[80];
	int fg, fg1, bg, bg1, x, y, x1, y1, x2, y2, x3, y3, sfg, sbg, x_star, y_star;
	int num_stars = 240;
	fg = 4;//red
	bg = 0;

	fg1 = 14;//yellow
	bg1 = 0;
	//set fdg, bgd for stars
	sfg = 15;//white
	sbg = 0;
	//draw stars in random spots
	for (int j=0; j<num_stars; j++){
		x_star = rand () %80;
		y_star = rand () %30;
		while (y_star <= 1){
			x_star = rand () %80;
			y_star = rand () %30;
		}
		sprintf(star_color_string, ".");
		textVGADrawColorText (star_color_string, x_star, y_star, sbg, sfg);
	}
}

void drawStartText(int score_val)
{
	//This is the function you call for your week 2 demo
	char mike_string[80], matt_string[80], color_string[80], color_string1[80], color_string2[80], color_string3[80];
	char star_color_string[80];
    int mikefg, mikebg, mattfg, mattbg, mattx, matty, mikex, mikey, fg, fg1, bg, bg1, x, y, x1, y1, x2, y2, x3, y3, sfg, sbg, num_stars, x_star, y_star;
    num_stars = 240;
    reset_score();
	textVGAColorClr();
	//initialize palette
	drawGameScreen(score_val);
	for (int i = 0; i < 16; i++)
	{
		setColorPalette (i, colors[i].red, colors[i].green, colors[i].blue);
	}
		//set fgd, bgd for text
		fg = 4;//red
		bg = 0;

		fg1 = 14;//yellow
		bg1 = 0;
		//set fdg, bgd for stars
		sfg = 15;//white
		sbg = 0;

		mikefg = 1;
		mikebg = 0;

		mattfg = 3;
		mattbg = 0;


		for (int j=0; j<num_stars; j++){
			x_star = rand () %80;
			y_star = rand () %30;
			while (y_star <= 1){
				x_star = rand () %80;
				y_star = rand () %30;
			}
			sprintf(star_color_string, ".");
			textVGADrawColorText (star_color_string, x_star, y_star, sbg, sfg);
		}

		sprintf(color_string, "X-WING ATTACK: Choose Difficulty to Start");//, colors[fg].name, colors[bg].name);
		x = 20;
		y = 1;
		textVGADrawColorText (color_string, x, y, bg, fg);


		sprintf(color_string1, "Use WASD to move, SPACE to SHOOT");//, colors[fg].name, colors[bg].name);
		x1 = 24;
		y1 = 4;
		textVGADrawColorText (color_string1, x1, y1, bg1, fg1);

		sprintf(color_string2, "Keep an eye out for POWER UPS");//, colors[fg].name, colors[bg].name);
		x2 = 25;
		y2 = 6;
		textVGADrawColorText (color_string2, x2, y2, bg1, fg1);

		sprintf(color_string3, "DON'T get HIT by ENEMIES! GOOD LUCK!");//, colors[fg].name, colors[bg].name);
		x3 = 23;
		y3 = 8;
		textVGADrawColorText (color_string3, x3, y3, bg1, fg1);

		sprintf(mike_string, "Michael Grawe");//, colors[fg].name, colors[bg].name);
		mikex= 1;
		mikey = 28;
		textVGADrawColorText (mike_string, mikex, mikey, mikebg, mikefg);

		sprintf(matt_string, "Matthew Fang");//, colors[fg].name, colors[bg].name);
		mattx = 67;
		matty = 28;
		textVGADrawColorText (matt_string, mattx, matty, mattbg, mattfg);

}
void drawLoseText(int score_val)
{
	//This is the function you call for your week 2 demo
	char color_string[80];
	char color_string1[80];
	char star_color_string[80];
    int fg, bg, x, y, x1, y1, sfg, sbg, num_stars, x_star, y_star;
    num_stars = 240;
	textVGAColorClr();
	//initialize palette
	for (int i = 0; i < 16; i++)
	{
		setColorPalette (i, colors[i].red, colors[i].green, colors[i].blue);
	}
		//set fgd, bgd for text
		fg = 4;//red
		bg = 0;

		int fg1 = 14;
		int bg1 = 0;
		//set fdg, bgd for stars
		sfg = 15;//white
		sbg = 0;
	//draw stars in random spots
	for (int j=0; j<num_stars; j++){
		x_star = rand () %80;
		y_star = rand () %30;
		while (y_star <= 1){
			x_star = rand () %80;
			y_star = rand () %30;
		}
		sprintf(star_color_string, ".");
		textVGADrawColorText (star_color_string, x_star, y_star, sbg, sfg);
	}

		sprintf(color_string, "GAME OVER: Try Again!");//, colors[fg].name, colors[bg].name);
		x = 30;
		y = 1;
		textVGADrawColorText (color_string, x, y, bg, fg);

		sprintf(color_string1, "Score: %d", score_val);//, colors[fg].name, colors[bg].name);
		x1 = 36;
		y1 = 5;
		textVGADrawColorText (color_string1, x1, y1, bg1, fg1);
}
void drawWinText(int score_val)
{
	//This is the function you call for your week 2 demo
	char color_string[80], color_string1[80];
	char star_color_string[80];
    int fg, bg, fg1, bg1, x, y, x1, y1, sfg, sbg, num_stars, x_star, y_star;
    num_stars = 240;
	textVGAColorClr();
	//initialize palette
	for (int i = 0; i < 16; i++)
	{
		setColorPalette (i, colors[i].red, colors[i].green, colors[i].blue);
	}
		//set fgd, bgd for text
		fg = 4;//red
		bg = 0;

		fg1 = 14;
		bg1 = 0;
		//set fdg, bgd for stars
		sfg = 15;//white
		sbg = 0;
	//draw stars in random spots
	for (int j=0; j<num_stars; j++){
		x_star = rand () %80;
		y_star = rand () %30;
		while (y_star <= 1){
			x_star = rand () %80;
			y_star = rand () %30;
		}
		sprintf(star_color_string, ".");
		textVGADrawColorText (star_color_string, x_star, y_star, sbg, sfg);
	}

		sprintf(color_string, "You Win!!! Nice Job");//, colors[fg].name, colors[bg].name);
		x = 30;
		y = 1;
		textVGADrawColorText (color_string, x, y, bg, fg);

		sprintf(color_string1, "Score: %d", score_val);//, colors[fg].name, colors[bg].name);
		x1 = 36;
		y1 = 5;
		textVGADrawColorText (color_string1, x1, y1, bg1, fg1);
}


