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

void *sp, *top;

int main(int argc, char *argv[])
{
	Elf64_Ehdr elf_header;
	Elf64_Phdr phdr;
	int fd, poff;

	if (argc < 2) {
		fprintf(stderr, "./apager exe_file\n");
		exit(EXIT_FAILURE);
	}

	if ((fd = open(argv[1], O_RDONLY)) < 0) {
		fprintf(stderr, "Fail to open loaded file\n");
		goto out;
	}

	if (read(fd, &elf_header, sizeof(Elf64_Ehdr)) < 0) {
		fprintf(stderr, "read error %d\n", __LINE__);
		goto out;
	}

	if (memcmp(&elf_header, ELFMAG, SELFMAG) != 0) {
		fprintf(stderr, "File format error\n");
		goto out;
	}

	show_elf_header(&elf_header);

	if (init_stack(argc, argv) < 0)
		goto out;

	printf("asdf\n");
	load_elf_binary(fd, &elf_header);

out:
	close(fd);
	free(top);
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

int load_elf_binary(int fd, Elf64_Ehdr *ep)
{
	Elf64_Phdr phdr;
	Elf64_Addr elf_entry;
	unsigned long elf_bss, elf_brk;
	int bss_prot = 0;
	int i;

	memset(&phdr, 0, sizeof(Elf64_Phdr));
	lseek(fd, ep->e_phoff, SEEK_SET);
	elf_bss = 0;
	elf_brk = 0;
	for (i = 0; i < ep->e_phnum; i++) {
		int elf_prot = 0, elf_flags;
		unsigned long k;
		Elf64_Addr vaddr;

		if (read(fd, &phdr, sizeof(Elf64_Phdr)) < 0) {
			fprintf(stderr, "read erorr on phdr\n");
			return -1;
		}
		
		if (phdr.p_type != PT_LOAD)
			continue;

		if (elf_brk > elf_bss) {
			unsigned long nbyte;
			
			if (map_bss(elf_bss, elf_brk, bss_prot) < 0) {
				fprintf(stderr, "map_bss error\n");
				return -1;
			}

			padzero(elf_bss);
		}

		if (phdr.p_flags & PF_R)
			elf_prot |= PROT_READ;
		if (phdr.p_flags & PF_W)
			elf_prot |= PROT_WRITE;
		if (phdr.p_flags & PF_X)
			elf_prot |= PROT_EXEC;
		
		elf_flags = MAP_PRIVATE | MAP_FIXED | MAP_EXECUTABLE;

		vaddr = phdr.p_vaddr;

		if (elf_map(vaddr, 0, elf_prot, elf_flags, fd, &phdr) < 0) {
			fprintf(stderr, "elf_map error\n");
			return -1;
		}
		
		k = phdr.p_vaddr + phdr.p_filesz;
		if (k > elf_bss)
			elf_bss = k;

		k = phdr.p_vaddr + phdr.p_memsz;
		if (k > elf_brk) {
			bss_prot = elf_prot;
			elf_brk = k;
		}
	}

	map_bss(elf_bss, elf_brk, bss_prot);
	padzero(elf_bss);

	elf_entry = ep->e_entry;

	return 0;
}

int elf_map(Elf64_Addr addr, unsigned long total_size, int prot, int type, 
		int fd, Elf64_Phdr *pp)
{
	Elf64_Addr map_addr;
	unsigned long size = pp->p_filesz + ELF_PAGEOFFSET(pp->p_vaddr);
	unsigned long off = pp->p_offset - ELF_PAGEOFFSET(pp->p_vaddr);
	addr = ELF_PAGESTART(addr);
	size = ELF_PAGEALIGN(size);

	if (!size)
		return addr;
	
	return mmap(addr, size, prot, type, fd, off);
}

int map_bss(unsigned long start, unsigned long end, int prot)
{
	int size;
	int type;

	start = ELF_PAGEALIGN(start);
	size = end - ELF_PAGEALIGN(end);
	end = ELF_PAGEALIGN(end);
	type = MAP_FIXED | MAP_ANONYMOUS | MAP_PRIVATE;
	if (end > start) {
		return mmap(end, size, prot, type, -1, 0);
	}

	return 0;
}

int padzero(unsigned long elf_bss)
{
	unsigned long nbyte;

	nbyte = ELF_PAGEOFFSET(elf_bss);
	if (nbyte) {
		nbyte = ELF_MIN_ALIGN - nbyte;
		memset((void *) elf_bss, 0, nbyte);
	}

	return 0;
}

int create_elf_tables(Elf64_Ehdr *ep, unsigned long load_addr)
{
	arch_align_stack(sp);
}

int init_stack(int argc, char *argv[])
{
	size_t len;
	int i;

	if ((sp = malloc(STACK_SIZE)) == NULL) {
		fprintf("malloc error in %s\n", __func__);
		return -1;
	}
	top = sp;

	sp = ((char *) sp) + STACK_SIZE;
	/* NULL pointer */
	STACK_ADD(sp, 1); 

	/* push env to stack */
	len = strlen("2");
	sp = ((char *) sp) - len;
	memcpy(sp, "2", len);
	len = strlen("1");
	sp = ((char *) sp) - len;
	memcpy(sp, "1", len);

	/* push args to stack */
	for (i = argc - 1; i >= 0; i--) {
		len = strlen(argv[i]);
		sp = ((char *) sp) - len;
		memcpy(sp, argv[i], len);
	}

	return 0;
}
