	.file	"apager.c"
	.comm	sp,8,8
	.comm	top,8,8
	.comm	stack_bottom,8,8
	.comm	arg_start,8,8
	.comm	arg_end,8,8
	.comm	env_start,8,8
	.comm	env_end,8,8
	.section	.rodata
.LC0:
	.string	"./apager exe_file\n"
.LC1:
	.string	"Fail to open loaded file\n"
.LC2:
	.string	"read error %d\n"
.LC3:
	.string	"\177ELF"
.LC4:
	.string	"File format error\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	addq	$-128, %rsp
	movl	%edi, -100(%rbp)
	movq	%rsi, -112(%rbp)
	movq	%rdx, -120(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	cmpl	$1, -100(%rbp)
	jg	.L2
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$18, %edx
	movl	$1, %esi
	movl	$.LC0, %edi
	call	fwrite
	movl	$1, %edi
	call	exit
.L2:
	movq	-112(%rbp), %rax
	addq	$8, %rax
	movq	(%rax), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	open
	movl	%eax, -84(%rbp)
	cmpl	$0, -84(%rbp)
	jns	.L3
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$25, %edx
	movl	$1, %esi
	movl	$.LC1, %edi
	call	fwrite
	jmp	.L4
.L3:
	leaq	-80(%rbp), %rcx
	movl	-84(%rbp), %eax
	movl	$64, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	read
	testq	%rax, %rax
	jns	.L5
	movq	stderr(%rip), %rax
	movl	$31, %edx
	movl	$.LC2, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf
	jmp	.L4
.L5:
	leaq	-80(%rbp), %rax
	movl	$4, %edx
	movl	$.LC3, %esi
	movq	%rax, %rdi
	call	memcmp
	testl	%eax, %eax
	je	.L6
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$18, %edx
	movl	$1, %esi
	movl	$.LC4, %edi
	call	fwrite
	jmp	.L4
.L6:
	leaq	-80(%rbp), %rax
	movq	%rax, %rdi
	call	show_elf_header
	movq	-112(%rbp), %rdx
	movl	-100(%rbp), %eax
	movq	%rdx, %rsi
	movl	%eax, %edi
	call	init_stack
	testl	%eax, %eax
	js	.L9
	movq	-120(%rbp), %rcx
	movl	-100(%rbp), %edx
	leaq	-80(%rbp), %rsi
	movl	-84(%rbp), %eax
	movl	%eax, %edi
	call	load_elf_binary
	jmp	.L4
.L9:
	nop
.L4:
	movl	-84(%rbp), %eax
	movl	%eax, %edi
	call	close
	movl	$0, %edi
	call	exit
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.section	.rodata
.LC5:
	.string	"e_ident: %s\n"
.LC6:
	.string	"e_entry: %p\n"
.LC7:
	.string	"e_phoff: %lu\n"
.LC8:
	.string	"e_shoff: %lu\n"
.LC9:
	.string	"sizeof Elf64_Ehdr: %lu\n"
.LC10:
	.string	"e_ehsize: %u\n"
.LC11:
	.string	"e_phentsize: %u\n"
.LC12:
	.string	"e_phnum: %u\n"
	.text
	.globl	show_elf_header
	.type	show_elf_header, @function
show_elf_header:
.LFB3:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rsi
	movl	$.LC5, %edi
	movl	$0, %eax
	call	printf
	movq	-8(%rbp), %rax
	movq	24(%rax), %rax
	movq	%rax, %rsi
	movl	$.LC6, %edi
	movl	$0, %eax
	call	printf
	movq	-8(%rbp), %rax
	movq	32(%rax), %rax
	movq	%rax, %rsi
	movl	$.LC7, %edi
	movl	$0, %eax
	call	printf
	movq	-8(%rbp), %rax
	movq	40(%rax), %rax
	movq	%rax, %rsi
	movl	$.LC8, %edi
	movl	$0, %eax
	call	printf
	movl	$64, %esi
	movl	$.LC9, %edi
	movl	$0, %eax
	call	printf
	movq	-8(%rbp), %rax
	movzwl	52(%rax), %eax
	movzwl	%ax, %eax
	movl	%eax, %esi
	movl	$.LC10, %edi
	movl	$0, %eax
	call	printf
	movq	-8(%rbp), %rax
	movzwl	54(%rax), %eax
	movzwl	%ax, %eax
	movl	%eax, %esi
	movl	$.LC11, %edi
	movl	$0, %eax
	call	printf
	movq	-8(%rbp), %rax
	movzwl	56(%rax), %eax
	movzwl	%ax, %eax
	movl	%eax, %esi
	movl	$.LC12, %edi
	movl	$0, %eax
	call	printf
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	show_elf_header, .-show_elf_header
	.section	.rodata
.LC13:
	.string	"read erorr on phdr\n"
.LC14:
	.string	"map_bss error\n"
.LC15:
	.string	"vaddr: %p\n"
.LC16:
	.string	"elf_map error\n"
.LC17:
	.string	"bss map error\n"
	.text
	.globl	load_elf_binary
	.type	load_elf_binary, @function
load_elf_binary:
.LFB4:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$160, %rsp
	movl	%edi, -132(%rbp)
	movq	%rsi, -144(%rbp)
	movl	%edx, -136(%rbp)
	movq	%rcx, -152(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, -120(%rbp)
	leaq	-64(%rbp), %rax
	movl	$56, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	memset
	movq	-144(%rbp), %rax
	movq	32(%rax), %rax
	movq	%rax, %rcx
	movl	-132(%rbp), %eax
	movl	$0, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	lseek
	movq	$0, -104(%rbp)
	movq	$0, -96(%rbp)
	movl	$0, -116(%rbp)
	jmp	.L12
.L24:
	movl	$0, -112(%rbp)
	leaq	-64(%rbp), %rcx
	movl	-132(%rbp), %eax
	movl	$56, %edx
	movq	%rcx, %rsi
	movl	%eax, %edi
	call	read
	testq	%rax, %rax
	jns	.L13
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$19, %edx
	movl	$1, %esi
	movl	$.LC13, %edi
	call	fwrite
	movl	$-1, %eax
	jmp	.L26
.L13:
	movl	-64(%rbp), %eax
	cmpl	$1, %eax
	jne	.L28
	movq	-96(%rbp), %rax
	cmpq	-104(%rbp), %rax
	jbe	.L17
	movl	-120(%rbp), %edx
	movq	-96(%rbp), %rcx
	movq	-104(%rbp), %rax
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	map_bss
	testl	%eax, %eax
	jns	.L18
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$14, %edx
	movl	$1, %esi
	movl	$.LC14, %edi
	call	fwrite
	movl	$-1, %eax
	jmp	.L26
.L18:
	movq	-104(%rbp), %rax
	movq	%rax, %rdi
	call	padzero
.L17:
	movl	-60(%rbp), %eax
	andl	$4, %eax
	testl	%eax, %eax
	je	.L19
	orl	$1, -112(%rbp)
.L19:
	movl	-60(%rbp), %eax
	andl	$2, %eax
	testl	%eax, %eax
	je	.L20
	orl	$2, -112(%rbp)
.L20:
	movl	-60(%rbp), %eax
	andl	$1, %eax
	testl	%eax, %eax
	je	.L21
	orl	$4, -112(%rbp)
.L21:
	movl	$4114, -108(%rbp)
	movq	-48(%rbp), %rax
	movq	%rax, -88(%rbp)
	movq	stderr(%rip), %rax
	movq	-88(%rbp), %rdx
	movl	$.LC15, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf
	leaq	-64(%rbp), %rdi
	movl	-132(%rbp), %esi
	movl	-108(%rbp), %ecx
	movl	-112(%rbp), %edx
	movq	-88(%rbp), %rax
	movq	%rdi, %r9
	movl	%esi, %r8d
	movl	$0, %esi
	movq	%rax, %rdi
	call	elf_map
	testl	%eax, %eax
	jns	.L22
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$14, %edx
	movl	$1, %esi
	movl	$.LC16, %edi
	call	fwrite
	movl	$-1, %eax
	jmp	.L26
.L22:
	movq	-48(%rbp), %rdx
	movq	-32(%rbp), %rax
	addq	%rdx, %rax
	movq	%rax, -80(%rbp)
	movq	-80(%rbp), %rax
	cmpq	-104(%rbp), %rax
	jbe	.L23
	movq	-80(%rbp), %rax
	movq	%rax, -104(%rbp)
.L23:
	movq	-48(%rbp), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movq	%rax, -80(%rbp)
	movq	-80(%rbp), %rax
	cmpq	-96(%rbp), %rax
	jbe	.L16
	movl	-112(%rbp), %eax
	movl	%eax, -120(%rbp)
	movq	-80(%rbp), %rax
	movq	%rax, -96(%rbp)
	jmp	.L16
.L28:
	nop
.L16:
	addl	$1, -116(%rbp)
.L12:
	movq	-144(%rbp), %rax
	movzwl	56(%rax), %eax
	movzwl	%ax, %eax
	cmpl	-116(%rbp), %eax
	jg	.L24
	movl	-120(%rbp), %edx
	movq	-96(%rbp), %rcx
	movq	-104(%rbp), %rax
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	map_bss
	testl	%eax, %eax
	jns	.L25
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$14, %edx
	movl	$1, %esi
	movl	$.LC17, %edi
	call	fwrite
	movl	$-1, %eax
	jmp	.L26
.L25:
	movq	-104(%rbp), %rax
	movq	%rax, %rdi
	call	padzero
	movq	-144(%rbp), %rax
	movq	24(%rax), %rax
	movq	%rax, -72(%rbp)
	movq	-152(%rbp), %rcx
	movl	-136(%rbp), %edx
	movq	-144(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	create_elf_tables
	movq	-72(%rbp), %rax
	movq	%rax, %rdi
	call	jump_to_entry
	movq	-72(%rbp), %rax
.L26:
	movq	-8(%rbp), %rsi
	xorq	%fs:40, %rsi
	je	.L27
	call	__stack_chk_fail
.L27:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	load_elf_binary, .-load_elf_binary
	.section	.rodata
.LC18:
	.string	"%d\n"
	.text
	.globl	elf_map
	.type	elf_map, @function
elf_map:
.LFB5:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movl	%edx, -36(%rbp)
	movl	%ecx, -40(%rbp)
	movl	%r8d, -44(%rbp)
	movq	%r9, -56(%rbp)
	movq	-56(%rbp), %rax
	movq	32(%rax), %rdx
	movq	-56(%rbp), %rax
	movq	16(%rax), %rax
	andl	$4095, %eax
	addq	%rdx, %rax
	movq	%rax, -16(%rbp)
	movq	-56(%rbp), %rax
	movq	8(%rax), %rdx
	movq	-56(%rbp), %rax
	movq	16(%rax), %rax
	andl	$4095, %eax
	subq	%rax, %rdx
	movq	%rdx, %rax
	movq	%rax, -8(%rbp)
	andq	$-4096, -24(%rbp)
	movq	-16(%rbp), %rax
	addq	$4095, %rax
	andq	$-4096, %rax
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, %rsi
	movl	$.LC18, %edi
	movl	$0, %eax
	call	printf
	cmpq	$0, -16(%rbp)
	jne	.L30
	movq	-24(%rbp), %rax
	jmp	.L31
.L30:
	movq	-8(%rbp), %r8
	movq	-24(%rbp), %rax
	movl	-44(%rbp), %edi
	movl	-40(%rbp), %ecx
	movl	-36(%rbp), %edx
	movq	-16(%rbp), %rsi
	movq	%r8, %r9
	movl	%edi, %r8d
	movq	%rax, %rdi
	call	mmap
.L31:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	elf_map, .-elf_map
	.globl	map_bss
	.type	map_bss, @function
map_bss:
.LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movl	%edx, -36(%rbp)
	movq	-24(%rbp), %rax
	addq	$4095, %rax
	andq	$-4096, %rax
	movq	%rax, -24(%rbp)
	movq	-32(%rbp), %rax
	addq	$4095, %rax
	andq	$-4096, %rax
	movq	%rax, -32(%rbp)
	movl	$50, -4(%rbp)
	movq	-32(%rbp), %rax
	cmpq	-24(%rbp), %rax
	jbe	.L33
	movq	-24(%rbp), %rax
	movl	-4(%rbp), %ecx
	movl	-36(%rbp), %edx
	movl	$0, %r9d
	movl	$-1, %r8d
	movl	$4096, %esi
	movq	%rax, %rdi
	call	mmap
	jmp	.L34
.L33:
	movl	$0, %eax
.L34:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	map_bss, .-map_bss
	.globl	padzero
	.type	padzero, @function
padzero:
.LFB7:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	-24(%rbp), %rax
	andl	$4095, %eax
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L36
	movl	$4096, %eax
	subq	-8(%rbp), %rax
	movq	%rax, -8(%rbp)
	movq	-24(%rbp), %rax
	movq	-8(%rbp), %rdx
	movl	$0, %esi
	movq	%rax, %rdi
	call	memset
.L36:
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	padzero, .-padzero
	.section	.rodata
.LC19:
	.string	"ei_index: %d\n"
	.text
	.globl	create_elf_tables
	.type	create_elf_tables, @function
create_elf_tables:
.LFB8:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$768, %rsp
	movq	%rdi, -744(%rbp)
	movq	%rsi, -752(%rbp)
	movl	%edx, -756(%rbp)
	movq	%rcx, -768(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, -728(%rbp)
	leaq	-688(%rbp), %rax
	movl	$672, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	memset
	movq	sp(%rip), %rax
	andq	$-16, %rax
	movq	%rax, sp(%rip)
	nop
.L39:
	movq	-768(%rbp), %rax
	leaq	8(%rax), %rdx
	movq	%rdx, -768(%rbp)
	movq	(%rax), %rax
	testq	%rax, %rax
	jne	.L39
	movq	-768(%rbp), %rax
	movq	%rax, -712(%rbp)
	jmp	.L40
.L42:
	movl	-728(%rbp), %eax
	cltq
	salq	$4, %rax
	addq	%rbp, %rax
	leaq	-688(%rax), %rcx
	movq	-712(%rbp), %rax
	movq	8(%rax), %rdx
	movq	(%rax), %rax
	movq	%rax, (%rcx)
	movq	%rdx, 8(%rcx)
	movq	-712(%rbp), %rax
	movq	(%rax), %rax
	cmpq	$3, %rax
	jne	.L41
	movl	-728(%rbp), %eax
	cltq
	salq	$4, %rax
	addq	%rbp, %rax
	subq	$680, %rax
	movq	$0, (%rax)
.L41:
	addq	$16, -712(%rbp)
	addl	$1, -728(%rbp)
.L40:
	movq	-712(%rbp), %rax
	movq	(%rax), %rax
	testq	%rax, %rax
	jne	.L42
	addl	$2, -728(%rbp)
	movl	-728(%rbp), %eax
	movl	%eax, %esi
	movl	$.LC19, %edi
	movl	$0, %eax
	call	printf
	movq	sp(%rip), %rax
	movl	-728(%rbp), %edx
	movslq	%edx, %rdx
	salq	$4, %rdx
	negq	%rdx
	addq	%rdx, %rax
	movq	%rax, sp(%rip)
	movl	-756(%rbp), %eax
	addl	$5, %eax
	movl	%eax, -724(%rbp)
	movq	sp(%rip), %rax
	movl	-724(%rbp), %edx
	movslq	%edx, %rdx
	salq	$3, %rdx
	negq	%rdx
	addq	%rdx, %rax
	andq	$-16, %rax
	movq	%rax, sp(%rip)
	movq	sp(%rip), %rax
	movq	%rax, stack_bottom(%rip)
	movq	sp(%rip), %rax
	movl	-756(%rbp), %edx
	movslq	%edx, %rdx
	movq	%rdx, (%rax)
	movq	sp(%rip), %rax
	addq	$8, %rax
	movq	%rax, sp(%rip)
	movq	arg_start(%rip), %rax
	movq	%rax, -720(%rbp)
	movl	$0, -732(%rbp)
	jmp	.L43
.L44:
	movq	sp(%rip), %rax
	movq	-720(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	-720(%rbp), %rax
	movq	%rax, %rdi
	call	strlen
	movq	%rax, -704(%rbp)
	movq	sp(%rip), %rax
	addq	$8, %rax
	movq	%rax, sp(%rip)
	movq	-704(%rbp), %rax
	addq	$1, %rax
	addq	%rax, -720(%rbp)
	addl	$1, -732(%rbp)
.L43:
	movl	-756(%rbp), %eax
	subl	$1, %eax
	cmpl	-732(%rbp), %eax
	jg	.L44
	movq	sp(%rip), %rax
	movq	$0, (%rax)
	movq	sp(%rip), %rax
	addq	$8, %rax
	movq	%rax, sp(%rip)
	movq	env_start(%rip), %rax
	movq	%rax, -720(%rbp)
	movl	$0, -732(%rbp)
	jmp	.L45
.L46:
	movq	sp(%rip), %rax
	movq	-720(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	-720(%rbp), %rax
	movq	%rax, %rdi
	call	strlen
	movq	%rax, -696(%rbp)
	movq	sp(%rip), %rax
	addq	$8, %rax
	movq	%rax, sp(%rip)
	movq	-696(%rbp), %rax
	addq	%rax, -720(%rbp)
	addl	$1, -732(%rbp)
.L45:
	cmpl	$1, -732(%rbp)
	jle	.L46
	movq	sp(%rip), %rax
	movq	$0, (%rax)
	movq	sp(%rip), %rax
	addq	$8, %rax
	movq	%rax, sp(%rip)
	movl	-728(%rbp), %eax
	cltq
	salq	$4, %rax
	movq	%rax, %rdx
	movq	sp(%rip), %rax
	leaq	-688(%rbp), %rcx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	memcpy
	movl	$0, %eax
	movq	-8(%rbp), %rsi
	xorq	%fs:40, %rsi
	je	.L48
	call	__stack_chk_fail
.L48:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	create_elf_tables, .-create_elf_tables
	.section	.rodata
.LC20:
	.string	"mmap error in %s\n"
.LC21:
	.string	"ENVVAR2=2"
.LC22:
	.string	"ENVVAR=1"
	.text
	.globl	init_stack
	.type	init_stack, @function
init_stack:
.LFB9:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movl	%edi, -36(%rbp)
	movq	%rsi, -48(%rbp)
	movl	$0, -16(%rbp)
	movl	$0, -12(%rbp)
	movl	$3, -16(%rbp)
	movl	$306, -12(%rbp)
	movl	-12(%rbp), %edx
	movl	-16(%rbp), %eax
	movl	$0, %r9d
	movl	$-1, %r8d
	movl	%edx, %ecx
	movl	%eax, %edx
	movl	$40960, %esi
	movl	$268435456, %edi
	call	mmap
	movq	%rax, sp(%rip)
	movq	sp(%rip), %rax
	cmpq	$-1, %rax
	jne	.L50
	movq	stderr(%rip), %rax
	movl	$__func__.4208, %edx
	movl	$.LC20, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf
	movl	$-1, %eax
	jmp	.L51
.L50:
	movq	sp(%rip), %rax
	movl	$40960, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	memset
	movq	$268476416, sp(%rip)
	movq	$9, -8(%rbp)
	movq	sp(%rip), %rax
	movq	-8(%rbp), %rdx
	notq	%rdx
	addq	%rdx, %rax
	movq	%rax, sp(%rip)
	movq	sp(%rip), %rax
	movq	%rax, env_end(%rip)
	movq	-8(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	sp(%rip), %rax
	movl	$.LC21, %esi
	movq	%rax, %rdi
	call	memcpy
	movq	$9, -8(%rbp)
	movq	sp(%rip), %rax
	movq	-8(%rbp), %rdx
	notq	%rdx
	addq	%rdx, %rax
	movq	%rax, sp(%rip)
	movq	-8(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	sp(%rip), %rax
	movl	$.LC22, %esi
	movq	%rax, %rdi
	call	memcpy
	movq	sp(%rip), %rax
	movq	%rax, env_start(%rip)
	movl	-36(%rbp), %eax
	subl	$1, %eax
	movl	%eax, -20(%rbp)
	jmp	.L52
.L55:
	movl	-20(%rbp), %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	-48(%rbp), %rax
	addq	%rdx, %rax
	movq	(%rax), %rax
	movq	%rax, %rdi
	call	strlen
	movq	%rax, -8(%rbp)
	movq	sp(%rip), %rax
	movq	-8(%rbp), %rdx
	notq	%rdx
	addq	%rdx, %rax
	movq	%rax, sp(%rip)
	movl	-36(%rbp), %eax
	subl	$1, %eax
	cmpl	-20(%rbp), %eax
	jne	.L53
	movq	sp(%rip), %rax
	movq	%rax, arg_end(%rip)
.L53:
	cmpl	$1, -20(%rbp)
	jne	.L54
	movq	sp(%rip), %rax
	movq	%rax, arg_start(%rip)
.L54:
	movq	-8(%rbp), %rax
	leaq	1(%rax), %rdx
	movl	-20(%rbp), %eax
	cltq
	leaq	0(,%rax,8), %rcx
	movq	-48(%rbp), %rax
	addq	%rcx, %rax
	movq	(%rax), %rcx
	movq	sp(%rip), %rax
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	memcpy
	movq	sp(%rip), %rax
	movq	%rax, %rdi
	call	puts
	subl	$1, -20(%rbp)
.L52:
	cmpl	$0, -20(%rbp)
	jg	.L55
	movl	$0, %eax
.L51:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	init_stack, .-init_stack
	.section	.rodata
.LC23:
	.string	"fault: %lu\n"
.LC24:
	.string	"%p\n"
	.text
	.globl	jump_to_entry
	.type	jump_to_entry, @function
jump_to_entry:
.LFB10:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	$7128708, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, %rsi
	movl	$.LC23, %edi
	movl	$0, %eax
	call	printf
	movq	-24(%rbp), %rax
	movq	%rax, %rsi
	movl	$.LC24, %edi
	movl	$0, %eax
	call	printf
#APP
# 307 "apager.c" 1
	movq $0, %rax
# 0 "" 2
# 308 "apager.c" 1
	movq $0, %rbx
# 0 "" 2
# 309 "apager.c" 1
	movq $0, %rcx
# 0 "" 2
# 310 "apager.c" 1
	movq $0, %rdx
# 0 "" 2
#NO_APP
	movq	stack_bottom(%rip), %rax
#APP
# 311 "apager.c" 1
	movq %rax, %rsp
# 0 "" 2
#NO_APP
	movq	-24(%rbp), %rax
	movq	%rax, %rcx
#APP
# 312 "apager.c" 1
	jmp *%rcx
# 0 "" 2
#NO_APP
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	jump_to_entry, .-jump_to_entry
	.section	.rodata
	.align 8
	.type	__func__.4208, @object
	.size	__func__.4208, 11
__func__.4208:
	.string	"init_stack"
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.10) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
