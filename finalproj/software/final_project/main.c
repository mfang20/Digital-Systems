//ECE 385 USB Host Shield code
//based on Circuits-at-home USB Host code 1.x
//to be used for ECE 385 course materials
//Revised October 2020 - Zuofu Cheng

#include <stdio.h>
#include "system.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "usb_kb/GenericMacros.h"
#include "usb_kb/GenericTypeDefs.h"
#include "usb_kb/HID.h"
#include "usb_kb/MAX3421E.h"
#include "usb_kb/transfer.h"
#include "usb_kb/usb_ch9.h"
#include "usb_kb/USB.h"
#include "vram_stuff.h"
#include <time.h>
#include <stdbool.h>

extern HID_DEVICE hid_device;

static BYTE addr = 1; 				//hard-wired USB address
const char* const devclasses[] = { " Uninitialized", " HID Keyboard", " HID Mouse", " Mass storage" };

BYTE GetDriverandReport() {
	BYTE i;
	BYTE rcode;
	BYTE device = 0xFF;
	BYTE tmpbyte;

	DEV_RECORD* tpl_ptr;
	printf("Reached USB_STATE_RUNNING (0x40)\n");
	for (i = 1; i < USB_NUMDEVICES; i++) {
		tpl_ptr = GetDevtable(i);
		if (tpl_ptr->epinfo != NULL) {
			printf("Device: %d", i);
			printf("%s \n", devclasses[tpl_ptr->devclass]);
			device = tpl_ptr->devclass;
		}
	}
	//Query rate and protocol
	rcode = XferGetIdle(addr, 0, hid_device.interface, 0, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetIdle Error. Error code: ");
		printf("%x \n", rcode);
	} else {
		printf("Update rate: ");
		printf("%x \n", tmpbyte);
	}
	printf("Protocol: ");
	rcode = XferGetProto(addr, 0, hid_device.interface, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetProto Error. Error code ");
		printf("%x \n", rcode);
	} else {
		printf("%d \n", tmpbyte);
	}
	return device;
}

void setLED(int LED) {
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE,
			(IORD_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE) | (0x001 << LED)));
}

void clearLED(int LED) {
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE,
			(IORD_ALTERA_AVALON_PIO_DATA(LEDS_PIO_BASE) & ~(0x001 << LED)));

}

void printSignedHex0(signed char value) {
	BYTE tens = 0;
	BYTE ones = 0;
	WORD pio_val = IORD_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE);
	if (value < 0) {
		setLED(11);
		value = -value;
	} else {
		clearLED(11);
	}
	//handled hundreds
	if (value / 100)
		setLED(13);
	else
		clearLED(13);

	value = value % 100;
	tens = value / 10;
	ones = value % 10;

	pio_val &= 0x00FF;
	pio_val |= (tens << 12);
	pio_val |= (ones << 8);

	IOWR_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE, pio_val);
}

void printSignedHex1(signed char value) {
	BYTE tens = 0;
	BYTE ones = 0;
	DWORD pio_val = IORD_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE);
	if (value < 0) {
		setLED(10);
		value = -value;
	} else {
		clearLED(10);
	}
	//handled hundreds
	if (value / 100)
		setLED(12);
	else
		clearLED(12);

	value = value % 100;
	tens = value / 10;
	ones = value % 10;
	tens = value / 10;
	ones = value % 10;

	pio_val &= 0xFF00;
	pio_val |= (tens << 4);
	pio_val |= (ones << 0);

	IOWR_ALTERA_AVALON_PIO_DATA(HEX_DIGITS_PIO_BASE, pio_val);
}

int setKeycode(WORD keycode, WORD keycode2, WORD keycode3)
{	int keycode_ret = 0;
	IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE_BASE, keycode);//x8002000 before
	IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE2_BASE, keycode2);//x8002000 before
	IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE3_BASE, keycode3);//x8002000 before
	if ((keycode != 0) ||(keycode2 != 0) || (keycode3 != 0)){
		keycode_ret = 1;
	}
	return keycode_ret;
}

int setScoreVal () {
	int score_val;
	score_val = IORD_ALTERA_AVALON_PIO_DATA(0x80050c0);
	return score_val;
}

int setLoseGame () {
	int lose_game;
	lose_game = IORD_ALTERA_AVALON_PIO_DATA(0x80050b0);
	return lose_game;
}

int setWinGame () {
	int win_game;
	win_game = IORD_ALTERA_AVALON_PIO_DATA(0x80050a0);
	return win_game;
}

int setResetButton () {
	int reset_button = IORD_ALTERA_AVALON_PIO_DATA(0x8005080);
	return reset_button;
}

