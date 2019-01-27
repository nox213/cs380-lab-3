#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <elf.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>
#include "apager.h"

int main(int argc, char *argv[])
{
	Elf64_Ehdr elf_header;
	Elf64_Phdr *ph;
	int fd, poff;

	if (argc != 2) {
		fprintf(stderr, "./apager exe_file\n");
		exit(EXIT_FAILURE);
	}

	if ((fd = open(argv[1], O_RDONLY)) < 0) {
		fprintf(stderr, "Fail to open loaded file\n");
		exit(EXIT_FAILURE);
	}

	if (read(fd, &elf_header, sizeof(Elf64_Ehdr)) < 0) {
		fprintf(stderr, "read error %d\n", __LINE__);
		exit(EXIT_FAILURE);
	}

	if (memcmp(&elf_header, ELFMAG, SELFMAG) != 0) {
		fprintf(stderr, "File Format error\n");
		exit(EXIT_FAILURE);
	}

	show_elf_header(&elf_header);

	poff = elf_header.e_phoff;
	lseek(fd, 0, SEEK_SET);

	exit (EXIT_SUCCESS);
}

void show_elf_header(Elf64_Ehdr *ep)
{
	printf("e_ident: %s\n", ep->e_ident);
	printf("e_entry: %p\n", ep->e_entry);
	printf("e_phoff: %d\n", ep->e_phoff);
	printf("e_shoff: %d\n", ep->e_shoff);
	printf("sizeof Elf64_Ehdr: %u\n", sizeof(Elf64_Ehdr));
	printf("e_ehsize: %u\n", ep->e_ehsize);
	printf("e_phentsize: %u\n", ep->e_phentsize);
	printf("e_phnum: %u\n", ep->e_phnum);
}


