#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
enum ENCLOSED_TYPE {
	IF_TYPE, IF_ELSE_TYPE, BEGIN_UNTIL_TYPE, DO_LOOP_TYPE
};
typedef struct _label_entry {
	enum ENCLOSED_TYPE type;
	int cnt;
	struct _label_entry *next;
} label_entry;
label_entry* set_label(enum ENCLOSED_TYPE type, int cnt, label_entry* labels) {
	label_entry* entry = (label_entry*)malloc(sizeof(label_entry));
	entry->type = type;
	entry->cnt = cnt;
	entry->next = labels;
	return entry;
}
// Pop the entry. Need to check labels != NULL beforehand.
label_entry* pop_entry(label_entry* labels) {
	label_entry* next = labels->next;
	free(labels);
	return next;
}
// Determine if a word is a (integer) number
int isnumber(char* word) {
	if (*word == '-')
		++word;
	if (*word == '\0')
		return 0;
	for (;*word != '\0'; ++word)
		if (!isdigit(*word))
			return 0;
	return 1;
}
int compile(FILE* fout) {
	label_entry* labels = NULL;
	char word[256];
	int lineno=1, newline=0;
	int def_words = 0, next_def_word = 0;
	int if_cnt = 0, loop_cnt = 0, until_cnt = 0;
	int line_comment=0, brace_comment=0;
	fprintf(fout, ".text\n");
	while (scanf("%s", word) != EOF) {
		int len = strlen(word);
		if (word[len-1] == '\n') {
			word[len-1] = '\0';
			newline = 1;
		}
		if (strcmp(word, "\\") == 0) {
			line_comment = 1;
		}
		if (line_comment) {
			if (newline)
				newline = 0, ++lineno, line_comment = 0;
			continue;
		}
		if (strcmp(word, "(") == 0) {
			brace_comment = 1;
		}
		else if (strcmp(word, ")") == 0) {
			brace_comment = 0;
			continue;
		}
		if (brace_comment) {
			if (newline)
				newline = 0, ++lineno, brace_comment = 0;
			continue;
		}

		if (isnumber(word)) {
			int num;
			sscanf(word, "%d", &num);
			if (num > 32767 || num < -32768) {
				printf("L%d Literal out of range\n", num);
				return -1;
			}
			if (num >= 0)
				fprintf(fout, "imm %d\n", num);
			else {
				fprintf(fout, "imm %d\n", -(num + 1));
				fprintf(fout, "not _ T 0 0 1\n");
			}
		}
		// Word definition
		else if (strcmp(word, ":") == 0) {
			if (def_words) {
				printf("L%d Nested words definition not allowed\n", lineno);
				return -1;
			}
			else {
				fprintf(fout, "\n.dict\n");
				def_words = next_def_word = 1;
			}
		}
		else if (strcmp(word, ";") == 0) {
			if (!def_words || next_def_word) {
				printf("L%d Unexpected \";\"\n", lineno);
				return -1;
			}
			else {
				fprintf(fout, "jr\n");
				def_words = 0;
				fprintf(fout, "\n.text\n");
			}
		}
		else if (next_def_word) {
			fprintf(fout, "%s:\n", word);
			next_def_word = 0;
		}
		// Address stack operations
		else if (strcmp(word, ">r") == 0) {
			fprintf(fout, "movb _ R -1 1 1\n");
		}
		else if (strcmp(word, "r>") == 0) {
			fprintf(fout, "movb R T 1 -1 0\n");
		}
		else if (strcmp(word, "r@") == 0) {
			fprintf(fout, "movb R T 1 0 0\n");
		}
		// Control flow
		else if (strcmp(word, "if") == 0) {
			labels = set_label(IF_TYPE, if_cnt++, labels);
			fprintf(fout, "jz _else_%d\n", labels->cnt);
			fprintf(fout, "movb R R -1 0 0\n");
		}
		else if (strcmp(word, "else") == 0) {
			if (labels == NULL || labels->type != IF_TYPE) {
				printf("L%d: Unmatched else\n", lineno);
				return 1;
			}
			fprintf(fout, "j _then_%d\n", labels->cnt);
			fprintf(fout, "_else_%d:\n", labels->cnt);
			fprintf(fout, "movb R R -1 0 0\n");
			labels->type = IF_ELSE_TYPE;
		}
		else if (strcmp(word, "then") == 0) {
			if (labels == NULL || (labels->type != IF_TYPE & labels->type != IF_ELSE_TYPE)) {
				printf("L%d: Unmatched then\n", lineno);
				return 1;
			}
			fprintf(fout, "j _then_%d\n", labels->cnt);
			if (labels->type == IF_TYPE) {
				fprintf(fout, "_else_%d:\n", labels->cnt);
				fprintf(fout, "movb R R -1 0 0\n");
			}
			fprintf(fout, "_then_%d:\n", labels->cnt);
			labels = pop_entry(labels);
		}
		else if (strcmp(word, "begin") == 0) {
			labels = set_label(BEGIN_UNTIL_TYPE, until_cnt++, labels);
			fprintf(fout, "imm 0\n");
			fprintf(fout, "_begin_%d:\n", labels->cnt);
			fprintf(fout, "movb R R -1 0 0\n"); // Remove the flag created last time
		}
		else if (strcmp(word, "until") == 0) {
			if (labels == NULL || labels->type != BEGIN_UNTIL_TYPE) {
				printf("L%d: Unmatched until\n", lineno);
				return 1;
			}
			fprintf(fout, "jz _begin_%d\n", labels->cnt);
			fprintf(fout, "movb R R -1 0 0\n"); // Remove the flag created last time
		}
		else if (strcmp(word, "do") == 0) {
			labels = set_label(DO_LOOP_TYPE, loop_cnt++, labels);
			fprintf(fout, "movb _ R -1 1 1\n");
			fprintf(fout, "movb _ R -1 1 1\n"); // | hi lo
			fprintf(fout, "imm 0\n");
			fprintf(fout, "_do_%d:\n", labels->cnt);
			fprintf(fout, "movb R R -1 0 0\n"); // Remove the flag created last time
		}
		else if (strcmp(word, "loop") == 0) {
			if (labels == NULL || labels->type != DO_LOOP_TYPE) {
				printf("L%d: Unmatched loop\n", lineno);
				return 1;
			}
			fprintf(fout, "movb R T 1 -1 0\n"); // hi | lo
			fprintf(fout, "imm 1\n"); // hi 1 | lo
			fprintf(fout, "add R R -1 0 0\n"); // hi | lo+1
			fprintf(fout, "sge R T 1 0 1\n"); // hi lo>=hi | lo
			fprintf(fout, "jal swap\n"); // lo>=hi hi | lo
			fprintf(fout, "movb _ R -1 1 1\n"); // lo>=hi | hi lo
			fprintf(fout, "jz _do_%d\n", labels->cnt);
			fprintf(fout, "movb R R -1 0 0\n"); // Remove the flag created last time
			fprintf(fout, "movb R R 0 -1 0\n"); // Remove the loop variable
			fprintf(fout, "movb R R 0 -1 0\n"); // Remove the loop variable
		}
		else fprintf(fout, "jal %s\n", word);
		if (newline)
			++lineno, newline = 0;
	}
	if (def_words) {
		printf("L%d Unenclosed word definition\n", lineno);
		return 1;
	}
	return 0;
}
int main(int argc, char* argv[]) {
	if (argc != 3) {
		printf("Arguments: fs_in assembly_out");
		return 1;
	}
	char line[256];
	FILE* fout = fopen(argv[2], "w");
	freopen("builtin.asm", "r",stdin);
	fputs("# Builtin\n", fout);
	while (gets(line) != NULL)
		fprintf(fout, "%s\n", line);
	fputs("# End of Builtin\n\n", fout);
	freopen(argv[1], "r", stdin);
	if (compile(fout) == 0) {
		printf("Compile success\n");
		return 0;
	}
	else {
		fclose(fout);
		fopen(argv[2], "w");
		printf("Compile fail\n");
		return 1;
	}
}