int setStartGame () {
	int start_game = IORD_ALTERA_AVALON_PIO_DATA(0x8005070);
	return start_game;
}

int main() {
	BYTE rcode;
	BOOT_MOUSE_REPORT buf;		//USB mouse report
	BOOT_KBD_REPORT kbdbuf;

	BYTE runningdebugflag = 0;//flag to dump out a bunch of information when we first get to USB_STATE_RUNNING
	BYTE errorflag = 0; //flag once we get an error device so we don't keep dumping out state info
	BYTE device;

	printf("initializing MAX3421E...\n");
	MAX3421E_init();
	printf("initializing USB...\n");
	USB_init();

	while(1){
		//returns 1 if game wasn't completed, 0 if game was completed
		run_game();
		while(1){
			//restarts gameset
			if(setResetButton()){
				break;
				prtinf("resetting");
			}
		}
	}

	return 0;
}

int run_game(){
	int game_started = 0;
	int previous_score;
	int score_val = 0;
	int lose_game = 0;
	int win_game = 0;
	int set_stars = 0;
	bool rand_side_not_chosen = true;
	BYTE rcode;
	BOOT_MOUSE_REPORT buf;		//USB mouse report
	BOOT_KBD_REPORT kbdbuf;

	BYTE runningdebugflag = 0;//flag to dump out a bunch of information when we first get to USB_STATE_RUNNING
	BYTE errorflag = 0; //flag once we get an error device so we don't keep dumping out state info
	BYTE device;
	drawStartText(score_val);
	reset_score();
	printf("reached 208");
	while (1) {
		//printf(".");
		MAX3421E_Task();
		USB_Task();
		//usleep (500000);
		//game logic
		////switch from start screen if game started
		printf("276\n");
		previous_score = score_val;
		score_val = setScoreVal();
		//printf("%d", game_started);
		printf("start game: %d \n", setStartGame());
		if(setStartGame() == 1 && set_stars == 0){
			printf("start game");
			drawGameScreen(score_val); //remove text
			drawstars(); //remove if can't get transparent bckgrnd
			set_stars = 1;
		}
		else if(previous_score != score_val){
			update_score(score_val);
		}

		if(rand_side_not_chosen && setStartGame()){
		//time retrieval
			srand(time(0));	//timing is based on the startup for FPGA and first button pressed
			int rand_side = rand()%2;
			printf("rand_side: %d", rand_side);

			IOWR_ALTERA_AVALON_PIO_DATA(0x8005090, rand_side);
			rand_side_not_chosen = false;
		}

		if (setLoseGame()) {
			drawLoseText(score_val);
			printf("lose 270\n");
			setKeycode(00, 00, 00);
			return 0;
		}
		else if (setWinGame()) {
			drawWinText(score_val);
			printf("win 274\n");
			setKeycode(00, 00, 00);
			return 0;
		}
		else if(setResetButton()){
			printf("reset 286\n");
			reset_score();
			setKeycode(00, 00, 00);
			return 0;
		}

		if (GetUsbTaskState() == USB_STATE_RUNNING) {
			printf("223\n");
			if (!runningdebugflag) {
				runningdebugflag = 1;
				setLED(9);
				device = GetDriverandReport();
		}
		else if (device == 1) {
			printf("230\n");
				//run keyboard debug polling
				rcode = kbdPoll(&kbdbuf);
				if (rcode == hrNAK) {
					continue; //NAK means no new data
				} else if (rcode) {
					printf("Rcode: ");
					printf("%x \n", rcode);
					continue;
				}
				game_started += setKeycode(kbdbuf.keycode[0],kbdbuf.keycode[1], kbdbuf.keycode[2]);
				/*
				printf("keycodes: ");
				for (int i = 0; i < 6; i++) {
					printf("%x ", kbdbuf.keycode[i]);
				}*/
				//printSignedHex0(kbdbuf.keycode[0]);
				//printSignedHex1(kbdbuf.keycode[1]);
				//printf("\n");
			}
		}
		else if (GetUsbTaskState() == USB_STATE_ERROR) {
			printf("252\n");
			if (!errorflag) {
				errorflag = 1;
				clearLED(9);
				printf("USB Error State\n");
				//print out string descriptor here
			}
		}
		else //not in USB running state
		{
			printf("262\n");
			printf("USB task state: ");
			printf("%x\n", GetUsbTaskState());
			if (runningdebugflag) {	//previously running, reset USB hardware just to clear out any funky state, HS/FS etc
				runningdebugflag = 0;
				MAX3421E_init();
				USB_init();
			}
			errorflag = 0;
			clearLED(9);
		}


	}
	return 0;
}
