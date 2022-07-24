#include <stdio.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"

void returnStuff(){

	int a = IORD_ALTERA_AVALON_PIO_DATA(INPUT1_BASE);
	int b = IORD_ALTERA_AVALON_PIO_DATA(INPUT2_BASE);
	int c = IORD_ALTERA_AVALON_PIO_DATA(INPUT3_BASE);
	int d = IORD_ALTERA_AVALON_PIO_DATA(INPUT4_BASE);


	if (a == 4){
		IOWR_ALTERA_AVALON_PIO_DATA(OUTPUT_X_BASE, 7);
		IOWR_ALTERA_AVALON_PIO_DATA(OUTPUT_Y_BASE, 6);
		IOWR_ALTERA_AVALON_PIO_DATA(READY_BASE, 1);
	} else {
		IOWR_ALTERA_AVALON_PIO_DATA(OUTPUT_X_BASE, 3);
		IOWR_ALTERA_AVALON_PIO_DATA(OUTPUT_Y_BASE, 2);
		IOWR_ALTERA_AVALON_PIO_DATA(READY_BASE, 1);
	}


}
void returnStuff2(){
	int a = IORD_ALTERA_AVALON_PIO_DATA(INPUT1_BASE);
	int b = IORD_ALTERA_AVALON_PIO_DATA(INPUT2_BASE);
	int c = IORD_ALTERA_AVALON_PIO_DATA(INPUT3_BASE);
	int d = IORD_ALTERA_AVALON_PIO_DATA(INPUT4_BASE);


	if (a == 4){
		IOWR_ALTERA_AVALON_PIO_DATA(OUTPUT_X_BASE, 6);
		IOWR_ALTERA_AVALON_PIO_DATA(OUTPUT_Y_BASE, 3);
		IOWR_ALTERA_AVALON_PIO_DATA(READY_BASE, 0);
	} else {
		IOWR_ALTERA_AVALON_PIO_DATA(OUTPUT_X_BASE, 3);
		IOWR_ALTERA_AVALON_PIO_DATA(OUTPUT_Y_BASE, 2);
		IOWR_ALTERA_AVALON_PIO_DATA(READY_BASE, 0);
	}
}

void clear(){
	IOWR_ALTERA_AVALON_PIO_DATA(OUTPUT_X_BASE, 0);
	IOWR_ALTERA_AVALON_PIO_DATA(OUTPUT_Y_BASE, 0);
	IOWR_ALTERA_AVALON_PIO_DATA(READY_BASE, 0);
}

int main() {
	printf("Hello from Shit!\n");

	while (1){
		int x = IORD_ALTERA_AVALON_PIO_DATA(ENABLE_BASE);
		if (x == 1) returnStuff();
		else clear();

	}

}

