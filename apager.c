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

char *sp, *top, *stack_bottom;
char *arg_start, *arg_end, *env_start, *env_end;

int main(int argc, char *argv[], char *envp[])
{
	Elf64_Ehdr elf_header;
	Elf64_auxv_t *auxv;
	Elf64_Addr loader_entry;
	char **p;
	int fd;

	if (argc < 2) {
		fprintf(stderr, "./apager exe_file\n");
		exit(EXIT_FAILURE);
	}

	if ((fd = open(argv[1], O_RDWR)) < 0) {
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

	/* Check whether entry point is overlapped with loaded program */
	p = envp;
	while (*p++ != NULL)
		;
	for (auxv = (Elf64_auxv_t *) envp; auxv->a_type != AT_NULL;
			auxv++) {
		if (auxv->a_type == AT_ENTRY) {
			loader_entry = auxv->a_un.a_val;	
		}

	}

	if (elf_header.e_entry == loader_entry) {
		fprintf(stderr, "entry point is overlapped\n");
		goto out;
	}

	//show_elf_header(&elf_header);

	if (init_stack(argc, argv) < 0)
		goto out;

	load_elf_binary(fd, &elf_header, argc, envp);

out:
	close(fd);
	exit (EXIT_SUCCESS);
}

void show_elf_header(Elf64_Ehdr *ep)
{
	printf("e_ident: %s\n", ep->e_ident);
	printf("e_entry: %p\n", ep->e_entry);
	printf("e_phoff: %lu\n", ep->e_phoff);
	printf("e_shoff: %lu\n", ep->e_shoff);
	printf("sizeof Elf64_Ehdr: %lu\n", sizeof(Elf64_Ehdr));
	printf("e_ehsize: %u\n", ep->e_ehsize);
	printf("e_phentsize: %u\n", ep->e_phentsize);
	printf("e_phnum: %u\n", ep->e_phnum);
}

int load_elf_binary(int fd, Elf64_Ehdr *ep, int argc, char *envp[])
{
	Elf64_Phdr phdr;
	Elf64_Addr elf_entry;
	unsigned long elf_bss, elf_brk;
	int bss_prot = 0;
	int i;

	lseek(fd, ep->e_phoff, SEEK_SET);
	elf_bss = 0;
	elf_brk = 0;
	for (i = 0; i < ep->e_phnum; i++) {
		int elf_prot = 0, elf_flags;
		unsigned long k;
		Elf64_Addr vaddr;

		memset(&phdr, 0, sizeof(Elf64_Phdr));
		if (read(fd, &phdr, sizeof(Elf64_Phdr)) < 0) {
			fprintf(stderr, "read erorr on phdr\n");
			return -1;
		}
		
		if (phdr.p_type != PT_LOAD)
			continue;

		if (elf_brk > elf_bss) {
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

	if (map_bss(elf_bss, elf_brk, bss_prot) < 0) {
		fprintf(stderr, "bss map error\n");
		return -1;
	}
	if (elf_bss != elf_brk)
		padzero(elf_bss);

	elf_entry = ep->e_entry;

	create_elf_tables(ep, 0, argc, envp);
	jump_to_entry(elf_entry);

	return 0;
}

void *elf_map(Elf64_Addr addr, unsigned long total_size, int prot, int type, 
		int fd, Elf64_Phdr *pp)
{
	unsigned long size = pp->p_filesz + ELF_PAGEOFFSET(pp->p_vaddr);
	unsigned long off = pp->p_offset - ELF_PAGEOFFSET(pp->p_vaddr);
	addr = ELF_PAGESTART(addr);
	size = ELF_PAGEALIGN(size);

	if (!size)
		return addr;
	
	return mmap((void *) addr, size, prot, type, fd, off);
}

int map_bss(unsigned long start, unsigned long end, int prot)
{
	int type;

	start = ELF_PAGEALIGN(start);
	end = ELF_PAGEALIGN(end);
	type = MAP_FIXED | MAP_ANONYMOUS | MAP_PRIVATE;
	if (end > start) {
		return (int) mmap((void *) start, end - start, prot, type, -1, 0);
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

int create_elf_tables(Elf64_Ehdr *ep, unsigned long load_addr, 
		int argc, char *envp[])
{
	int items;
	int i;
	char *p;
	Elf64_auxv_t elf_info[AT_VECTOR_SIZE];
	Elf64_auxv_t *auxv;
	int ei_index = 0;

	memset(elf_info, 0, sizeof(elf_info));
	sp = (char *) arch_align_stack(sp);


	/* Copy Loaders AT_VECTOR */
	while (*envp++ != NULL)
		;
	for (auxv = (Elf64_auxv_t *) envp; auxv->a_type != AT_NULL;
			auxv++, ei_index++) {
		elf_info[ei_index] = *auxv;
		if (auxv->a_type == AT_PHDR)
			elf_info[ei_index].a_un.a_val = 0;

	}

	ei_index += 2;
	sp = (char *) STACK_ADD(sp, ei_index * 2);

	items = (argc + 1) + (3) + 1;
	sp = (char *) STACK_ROUND(sp, items);
	stack_bottom = sp;



	/* Now, let's put argc (and argv, envp if appropriate) on the stack */
	*((long *) sp) = (long) argc - 1;
	sp += 8;


	/* Populate list of argv pointers back to argv strings. */
	p = arg_start;
	for (i = 0; i < argc - 1; i++) {
		size_t len;

		*((unsigned long *) sp) = (unsigned long) p;
		len = strnlen(p, MAX_ARG_STRLEN);
		sp += 8;
		p += len + 1;
	}
	*((unsigned long *) sp) = NULL;
	sp += 8;


	/* Populate list of envp pointers back to envp strings. */
	p = env_start;
	for (i = 0; i < 2; i++) {
		size_t len;

		*((unsigned long *) sp) = (unsigned long) p;
		len = strnlen(p, MAX_ARG_STRLEN);
		sp += 8;
		p += len;
	}
	*((unsigned long *) sp) = NULL;
	sp += 8;

	/* Put the elf_info on the stack in the right place.  */
	memcpy(sp, elf_info, sizeof(Elf64_auxv_t) * ei_index);

	return 0;
}

int init_stack(int argc, char *argv[])
{
	size_t len;
	int i;
	int prot = 0, flags = 0;;

	prot = PROT_READ | PROT_WRITE;
	flags = MAP_FIXED | MAP_ANONYMOUS | MAP_GROWSDOWN | MAP_PRIVATE;
	sp = mmap((void *) STACK_START, STACK_SIZE, prot, flags, -1 ,0);
	if (sp == MAP_FAILED) {
		fprintf(stderr, "mmap error in %s\n", __func__);
		return -1;
	}
	memset(sp, 0, STACK_SIZE);
	sp = (Elf64_Addr) STACK_TOP;
	/* NULL pointer */
	STACK_ADD(sp, 1); 

	/* push env to stack */
	len = strnlen("ENVVAR2=2", MAX_ARG_STRLEN);
	sp -= (len + 1);
	env_end = sp;
	memcpy(sp, "ENVVAR2=2", len + 1);
	len = strnlen("ENVVAR1=1", MAX_ARG_STRLEN);
	sp -= (len + 1);
	memcpy(sp, "ENVVAR=1", len + 1);
	env_start = sp;

	/* push args to stack */
	for (i = argc - 1; i > 0; i--) {
		len = strnlen(argv[i], MAX_ARG_STRLEN);
		sp = ((char *) sp) - (len + 1);
		if (i == argc - 1)
			arg_end = sp;
		if (i == 1)
			arg_start = sp;
		memcpy(sp, argv[i], len + 1);
	}

	return 0;
}

int jump_to_entry(Elf64_Addr elf_entry)
{
	asm("movq $0, %rax");
	asm("movq $0, %rbx");
	asm("movq $0, %rcx");
	asm("movq $0, %rdx");
	asm("movq %0, %%rsp" : : "r" (stack_bottom));
	asm("jmp *%0" : : "c" (elf_entry));

	printf("never reached\n");
	return 0;
}
