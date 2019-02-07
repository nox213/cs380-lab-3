OPTION = -Wall -Wl,-Ttext-segment=0x30000000
OPTION2 = -Wall -Wextra -g -O0 -I ./include

all : apager dpager hpager

apager : apager.o
	gcc $(OPTION) -o apager $<

apager.o : ./src/apager.c ./include/apager.h
	gcc $(OPTION2) -c $<

dpager : dpager.o
	gcc $(OPTION) -o dpager $<

dpager.o : ./src/dpager.c ./include/dpager.h
	gcc  $(OPTION2) -c $<

hpager : hpager.o
	gcc $(OPTION) -o hpager $<

hpager.o : ./src/hpager.c ./include/hpager.h
	gcc $(OPTION2) -c $<

test:
	gcc test1.c -o test1 -static
	gcc test2.c -o test2 -static
	gcc test3.c -o test3 -static

clean:
	rm -f apager.o
	rm -f apager
	rm -f dpager.o
	rm -f dpager
	rm -f hpager.o
	rm -f hpager
	rm -f test1
	rm -f test2
	rm -f test3
