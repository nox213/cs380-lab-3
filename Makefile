OPTION = -Wall -Wl,-Ttext-segment=0x30000000

apager : apager.o
	gcc $(OPTION) -o apager $<

apager.o : apager.c apager.h
	gcc -Wall -Wextra -g -O0 -c $<

clean:
	rm -f apager.o
	rm -f apager
	rm -f dpager.o
	rm -f dpager
	rm -f hpager.o
	rm -f hpager
