#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define DICT_LO 4096
#define DICT_HI 8192
#define TEXT_LO 0
#define TEXT_HI 4096
#define MAX_IMM 32768
typedef struct _label_entry {
	char* label;
	int pc;
	int lineno;
	struct _label_entry *next;
} label_entry;
const char* aluops[] = {"", "add", "sub", "mul", "div", "mod", "and", "or", "xor", "not", "movb", "sll", "srl", "slt", "sge", "seq"};
label_entry* set_label(char* line, int pc, label_entry* labels) {
	label_entry* entry = (label_entry*)malloc(sizeof(label_entry));
	entry->label = strdup(line);
	entry->pc = pc;
	entry->next = labels;
	return entry;
}
int find_label(char* line, label_entry* labels) {
	for (; labels != NULL && strcmp(labels->label, line) != 0; labels = labels -> next);
	if (labels == NULL)
		return -1;
	else return labels->pc;
}
void resolve_hanging(label_entry** hangings, char* labelname, int pc, int lineno, int* code_buf, int* dict_buf) {
	label_entry *i, *next, *prev = NULL;
	for (i=*hangings; i!=NULL; i=next) {
		next = i->next;
		if (strcmp(i->label, labelname) == 0) {
			int* pos;
			if (i->pc >= DICT_LO && i->pc <= DICT_HI)
				pos = dict_buf + ((i->pc - DICT_LO) >> 1);
			else if (i->pc >= TEXT_LO && i->pc <= TEXT_HI)
				pos = code_buf + ((i->pc - TEXT_LO) >> 1);
			else {
				printf("L%d encounter invalid hanging label %s", lineno, i->label);
				continue;
			}
			*pos |= pc;
			printf("L%d hanging label %s at L%d resolved to %d\n", lineno, i->label, lineno, pc);
			if (i == *hangings)
				*hangings = next;
			if (prev)
				prev->next = next;
			free(i);
		}
		prev = i;
	}
}
int assemble(char* code_out, char* dict_out) {
	int code_buf[4096];
	int dict_buf[4096];
	char line[256];
	int d_pc = DICT_LO, t_pc = TEXT_LO, lineno = 0;
	FILE* f_code = fopen(code_out, "w");
	FILE* f_dict = fopen(dict_out, "w");
	int *code_pt, *dict_pt;
	int** buf = NULL;
	int* pc = NULL;
	label_entry* labels = NULL;
	label_entry* hanging = NULL;
	code_pt = code_buf, dict_pt = dict_buf;
	memset(code_buf, 0, sizeof(code_buf));
	memset(dict_buf, 0, sizeof(dict_buf));

	while (gets(line) != NULL) {
		++lineno;
		int len = strlen(line);
		for (int i=0; i<len; ++i)
			if (line[i] == '#') {
				line[i] = '\0';
				len = i;
			}
		while (len>0 && line[len-1] == ' ')
			line[--len] = '\0';
		if (line[0] == '\0')
			continue;
		if (strcmp(line, ".dict") == 0) {
			buf = &dict_pt;
			pc = &d_pc;
			continue;
		}
		else if (strcmp(line, ".text") == 0) {
			buf = &code_pt;
			pc = &t_pc;
			continue;
		}
		else if (buf == NULL) {
			printf("L%d: Section error\n", lineno);
			return -1;
		}
		if (line[strlen(line)-1] == ':') {
			line[strlen(line)-1] = '\0';
			labels = set_label(line, *pc, labels);
			resolve_hanging(&hanging, line, *pc, lineno, code_buf, dict_buf);
			continue;
		}
		if (strncmp(line, "imm ", 4) == 0) {
			int imm;
			sscanf(line, "imm %d", &imm);
			if (! (0 <= imm && imm < MAX_IMM)) {
				printf("L%d: Imm out of range\n", lineno);
				return -1;
			}
			*((*buf)++) = (1<<15)|imm;
		}
		else if (strncmp(line, "jr", 2) == 0) {
			*((*buf)++) = 0;
		}
		else if (line[0] == 'j') {
			char label[256];
			int ret, type;
			if (strncmp(line, "jal ", 4) == 0) {
				sscanf(line, "jal %s", label);
				type = 1<<14;
			}
			else if (strncmp(line, "jz ", 3) == 0) {
				sscanf(line, "jz %s", label);
				type = 3<<13;
			}
			else if (strncmp(line, "j ", 2) == 0) {
				sscanf(line, "j %s", label);
				type = 1<<13;
			}
			else {
				printf("L%d: Invalid instruction\n", lineno);
				return -1;
			}
			if ((ret = find_label(label, labels)) == -1) {
				printf("L%d: hanging label %s\n", lineno, label);
				hanging = set_label(label, *pc, hanging);
				hanging -> lineno = lineno;
				ret = 0;
			}
			*((*buf)++) = type | ret;
		}
		else {
			char aluop[16], b_op[16], dest[16];
			int offset, aoffset, swap, opcode = 0, b_opcode, dest_opcode;
			sscanf(line, "%s %s %s %d %d %d", aluop, b_op, dest, &offset, &aoffset, &swap);
			for (int i=1; i<16; ++i)
				if (strcmp(aluops[i], aluop) == 0) {
					opcode = i;
					break;
				}
			if (opcode == 0) {
				printf("L%d: Invalid instruction (opcode)\n", lineno);
				return -1;
			}
			if (strcmp(b_op, "PC") == 0)
				b_opcode = 0;
			else if (strcmp(b_op, "N") == 0 || strcmp(b_op, "_") == 0)
				b_opcode = 1;
			else if (strcmp(b_op, "R") == 0)
				b_opcode = 2;
			else if (strcmp(b_op, "[T]") == 0)
				b_opcode = 3;
			else {
				printf("L%d: Invalid instruction (b_op)\n", lineno);
				return -1;
			}
			if (strcmp(dest, "T") == 0)
				dest_opcode = 0;
			else if (strcmp(dest, "N") == 0)
				dest_opcode = 1;
			else if (strcmp(dest, "R") == 0)
				dest_opcode = 2;
			else if (strcmp(dest, "[T]") == 0)
				dest_opcode = 3;
			else {
				printf("L%d: Invalid instruction (dest)\n", lineno);
				return -1;
			}
			if (offset > 1 || offset < -1 || aoffset > 1 || aoffset < -1 || swap > 1 || swap < 0) {
				printf("L%d: Invalid instruction (offset, swap)\n", lineno);
				return -1;
			}
			if (offset == -1)
				offset = 3;
			if (aoffset == -1)
				aoffset = 3;
			*((*buf)++) = (opcode << 9) | (b_opcode << 7) | (dest_opcode << 5) | (offset << 3) | (aoffset << 1) | swap;
		}
		*pc += 2;
		if (d_pc == DICT_HI || t_pc == TEXT_HI) {
			printf("L%d: Code too long\n", lineno);
			return -1;
		}
	}
	if (hanging != NULL) {
		printf("Hanging labels not resolved\n");
		for (; hanging != NULL; hanging = hanging -> next)
			printf("L%d %s\n", hanging->lineno, hanging->label);
		return 1;
	}
	for (int i=0; code_buf+i<code_pt; ++i) {
		for (int j = 15; j >= 0; --j)
			fprintf(f_code, "%d", (code_buf[i]>>j)&1);
		fprintf(f_code, "\n");
	}
	for (int i=0; dict_buf+i<dict_pt; ++i) {
		for (int j = 15; j >= 0; --j)
			fprintf(f_dict, "%d", (dict_buf[i]>>j)&1);
		fprintf(f_dict, "\n");
	}
	return 0;
}
int main(int argc, char* argv[]) {
	if (argc != 4) {
		printf("Arguments: assembly_in code_out dict_out");
		return -1;
	}
	freopen(argv[1], "r", stdin);
	if (assemble(argv[2], argv[3]) == 0) {
		printf("Assemble success\n");
		return 0;
	}
	else {
		printf("Assemble fail\n");
		return -1;
	}
}