#ifndef _APAGER_H_
#define _APAGER_H_

#define	ELFMAG		"\177ELF"
#define	SELFMAG		4

#define PAGE_SIZE	4096
#define ELF_MIN_ALIGN	PAGE_SIZE

#define ELF_PAGESTART(_v) ((_v) & ~(unsigned long)(ELF_MIN_ALIGN-1))
#define ELF_PAGEOFFSET(_v) ((_v) & (ELF_MIN_ALIGN-1))
#define ELF_PAGEALIGN(_v) (((_v) + ELF_MIN_ALIGN - 1) & ~(ELF_MIN_ALIGN - 1))

void show_elf_header(Elf64_Ehdr *elf_header);
int load_elf_binary(int fd, Elf64_Ehdr *ep);
int elf_map(Elf64_Addr addr, unsigned long total_size, int prot, int type, 
		int fd, Elf64_Phdr *pp);
int map_bss(unsigned long start, unsigned long end, int prot);

#endif
