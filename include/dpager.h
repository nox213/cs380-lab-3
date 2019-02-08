#ifndef _APAGER_H_
#define _APAGER_H_

#define	ELFMAG		"\177ELF"
#define	SELFMAG		4

#define PH_TABLE_SIZE	15
#define STACK_SIZE	(PAGE_SIZE * 10)
#define STACK_START	0x10000000	
#define STACK_TOP	(STACK_START + STACK_SIZE)
#define PAGE_SIZE	4096
#define ELF_MIN_ALIGN	PAGE_SIZE
#define MAX_ARG_STRLEN	PAGE_SIZE

#define AT_VECTOR_SIZE_BASE	20
#define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_BASE + 1))

#define ELF_PAGESTART(_v) ((_v) & ~(unsigned long)(ELF_MIN_ALIGN-1))
#define ELF_PAGEOFFSET(_v) ((_v) & (ELF_MIN_ALIGN-1))
#define ELF_PAGEALIGN(_v) (((_v) + ELF_MIN_ALIGN - 1) & ~(ELF_MIN_ALIGN - 1))

#define STACK_ADD(sp, items) ((Elf64_Addr *)(sp) - (items))
#define STACK_ROUND(sp, items) \
	(((unsigned long) ((Elf64_Addr *) (sp) - (items))) &~ 15UL)
#define STACK_ALLOC(sp, len) ({ sp -= len ; sp; })

#define arch_align_stack(p) ((unsigned long)(p) & ~0xf)

void show_elf_header(Elf64_Ehdr *elf_header);
int load_elf_binary(int fd, Elf64_Ehdr *ep, int argc, char *envp[]);
void *elf_map(Elf64_Addr addr, int prot, int type, 
		int fd, Elf64_Phdr *pp);
int map_bss(unsigned long start, int prot);
int padzero(unsigned long elf_bss);
int create_elf_tables(int argc, char *envp[], Elf64_Ehdr *ep);
int init_stack(int argc, char *argv[]);
int jump_to_entry(Elf64_Addr elf_entry);
void segv_handler(int signo, siginfo_t *info, void *context);

#endif
