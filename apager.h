#ifndef _APAGER_H_
#define _APAGER_H_

#include <elf.h>

#define	ELFMAG		"\177ELF"
#define	SELFMAG		4

void show_elf_header(Elf64_Ehdr *elf_header);

#endif
